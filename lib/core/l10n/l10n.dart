import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/child_profile.dart';
import 'app_language.dart';
import 'strings_ar.dart';
import 'strings_en.dart';
import 'strings_es.dart';
import 'strings_fa.dart';
import 'strings_hi.dart';
import 'strings_tr.dart';
import 'strings_zh.dart';

export 'app_language.dart';

/// The app's words in one language.
///
/// The app is written in English, and an English sentence is its own key:
/// `context.tr('Add a child')` finds that sentence in the language's table
/// and, where there is none, says it as written. A sentence with something
/// in it takes named blanks: `context.tr('Ask about {name}', {'name': n})`.
///
/// `test/l10n_test.dart` checks that every sentence the app says is in every
/// table, so a missing one is a failing test and never a screen half in
/// English.
class L10n {
  const L10n._(this.language, this._table);

  final AppLanguage language;
  final Map<String, String> _table;

  static const _tables = <AppLanguage, Map<String, String>>{
    AppLanguage.en: stringsEn,
    AppLanguage.fa: stringsFa,
    AppLanguage.hi: stringsHi,
    AppLanguage.es: stringsEs,
    AppLanguage.ar: stringsAr,
    AppLanguage.tr: stringsTr,
    AppLanguage.zh: stringsZh,
  };

  static final _cache = <AppLanguage, L10n>{};

  static L10n forLanguage(AppLanguage language) =>
      _cache.putIfAbsent(language, () => L10n._(language, _tables[language]!));

  /// The table of a language, for tests.
  @visibleForTesting
  static Map<String, String> tableOf(AppLanguage language) =>
      _tables[language]!;

  /// The words for the language the app is in. Asking for them makes the
  /// widget rebuild when the language changes.
  static L10n of(BuildContext context) =>
      Localizations.of<L10n>(context, L10n) ?? forLanguage(AppLanguage.en);

  static const delegate = _L10nDelegate();

  TextDirection get direction => language.direction;

  /// [key] in this language, with each `{name}` in it filled from [args].
  String tr(String key, [Map<String, Object>? args]) {
    final text = _table[key] ?? stringsEn[key] ?? key;
    if (args == null) return text;
    return _fill(text, args);
  }

  /// The form of [key] that suits [n] (`key#one`, `key#other`, ...), with
  /// `{n}` and any [args] filled in.
  String plural(String key, int n, [Map<String, Object>? args]) {
    final category = language.pluralCategory(n);
    final text =
        _table['$key#$category'] ??
        _table['$key#other'] ??
        stringsEn['$key#${AppLanguage.en.pluralCategory(n)}'] ??
        key;
    return _fill(text, {'n': n, ...?args});
  }

  static String _fill(String text, Map<String, Object> args) {
    var filled = text;
    args.forEach((name, value) {
      filled = filled.replaceAll('{$name}', '$value');
    });
    return filled;
  }

  /// "6 months" for a sentence, "6 mo" where there is room for little.
  String age(ChildProfile child, {bool short = false}) {
    final (:n, :unit) = child.ageSpan;
    return short
        ? tr('age.${unit.name}.short', {'n': n})
        : plural('age.${unit.name}', n);
  }

  /// "14 Mar 2026".
  String date(DateTime date) => tr('date.full', {
    'd': date.day,
    'm': tr('month.${date.month}'),
    'y': date.year,
  });

  /// "14 Mar", for dates in the current year.
  String dayMonth(DateTime date) =>
      tr('date.dayMonth', {'d': date.day, 'm': tr('month.${date.month}')});
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLanguage.fromCode(locale.languageCode) != null;

  @override
  Future<L10n> load(Locale locale) => SynchronousFuture(
    L10n.forLanguage(
      AppLanguage.fromCode(locale.languageCode) ?? AppLanguage.en,
    ),
  );

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);

  /// See [L10n.tr].
  String tr(String key, [Map<String, Object>? args]) => l10n.tr(key, args);
}
