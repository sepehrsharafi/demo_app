import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../l10n/app_language.dart';
import '../models/ask_topic.dart';
import '../models/care_level.dart';
import '../models/child_profile.dart';
import '../models/context_note.dart';
import '../models/conversation.dart';
import '../models/preferences.dart';

/// Everything Mother AI keeps on the phone, in one SQLite database: the
/// children and what it has learned about each, the two preferences, and
/// past conversations.
///
/// Children, their context, preferences and the list of conversations are
/// small and shown on every tab, so they live in memory and are written
/// through to the database. A conversation's messages are read only when it
/// is opened.
class AppStore extends ChangeNotifier {
  AppStore._(this._db);

  final Database _db;
  List<ChildProfile> _children = const [];
  List<Conversation> _conversations = const [];
  Map<int, List<ContextNote>> _context = const {};
  late AppLanguage _language;
  late Units _units;

  /// Opens the database on the phone; tests pass an in-memory one.
  static Future<AppStore> open({DatabaseFactory? factory, String? path}) async {
    factory ??= databaseFactory;
    path ??= p.join(await factory.getDatabasesPath(), 'mother_ai.db');
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        // Off by default in SQLite; removing a child relies on it to take
        // their conversations and context with them.
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
    final store = AppStore._(db);
    store._load(
      children: await db.query('children', orderBy: 'id'),
      context: await db.query(
        'context_notes',
        orderBy: 'updated_at DESC, id DESC',
      ),
      conversations: await db.query(
        'conversations',
        orderBy: 'updated_at DESC',
      ),
      settings: await db.query('settings'),
    );
    return store;
  }

  static Future<void> _create(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE children (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          birthday TEXT NOT NULL,
          hue INTEGER NOT NULL,
          allergies TEXT,
          conditions TEXT,
          medications TEXT,
          notes TEXT
        )''')
      ..execute('''
        CREATE TABLE conversations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          child_id INTEGER REFERENCES children(id) ON DELETE CASCADE,
          topic TEXT,
          title TEXT NOT NULL,
          preview TEXT NOT NULL DEFAULT '',
          care TEXT,
          updated_at INTEGER NOT NULL
        )''')
      ..execute('''
        CREATE TABLE messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          conversation_id INTEGER NOT NULL
            REFERENCES conversations(id) ON DELETE CASCADE,
          is_mine INTEGER NOT NULL,
          content TEXT NOT NULL
        )''')
      ..execute('CREATE INDEX conversations_child ON conversations(child_id)')
      ..execute(
        'CREATE INDEX messages_conversation ON messages(conversation_id)',
      )
      ..execute(
        'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
    _createContext(batch);
    await batch.commit(noResult: true);
  }

  /// Version 2 added what Mother AI learns about each child from chats.
  static Future<void> _upgrade(Database db, int from, int to) async {
    final batch = db.batch();
    if (from < 2) _createContext(batch);
    await batch.commit(noResult: true);
  }

  static void _createContext(Batch batch) => batch
    ..execute('''
      CREATE TABLE context_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL REFERENCES children(id) ON DELETE CASCADE,
        text TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )''')
    ..execute('CREATE INDEX context_notes_child ON context_notes(child_id)');

  void _load({
    required List<Map<String, Object?>> children,
    required List<Map<String, Object?>> context,
    required List<Map<String, Object?>> conversations,
    required List<Map<String, Object?>> settings,
  }) {
    _children = [for (final row in children) _childFrom(row)];
    final notes = <int, List<ContextNote>>{};
    for (final row in context) {
      final note = _noteFrom(row);
      (notes[note.childId] ??= []).add(note);
    }
    _context = notes;
    _conversations = [for (final row in conversations) _conversationFrom(row)];
    final saved = {
      for (final row in settings)
        row['key']! as String: row['value']! as String,
    };
    // Until the parent chooses, follow the phone.
    final locale = PlatformDispatcher.instance.locale;
    _language =
        AppLanguage.fromCode(saved['language']) ??
        AppLanguage.fromCode(locale.languageCode) ??
        AppLanguage.en;
    languageNotifier = ValueNotifier(_language);
    _units =
        Units.values.asNameMap()[saved['units']] ??
        (locale.countryCode == 'US' ? Units.imperial : Units.metric);
  }

  Future<void> close() => _db.close();

  // Children

  List<ChildProfile> get children => _children;

  ChildProfile? child(int? id) =>
      id == null ? null : _children.where((c) => c.id == id).firstOrNull;

  /// Adds a child, or saves changes to the one with [id].
  Future<ChildProfile> saveChild({
    int? id,
    required String name,
    required DateTime birthday,
    String? allergies,
    String? conditions,
    String? medications,
    String? notes,
  }) async {
    final existing = child(id);
    final row = <String, Object?>{
      'name': name.trim(),
      'birthday': _day(birthday),
      'hue': existing?.hueIndex ?? _freeHue(),
      'allergies': _blankToNull(allergies),
      'conditions': _blankToNull(conditions),
      'medications': _blankToNull(medications),
      'notes': _blankToNull(notes),
    };
    if (existing == null) {
      row['id'] = await _db.insert('children', row);
    } else {
      await _db.update(
        'children',
        row,
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      row['id'] = existing.id;
    }
    final saved = _childFrom(row);
    _children = [
      for (final c in _children) c.id == saved.id ? saved : c,
      if (existing == null) saved,
    ];
    notifyListeners();
    return saved;
  }

  /// Removes a child and every conversation about them.
  Future<void> removeChild(ChildProfile child) async {
    await _db.delete('children', where: 'id = ?', whereArgs: [child.id]);
    _children = [
      for (final c in _children)
        if (c.id != child.id) c,
    ];
    _conversations = [
      for (final c in _conversations)
        if (c.childId != child.id) c,
    ];
    _context = {..._context}..remove(child.id);
    notifyListeners();
  }

  /// The hue fewest children have, so brothers and sisters look different.
  int _freeHue() {
    final uses = List.filled(childHues.length, 0);
    for (final c in _children) {
      uses[c.hueIndex % childHues.length]++;
    }
    return uses.indexOf(uses.reduce((a, b) => a < b ? a : b));
  }

  // Context

  /// What Mother AI has learned about [child] from chats, newest first.
  List<ContextNote> contextOf(ChildProfile? child) =>
      child == null ? const [] : _context[child.id] ?? const [];

  /// Applies [update] to [child]'s context, whether Mother AI or the parent
  /// made it. Only notes of this child's that still exist are changed, and
  /// it resolves to what was actually applied.
  Future<ContextUpdate> reviseContext(
    ChildProfile child,
    ContextUpdate update,
  ) async {
    final current = contextOf(child);
    final applied = update.within(current.map((note) => note.id));
    // The child may have been removed while Mother AI was thinking.
    if (applied.isEmpty || this.child(child.id) == null) {
      return const ContextUpdate();
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final added = <ContextNote>[];
    await _db.transaction((txn) async {
      for (final id in applied.removed) {
        await txn.delete('context_notes', where: 'id = ?', whereArgs: [id]);
      }
      for (final MapEntry(key: id, value: text) in applied.edited.entries) {
        await txn.update(
          'context_notes',
          {'text': text, 'updated_at': now},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      for (final text in applied.added) {
        final row = <String, Object?>{
          'child_id': child.id,
          'text': text,
          'updated_at': now,
        };
        row['id'] = await txn.insert('context_notes', row);
        added.add(_noteFrom(row));
      }
    });
    final changed = [
      for (final note in current)
        if (applied.edited[note.id] case final text?)
          _noteFrom({
            'id': note.id,
            'child_id': child.id,
            'text': text,
            'updated_at': now,
          }),
    ];
    _context = {
      ..._context,
      child.id: [
        ...added.reversed,
        ...changed,
        for (final note in current)
          if (!applied.removed.contains(note.id) &&
              !applied.edited.containsKey(note.id))
            note,
      ],
    };
    notifyListeners();
    return applied;
  }

  // Preferences

  /// The language of the app and of Mother AI's answers. Only the app's
  /// frame listens to it, so a new chat message doesn't rebuild the app.
  late final ValueNotifier<AppLanguage> languageNotifier;
  AppLanguage get language => _language;

  /// The language named in itself, which is how Mother AI is told to answer.
  String get languageName => _language.nativeName;
  Units get units => _units;

  Future<void> setLanguage(AppLanguage chosen) async {
    await _put('language', chosen.code);
    _language = chosen;
    languageNotifier.value = chosen;
    notifyListeners();
  }

  Future<void> setUnits(Units units) async {
    await _put('units', units.name);
    _units = units;
    notifyListeners();
  }

  Future<void> _put(String key, String value) => _db.insert('settings', {
    'key': key,
    'value': value,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  // Conversations

  /// Newest first.
  List<Conversation> get conversations => _conversations;

  /// The newest conversation about [child], or the newest of all.
  Conversation? latestFor(ChildProfile? child) =>
      _conversations.where((c) => c.childId == child?.id).firstOrNull ??
      _conversations.firstOrNull;

  Future<List<ChatMessage>> messages(int conversationId) async {
    final rows = await _db.query(
      'messages',
      columns: ['is_mine', 'content'],
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'id',
    );
    return [
      for (final row in rows)
        ChatMessage(row['content']! as String, isMine: row['is_mine'] == 1),
    ];
  }

  /// Starts a conversation with its first question. Resolves to its id.
  Future<int> startConversation(
    ChatMessage question, {
    required ChildProfile? child,
    required AskTopic? topic,
  }) async {
    final row = <String, Object?>{
      'child_id': child?.id,
      'topic': topic?.name,
      'title': question.content.split('\n').first.trim(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    row['id'] = await _db.transaction((txn) async {
      final id = await txn.insert('conversations', row);
      await txn.insert('messages', _messageRow(id, question));
      return id;
    });
    _conversations = [_conversationFrom(row), ..._conversations];
    notifyListeners();
    return row['id']! as int;
  }

  /// Adds a message to a conversation and moves it to the top of the list.
  Future<void> addMessage(int conversationId, ChatMessage message) async {
    final current = _conversations
        .where((c) => c.id == conversationId)
        .firstOrNull;
    if (current == null) return;
    final reply = message.reply;
    final care = message.isMine
        ? current.care
        : _higher(current.care, reply.care);
    final changes = <String, Object?>{
      'preview': message.isMine
          ? current.preview
          : (reply.text.isEmpty ? reply.steps.firstOrNull ?? '' : reply.text),
      'care': care?.name,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    await _db.transaction((txn) async {
      await txn.insert('messages', _messageRow(conversationId, message));
      await txn.update(
        'conversations',
        changes,
        where: 'id = ?',
        whereArgs: [conversationId],
      );
    });
    _conversations = [
      _conversationFrom({
        'id': current.id,
        'child_id': current.childId,
        'topic': current.topic?.name,
        'title': current.title,
        ...changes,
      }),
      for (final c in _conversations)
        if (c.id != conversationId) c,
    ];
    notifyListeners();
  }

  static CareLevel? _higher(CareLevel? a, CareLevel? b) =>
      a == null || (b != null && b.index > a.index) ? b : a;

  // Rows

  static Map<String, Object?> _messageRow(int conversationId, ChatMessage m) =>
      {
        'conversation_id': conversationId,
        'is_mine': m.isMine ? 1 : 0,
        'content': m.content,
      };

  static ChildProfile _childFrom(Map<String, Object?> row) => ChildProfile(
    id: row['id']! as int,
    name: row['name']! as String,
    birthday: DateTime.parse(row['birthday']! as String),
    hueIndex: row['hue']! as int,
    allergies: row['allergies'] as String?,
    conditions: row['conditions'] as String?,
    medications: row['medications'] as String?,
    notes: row['notes'] as String?,
  );

  static ContextNote _noteFrom(Map<String, Object?> row) => ContextNote(
    id: row['id']! as int,
    childId: row['child_id']! as int,
    text: row['text']! as String,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
  );

  static Conversation _conversationFrom(Map<String, Object?> row) =>
      Conversation(
        id: row['id']! as int,
        title: row['title']! as String,
        childId: row['child_id'] as int?,
        topic: AskTopic.values.asNameMap()[row['topic']],
        preview: row['preview'] as String? ?? '',
        care: CareLevel.values.asNameMap()[row['care']],
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          row['updated_at']! as int,
        ),
      );

  /// "2026-03-14": a birthday is a day, not a moment.
  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
