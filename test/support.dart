import 'dart:convert';

import 'package:demo_app/core/data/app_store.dart';
import 'package:demo_app/core/models/ask_topic.dart';
import 'package:demo_app/core/models/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const feverQuestion = 'Emma has a fever after her vaccines this morning';
const rashQuestion = 'Daniel has a fever and a rash that doesn’t fade';

/// A store in memory, with Emma, Daniel and a conversation about each when
/// [family] is set. Emma's conversation is the newest.
Future<AppStore> openTestStore({bool family = true}) async {
  sqfliteFfiInit();
  final store = await AppStore.open(
    factory: databaseFactoryFfiNoIsolate,
    path: inMemoryDatabasePath,
  );
  if (!family) return store;

  final now = DateTime.now();
  final emma = await store.saveChild(
    name: 'Emma',
    birthday: DateTime(now.year, now.month - 6, 1),
    notes: 'Breastfed. Starting solids this month.',
  );
  final daniel = await store.saveChild(
    name: 'Daniel',
    birthday: DateTime(now.year - 2, now.month - 4, 1),
    allergies: 'Peanuts (mild)',
    medications: 'Antihistamine, as needed',
  );
  final rash = await store.startConversation(
    ChatMessage(rashQuestion, isMine: true),
    child: daniel,
    topic: AskTopic.health,
  );
  await store.addMessage(
    rash,
    ChatMessage(
      'CARE: urgent\nThis needs a doctor straight away.\n'
      '1. Call your local emergency number now.',
      isMine: false,
    ),
  );
  final fever = await store.startConversation(
    ChatMessage(feverQuestion, isMine: true),
    child: emma,
    topic: AskTopic.health,
  );
  await store.addMessage(
    fever,
    ChatMessage(
      'CARE: home\nA mild fever after vaccines is common.\n'
      '1. Offer extra feeds.',
      isMine: false,
    ),
  );
  return store;
}

/// Groq's side of a test: streams scripted answers the way the real API
/// does, and keeps every request it was sent.
class FakeGroq {
  /// The questions asked, each a streamed request.
  final requests = <Map<String, dynamic>>[];

  /// The context reviews that followed answers about a child.
  final reviews = <Map<String, dynamic>>[];

  /// What a review finds; nothing, unless a test says otherwise.
  String review = '{"add": [], "update": [], "remove": []}';

  /// Statuses to fail the next requests with, in order.
  final failures = <int>[];

  /// What the model is told about the question, from the last request.
  String get lastContext =>
      ((requests.last['messages'] as List).first as Map)['content'] as String;

  static String answerFor(String question) => question.contains('purple')
      ? 'CARE: urgent\nA rash that doesn’t fade under a glass needs a doctor '
            'straight away.\n1. Call your local emergency number now.'
      : 'CARE: home\nA calm, predictable routine helps most.\n'
            '1. Keep the same steps every night.\n'
            '2. Start winding down half an hour before bed.';

  late final http.Client client = MockClient.streaming((request, body) async {
    final json = jsonDecode(await body.bytesToString()) as Map<String, dynamic>;
    if (json['stream'] != true) {
      reviews.add(json);
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode({
              'choices': [
                {
                  'message': {'role': 'assistant', 'content': review},
                },
              ],
            }),
          ),
        ),
        200,
      );
    }
    requests.add(json);
    if (failures.isNotEmpty) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('{"error":{"message":"no"}}')),
        failures.removeAt(0),
      );
    }
    final messages = json['messages'] as List;
    final question = (messages.last as Map)['content'] as String;
    return http.StreamedResponse(sse(answerFor(question)), 200);
  });
}

/// [answer] as server-sent events, a few characters to an event.
Stream<List<int>> sse(String answer) => Stream.fromIterable([
  for (final piece in RegExp(r'.{1,10}', dotAll: true).allMatches(answer))
    utf8.encode(
      'data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': piece[0]},
          },
        ],
      })}\n\n',
    ),
  utf8.encode('data: [DONE]\n\n'),
]);
