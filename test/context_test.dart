import 'dart:convert';
import 'dart:io';

import 'package:demo_app/core/ai/context_keeper.dart';
import 'package:demo_app/core/ai/mother_ai.dart';
import 'package:demo_app/core/ai/system_prompt.dart';
import 'package:demo_app/core/data/app_store.dart';
import 'package:demo_app/core/models/child_profile.dart';
import 'package:demo_app/core/models/context_note.dart';
import 'package:demo_app/core/models/conversation.dart';
import 'package:demo_app/core/models/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support.dart';

void main() {
  group('reading a review', () {
    test('takes notes to add, rewrite and remove', () {
      final update = MotherAi.parseContextUpdate(
        '{"add": ["Fell and hurt her knee on 29 Sep 2026."], '
        '"update": [{"id": 3, "text": "Sleeps through since 20 Sep 2026."}], '
        '"remove": [5, "7"]}',
      );
      expect(update.added, ['Fell and hurt her knee on 29 Sep 2026.']);
      expect(update.edited, {3: 'Sleeps through since 20 Sep 2026.'});
      expect(update.removed, {5, 7});
    });

    test('survives prose around it and leaves out what is malformed', () {
      final update = MotherAi.parseContextUpdate(
        'Here you go: {"add": ["Teething.", 4], '
        '"update": [{"id": "x", "text": "?"}, {"text": "no id"}], '
        '"remove": null}',
      );
      expect(update.added, ['Teething.']);
      expect(update.edited, isEmpty);
      expect(update.removed, isEmpty);
      expect(MotherAi.parseContextUpdate('not json').isEmpty, isTrue);
      expect(MotherAi.parseContextUpdate('{"add": [').isEmpty, isTrue);
    });

    test('applies only to notes that exist, and never an empty one', () {
      const update = ContextUpdate(
        added: ['  ', 'New.'],
        edited: {1: 'Changed.', 2: 'Also removed.', 9: 'Made up.', 3: ' '},
        removed: {2, 8},
      );
      final applied = update.within([1, 2, 3]);
      expect(applied.added, ['New.']);
      expect(applied.edited, {1: 'Changed.'});
      expect(applied.removed, {2});
    });
  });

  group('the store', () {
    late AppStore store;
    late ChildProfile emma;

    setUp(() async {
      store = await openTestStore();
      emma = store.children.first;
    });
    tearDown(() => store.close());

    test('adds, rewrites and removes notes, newest first', () async {
      await store.reviseContext(
        emma,
        const ContextUpdate(added: ['Fell and hurt her knee.', 'Teething.']),
      );
      expect(store.contextOf(emma).map((n) => n.text), [
        'Teething.',
        'Fell and hurt her knee.',
      ]);
      final knee = store.contextOf(emma).last;

      await store.reviseContext(
        emma,
        ContextUpdate(edited: {knee.id: 'Knee is fine again.'}),
      );
      expect(store.contextOf(emma).first.text, 'Knee is fine again.');

      final applied = await store.reviseContext(
        emma,
        ContextUpdate(removed: {knee.id, 999}),
      );
      expect(applied.removed, {knee.id});
      expect(store.contextOf(emma).map((n) => n.text), ['Teething.']);
      // Nobody else's.
      expect(store.contextOf(store.children.last), isEmpty);
    });

    test('a removed child takes their context with them', () async {
      await store.reviseContext(emma, const ContextUpdate(added: ['A note.']));
      await store.removeChild(emma);
      expect(store.contextOf(emma), isEmpty);
      final applied = await store.reviseContext(
        emma,
        const ContextUpdate(added: ['Too late.']),
      );
      expect(applied.isEmpty, isTrue);
    });
  });

  test('a database from before context gains it, keeping the family', () async {
    sqfliteFfiInit();
    final dir = await Directory.systemTemp.createTemp('mother_ai');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'v1.db');

    // Version 1, as phones have it.
    final old = await databaseFactoryFfiNoIsolate.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute(
            'CREATE TABLE children (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL, birthday TEXT NOT NULL, hue INTEGER NOT NULL, '
            'allergies TEXT, conditions TEXT, medications TEXT, notes TEXT)',
          );
          await db.execute(
            'CREATE TABLE conversations (id INTEGER PRIMARY KEY '
            'AUTOINCREMENT, child_id INTEGER REFERENCES children(id) ON '
            'DELETE CASCADE, topic TEXT, title TEXT NOT NULL, preview TEXT '
            'NOT NULL DEFAULT \'\', care TEXT, updated_at INTEGER NOT NULL)',
          );
          await db.execute(
            'CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'conversation_id INTEGER NOT NULL REFERENCES conversations(id) '
            'ON DELETE CASCADE, is_mine INTEGER NOT NULL, content TEXT NOT '
            'NULL)',
          );
          await db.execute(
            'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
          );
          await db.insert('children', {
            'name': 'Emma',
            'birthday': '2026-03-14',
            'hue': 0,
          });
        },
      ),
    );
    await old.close();

    final store = await AppStore.open(
      factory: databaseFactoryFfiNoIsolate,
      path: path,
    );
    final emma = store.children.single;
    expect(emma.name, 'Emma');
    expect(store.contextOf(emma), isEmpty);
    await store.reviseContext(emma, const ContextUpdate(added: ['Teething.']));
    await store.close();

    final reopened = await AppStore.open(
      factory: databaseFactoryFfiNoIsolate,
      path: path,
    );
    expect(
      reopened.contextOf(reopened.children.single).single.text,
      'Teething.',
    );
    await reopened.close();
  });

  test('an answer is told what earlier chats taught Mother AI', () {
    final now = DateTime(2026, 10, 1);
    final child = ChildProfile(
      id: 1,
      name: 'Emma',
      birthday: DateTime(2026, 3, 14),
      hueIndex: 0,
    );
    final context = questionContext(
      child: child,
      topic: null,
      language: 'English',
      units: Units.metric,
      today: now,
      context: [
        ContextNote(
          id: 1,
          childId: 1,
          text: 'Fell and hurt her knee on 29 Sep 2026.',
          updatedAt: DateTime(2026, 9, 29),
        ),
      ],
      earlierChats: [
        Conversation(
          id: 4,
          title: 'Emma fell off the sofa',
          childId: 1,
          topic: null,
          preview: '',
          care: null,
          updatedAt: DateTime(2026, 9, 29),
        ),
      ],
    );
    expect(context, contains('Today is 1 Oct 2026.'));
    expect(
      context,
      contains('- 29 Sep 2026: Fell and hurt her knee on 29 Sep 2026.'),
    );
    expect(context, contains('- 29 Sep 2026: "Emma fell off the sofa"'));
  });

  test('a review sends the child, the notes and the end of the chat', () async {
    final store = await openTestStore();
    addTearDown(store.close);
    final groq = FakeGroq()
      ..review =
          '{"add": ["Fell and hurt her knee on 29 Sep 2026."], '
          '"update": [], "remove": []}';
    final emma = store.children.first;
    await store.reviseContext(emma, const ContextUpdate(added: ['Teething.']));

    final update = await ContextKeeper.review(
      store: store,
      ai: MotherAi(client: groq.client, apiKey: 'key'),
      child: emma,
      history: [
        for (var i = 0; i < 10; i++)
          ChatMessage('Message $i', isMine: i.isEven),
      ],
    );

    expect(update.added, ['Fell and hurt her knee on 29 Sep 2026.']);
    expect(store.contextOf(emma).first.text, startsWith('Fell'));
    final request = groq.reviews.single;
    expect(request['response_format'], {'type': 'json_object'});
    expect(request['stream'], isNot(true));
    final sent = ((request['messages'] as List).last as Map)['content'];
    expect(sent, contains('Child: Emma'));
    expect(sent, contains('Teething.'));
    expect(sent, contains('Notes: Breastfed.'));
    // Only the last six messages.
    expect(sent, isNot(contains('Message 3')));
    expect(sent, contains('Parent: Message 4'));
    expect(sent, contains('Mother AI: Message 9'));
    expect(jsonEncode(request), contains(contextPrompt.substring(0, 40)));
  });

  test('a failed review changes nothing', () async {
    final store = await openTestStore();
    addTearDown(store.close);
    final groq = FakeGroq()..review = 'Sorry, I can’t.';
    final update = await ContextKeeper.review(
      store: store,
      ai: MotherAi(client: groq.client, apiKey: 'key'),
      child: store.children.first,
      history: [ChatMessage('Hi', isMine: true)],
    );
    expect(update.isEmpty, isTrue);
    expect(store.contextOf(store.children.first), isEmpty);
  });
}
