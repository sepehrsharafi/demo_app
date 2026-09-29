import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/child_profile.dart';
import '../models/context_note.dart';
import '../models/conversation.dart';
import 'system_prompt.dart';

/// Asks the model on Groq and streams its answers back.
///
/// One HTTP client serves the whole app, so a follow-up question reuses the
/// open connection instead of paying for a new TLS handshake.
class MotherAi {
  MotherAi({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? const String.fromEnvironment('GROQ_API_KEY');

  final http.Client _client;
  final String _apiKey;

  static const model = 'openai/gpt-oss-120b';
  static final _endpoint = Uri.parse(
    'https://api.groq.com/openai/v1/chat/completions',
  );

  /// How long to wait for the next piece of an answer before giving up.
  static const _patience = Duration(seconds: 30);

  /// Tries per question, while the service is busy or a connection drops.
  static const _attempts = 3;

  /// The history sent with a question: its latest messages, within budget.
  static const _historyMessages = 16;
  static const _historyChars = 12000;

  /// How much of a chat a context review reads: the new exchange and the
  /// two before it, which is what "she's fine now" needs to make sense.
  static const _reviewMessages = 6;

  /// Streams the answer to the last message in [history] as it is written.
  /// [context] describes the child and preferences (see [questionContext]).
  ///
  /// Fails with a [MotherAiException] whose message can be shown as is.
  /// Cancelling the subscription closes the connection.
  Stream<String> answer({
    required List<ChatMessage> history,
    required String context,
  }) async* {
    if (_apiKey.isEmpty) throw MotherAiException.notConfigured;

    final body = jsonEncode({
      'model': model,
      'messages': [
        // The unchanging prompt first, so the provider's cache can reuse it.
        {'role': 'system', 'content': '$systemPrompt\n\n$context'},
        for (final message in _recent(history))
          {
            'role': message.isMine ? 'user' : 'assistant',
            'content': message.content,
          },
      ],
      'stream': true,
      // Short answers need little thought, and less thought means the
      // first words arrive sooner.
      'reasoning_effort': 'low',
      // The reasoning is never shown, so it needn't travel.
      'include_reasoning': false,
      'max_completion_tokens': 1024,
    });

    for (var attempt = 1; ; attempt++) {
      // Aborts the request if nothing arrives for a while.
      final abort = Completer<void>();
      Timer? watchdog;
      void wait() {
        watchdog?.cancel();
        watchdog = Timer(_patience, () {
          if (!abort.isCompleted) abort.complete();
        });
      }

      final request =
          http.AbortableRequest('POST', _endpoint, abortTrigger: abort.future)
            ..headers['Authorization'] = 'Bearer $_apiKey'
            ..headers['Content-Type'] = 'application/json'
            ..body = body;
      var wrote = false;
      try {
        wait();
        final response = await _client.send(request);
        if (response.statusCode != 200) {
          final detail = await response.stream.bytesToString();
          final delay = _retryDelay(response, attempt);
          if (delay != null) {
            await Future<void>.delayed(delay);
            continue;
          }
          _log('HTTP ${response.statusCode}: $detail');
          throw MotherAiException.forStatus(response.statusCode);
        }

        final lines = response.stream.toStringStream().transform(
          const LineSplitter(),
        );
        await for (final line in lines) {
          wait();
          if (!line.startsWith('data:')) continue;
          final data = line.substring(5).trim();
          // Not a break: the response closes right after, and reading it to
          // the end hands the connection back for the next question
          // instead of tearing it down.
          if (data == '[DONE]') continue;
          final event = jsonDecode(data) as Map<String, dynamic>;
          if (event['error'] != null) {
            _log('Stream error: ${event['error']}');
            throw MotherAiException.failed;
          }
          final choices = event['choices'] as List?;
          final delta = choices?.firstOrNull?['delta'] as Map?;
          if (delta?['content'] case final String text when text.isNotEmpty) {
            wrote = true;
            yield text;
          }
        }
        if (!wrote) throw MotherAiException.silent;
        return;
      } on http.RequestAbortedException {
        throw MotherAiException.slow;
      } on http.ClientException catch (error) {
        // A dropped connection (often an idle one the server closed) is
        // worth another try, but not once part of an answer is showing.
        if (!wrote && attempt < _attempts) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
        _log('Connection: $error');
        throw MotherAiException.offline;
      } on FormatException catch (error) {
        _log('Unreadable event: $error');
        throw MotherAiException.failed;
      } finally {
        watchdog?.cancel();
      }
    }
  }

  /// Reads the end of a chat about [child] and says what it changes in
  /// what Mother AI remembers about them ([notes]). Runs quietly after an
  /// answer, so it never throws: a failed review changes nothing.
  Future<ContextUpdate> reviewContext({
    required ChildProfile child,
    required List<ContextNote> notes,
    required List<ChatMessage> history,
    required String language,
  }) async {
    if (_apiKey.isEmpty || history.isEmpty) return const ContextUpdate();
    final body = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': contextPrompt},
        {
          'role': 'user',
          'content': contextReview(
            child: child,
            notes: notes,
            exchange: history.sublist(
              (history.length - _reviewMessages).clamp(0, history.length),
            ),
            language: language,
          ),
        },
      ],
      'response_format': {'type': 'json_object'},
      'reasoning_effort': 'low',
      'include_reasoning': false,
      'max_completion_tokens': 1024,
    });
    try {
      final response = await _client
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(_patience);
      if (response.statusCode != 200) {
        _log('Context HTTP ${response.statusCode}: ${response.body}');
        return const ContextUpdate();
      }
      final completion = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      final content =
          (completion['choices'] as List).first['message']['content'] as String;
      return parseContextUpdate(content);
    } catch (error) {
      _log('Context review failed: $error');
      return const ContextUpdate();
    }
  }

  /// The review's JSON, read leniently: whatever part of it is malformed is
  /// left out rather than failing the rest.
  @visibleForTesting
  static ContextUpdate parseContextUpdate(String json) {
    final start = json.indexOf('{');
    final end = json.lastIndexOf('}');
    if (start < 0 || end < start) return const ContextUpdate();
    final Object? decoded;
    try {
      decoded = jsonDecode(json.substring(start, end + 1));
    } on FormatException {
      return const ContextUpdate();
    }
    if (decoded is! Map) return const ContextUpdate();
    final reply = decoded;
    int? id(Object? value) => switch (value) {
      final int id => id,
      final num id => id.toInt(),
      final String id => int.tryParse(id),
      _ => null,
    };
    List<Object?> list(String key) => switch (reply[key]) {
      final List list => list,
      _ => const [],
    };
    return ContextUpdate(
      added: [
        for (final text in list('add'))
          if (text is String) text,
      ],
      edited: {
        for (final change in list('update'))
          if (change case {'id': final Object? raw, 'text': final String text})
            ?id(raw): text,
      },
      removed: {for (final value in list('remove')) ?id(value)},
    );
  }

  /// A busy or failing service is tried again after a short wait, unless
  /// it asks for longer than a parent should be kept waiting.
  Duration? _retryDelay(http.BaseResponse response, int attempt) {
    final status = response.statusCode;
    if (attempt >= _attempts || (status != 429 && status < 500)) return null;
    final after = double.tryParse(response.headers['retry-after'] ?? '');
    if (after == null) return Duration(milliseconds: 600 * attempt);
    return after <= 5 ? Duration(milliseconds: (after * 1000).round()) : null;
  }

  /// The latest messages, newest kept first, within the history budget.
  static Iterable<ChatMessage> _recent(List<ChatMessage> history) {
    var start = history.length;
    var chars = 0;
    while (start > 0 && history.length - start < _historyMessages) {
      chars += history[start - 1].content.length;
      // The question being asked always goes, however long it is.
      if (chars > _historyChars && start < history.length) break;
      start--;
    }
    return history.skip(start);
  }

  static void _log(String message) {
    if (kDebugMode) debugPrint('MotherAi: $message');
  }
}

/// Why an answer couldn't be given, in words for the parent.
class MotherAiException implements Exception {
  const MotherAiException(this.message);

  final String message;

  static const notConfigured = MotherAiException(
    'Mother AI isn’t connected yet. Add a Groq API key to secrets.json and '
    'restart the app.',
  );
  static const offline = MotherAiException(
    'Mother AI can’t be reached. Check your connection and try again.',
  );
  static const slow = MotherAiException(
    'Mother AI is taking too long to answer. Try again.',
  );
  static const busy = MotherAiException(
    'Mother AI is busy right now. Try again in a minute.',
  );
  static const unavailable = MotherAiException(
    'Mother AI is having trouble right now. Try again in a moment.',
  );
  static const refused = MotherAiException(
    'Mother AI’s API key was refused. Check GROQ_API_KEY in secrets.json.',
  );

  /// Groq answers 403 to a valid key when it won't serve the network the
  /// request comes from (its supported regions), so this isn't the key.
  static const blocked = MotherAiException(
    'Mother AI isn’t available on this network. Try another connection or '
    'a VPN.',
  );
  static const silent = MotherAiException(
    'Mother AI didn’t answer. Try again.',
  );
  static const failed = MotherAiException('Something went wrong. Try again.');

  static MotherAiException forStatus(int status) => switch (status) {
    401 => refused,
    403 => blocked,
    429 => busy,
    >= 500 => unavailable,
    _ => failed,
  };

  @override
  String toString() => message;
}
