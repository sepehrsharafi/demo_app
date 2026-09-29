import 'dart:convert';

import 'package:demo_app/core/ai/mother_ai.dart';
import 'package:demo_app/core/ai/system_prompt.dart';
import 'package:demo_app/core/models/care_level.dart';
import 'package:demo_app/core/models/child_profile.dart';
import 'package:demo_app/core/models/conversation.dart';
import 'package:demo_app/core/models/preferences.dart';
import 'package:demo_app/core/models/reply.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support.dart';

void main() {
  group('Reply.parse', () {
    test('reads the care level, the answer and the steps', () {
      final reply = Reply.parse(
        'CARE: gp\nEar pulling with a fever can be an infection.\n'
        '1. Call your GP today.\n2. Paracetamol can ease the pain.',
      );
      expect(reply.care, CareLevel.gp);
      expect(reply.text, 'Ear pulling with a fever can be an infection.');
      expect(reply.steps, [
        'Call your GP today.',
        'Paracetamol can ease the pain.',
      ]);
    });

    test('holds back what may still become the care line', () {
      for (final partial in ['C', 'CAR', 'CARE:', 'CARE: ho']) {
        final reply = Reply.parse(partial);
        expect(reply.isEmpty, isTrue, reason: partial);
      }
      expect(Reply.parse('Can').text, 'Can');
      expect(Reply.parse('CARE: home').care, CareLevel.home);
    });

    test('shows a step only once its words arrive', () {
      final reply = Reply.parse('CARE: home\nText.\n1. First.\n2');
      expect(reply.steps, ['First.']);
      expect(reply.text, 'Text.');
    });

    test('reads bullets, strips bold, and survives a missing care line', () {
      final reply = Reply.parse('**Rest** helps.\n- Nap when they nap.');
      expect(reply.care, isNull);
      expect(reply.text, 'Rest helps.');
      expect(reply.steps, ['Nap when they nap.']);
      expect(Reply.parse('CARE: none\nYou’re welcome.').care, isNull);
    });

    test('keeps a sentence that starts with a number as text', () {
      expect(
        Reply.parse('10 minutes is plenty.').text,
        '10 minutes is plenty.',
      );
    });
  });

  group('MotherAi', () {
    final question = [ChatMessage('Is 38°C a fever?', isMine: true)];

    MotherAi ai(MockClientStreamHandler handler) =>
        MotherAi(client: MockClient.streaming(handler), apiKey: 'key');

    test('streams the answer as it is written', () async {
      late Map<String, dynamic> sent;
      final pieces = await ai((request, body) async {
        sent = jsonDecode(await body.bytesToString()) as Map<String, dynamic>;
        expect(request.headers['Authorization'], 'Bearer key');
        return http.StreamedResponse(sse('CARE: home\nYes, mildly.'), 200);
      }).answer(history: question, context: 'Reply in English.').toList();

      expect(pieces.join(), 'CARE: home\nYes, mildly.');
      expect(pieces.length, greaterThan(1));
      expect(sent['reasoning_effort'], 'low');
      expect(sent['include_reasoning'], isFalse);
      final system = (sent['messages'] as List).first as Map;
      // The fixed prompt leads, so the provider can cache it.
      expect(system['content'], startsWith(systemPrompt));
      expect(system['content'], endsWith('Reply in English.'));
    });

    test('tries again when the service is busy', () async {
      var calls = 0;
      final answer = await ai((request, body) async {
        calls++;
        if (calls == 1) {
          return http.StreamedResponse(
            const Stream.empty(),
            429,
            headers: {'retry-after': '0'},
          );
        }
        return http.StreamedResponse(sse('CARE: none\nHello.'), 200);
      }).answer(history: question, context: '').join();

      expect(calls, 2);
      expect(answer, 'CARE: none\nHello.');
    });

    test('a blocked network is not blamed on the key', () async {
      final answer = ai(
        (request, body) async => http.StreamedResponse(
          Stream.value(utf8.encode('{"error":{"message":"Forbidden"}}')),
          403,
        ),
      ).answer(history: question, context: '');

      await expectLater(answer, emitsError(MotherAiException.blocked));
    });

    test('does not retry a refused key, and says so', () async {
      var calls = 0;
      final answer = ai((request, body) async {
        calls++;
        return http.StreamedResponse(const Stream.empty(), 401);
      }).answer(history: question, context: '');

      await expectLater(answer, emitsError(MotherAiException.refused));
      expect(calls, 1);
    });

    test('reports a dropped connection as being offline', () async {
      final answer = ai(
        (request, body) async =>
            throw http.ClientException('Failed host lookup'),
      ).answer(history: question, context: '');

      await expectLater(answer, emitsError(MotherAiException.offline));
    });

    test('needs an API key', () async {
      final answer = MotherAi(apiKey: '')
          .answer(history: question, context: '');
      await expectLater(answer, emitsError(MotherAiException.notConfigured));
    });

    test('an answer with no words is a failure', () async {
      final answer = ai(
        (request, body) async => http.StreamedResponse(sse(''), 200),
      ).answer(history: question, context: '');
      await expectLater(answer, emitsError(MotherAiException.silent));
    });

    test('sends only the latest history', () async {
      late List<dynamic> messages;
      final history = [
        for (var i = 0; i < 40; i++)
          ChatMessage('Message $i', isMine: i.isEven),
      ];
      await ai((request, body) async {
        final json = jsonDecode(await body.bytesToString()) as Map;
        messages = json['messages'] as List;
        return http.StreamedResponse(sse('CARE: none\nOk.'), 200);
      }).answer(history: history, context: '').drain<void>();

      expect(messages.length, 1 + 16);
      expect((messages.last as Map)['content'], 'Message 39');
    });
  });

  test('the context says only what is recorded about a child', () {
    final now = DateTime.now();
    final child = ChildProfile(
      id: 1,
      name: 'Emma',
      birthday: DateTime(now.year, now.month - 6, 1),
      hueIndex: 0,
      allergies: 'Peanuts',
    );
    final context = questionContext(
      child: child,
      topic: null,
      language: 'Deutsch',
      units: Units.metric,
    );
    expect(context, contains('Reply in Deutsch.'));
    expect(context, contains('Emma, 6 months old'));
    expect(context, contains('Allergies: Peanuts.'));
    expect(context, isNot(contains('Medicines')));
    expect(
      questionContext(
        child: null,
        topic: null,
        language: 'English',
        units: Units.imperial,
      ),
      contains('not about a particular child'),
    );
  });

  test('ages read the way parents say them', () {
    final now = DateTime.now();
    ChildProfile born(DateTime birthday) =>
        ChildProfile(id: 1, name: 'A', birthday: birthday, hueIndex: 0);

    expect(born(DateTime(now.year, now.month, now.day - 3)).age, '3 days');
    expect(born(DateTime(now.year, now.month, now.day - 15)).age, '2 weeks');
    expect(born(DateTime(now.year, now.month - 1, 1)).age, '1 month');
    expect(born(DateTime(now.year, now.month - 18, 1)).ageShort, '18 mo');
    expect(born(DateTime(now.year - 3, now.month, 1)).age, '3 years');
  });
}
