import 'dart:io';

import 'package:demo_app/core/l10n/l10n.dart';
import 'package:demo_app/core/l10n/strings_en.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/l10n_keys.dart';

/// The plural forms each language's counts need.
const _forms = {
  AppLanguage.en: ['one', 'other'],
  AppLanguage.es: ['one', 'other'],
  AppLanguage.tr: ['one', 'other'],
  AppLanguage.fa: ['one', 'other'],
  AppLanguage.hi: ['one', 'other'],
  AppLanguage.zh: ['other'],
  AppLanguage.ar: ['zero', 'one', 'two', 'few', 'many', 'other'],
};

const _plurals = ['age.year', 'age.month', 'age.week', 'age.day'];

Set<String> _blanks(String text) => {
  for (final match in RegExp(r'\{(\w+)\}').allMatches(text)) match.group(1)!,
};

void main() {
  final sentences = sentencesInSource(Directory('lib'));
  final calendar = {
    for (final key in stringsEn.keys)
      if (!key.contains('#')) key,
  };
  final pluralKeys = {
    for (final base in _plurals)
      for (final form in ['zero', 'one', 'two', 'few', 'many', 'other'])
        '$base#$form',
  };

  test('the source has sentences to translate', () {
    expect(sentences.length, greaterThan(150));
  });

  for (final language in AppLanguage.values.where((l) => l != AppLanguage.en)) {
    group(language.code, () {
      final table = L10n.tableOf(language);

      test('has every sentence the app says', () {
        final missing = sentences.where((key) => !table.containsKey(key));
        expect(
          missing,
          isEmpty,
          reason: 'Not translated:\n${missing.join('\n')}',
        );
      });

      test('has the calendar and every form of every age', () {
        final missing = [
          ...calendar.where((key) => !table.containsKey(key)),
          for (final base in _plurals)
            for (final form in _forms[language]!)
              if (!table.containsKey('$base#$form')) '$base#$form',
        ];
        expect(missing, isEmpty, reason: 'Missing:\n${missing.join('\n')}');
      });

      test('says nothing the app does not', () {
        final extra = table.keys.where(
          (key) =>
              !sentences.contains(key) &&
              !calendar.contains(key) &&
              !pluralKeys.contains(key),
        );
        expect(extra, isEmpty, reason: 'Not in the app:\n${extra.join('\n')}');
      });

      test('leaves no word empty and keeps every {blank}', () {
        final wrong = <String>[];
        for (final MapEntry(:key, :value) in table.entries) {
          if (value.trim().isEmpty) wrong.add('$key: empty');
          if (pluralKeys.contains(key)) {
            // Forms for one, two or none may say the number in words.
            final form = key.split('#').last;
            final needsNumber = !{'zero', 'one', 'two'}.contains(form);
            if (needsNumber && !_blanks(value).contains('n')) {
              wrong.add('$key: no {n}');
            }
            continue;
          }
          final expected = _blanks(stringsEn[key] ?? key);
          if (!_blanks(value).containsAll(expected) ||
              !expected.containsAll(_blanks(value))) {
            wrong.add('$key: blanks $expected became ${_blanks(value)}');
          }
        }
        expect(wrong, isEmpty, reason: wrong.join('\n'));
      });

      test('keeps a name last in the two headlines', () {
        for (final key in [
          'What’s on your mind\nabout {name}?',
          'Ask me anything\nabout {name}.',
        ]) {
          final lines = table[key]!.split('\n');
          expect(lines.last, contains('{name}'), reason: key);
          expect(lines.length, lessThanOrEqualTo(2), reason: key);
        }
      });
    });
  }
}
