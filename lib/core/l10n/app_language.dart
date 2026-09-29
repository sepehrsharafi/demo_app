import 'package:flutter/widgets.dart';

/// The languages the app speaks. Choosing one changes the words on every
/// screen, the direction they run in, and the language Mother AI answers in.
enum AppLanguage {
  en('en', 'English'),
  fa('fa', 'فارسی', rightToLeft: true),
  hi('hi', 'हिन्दी'),
  es('es', 'Español'),
  ar('ar', 'العربية', rightToLeft: true),
  tr('tr', 'Türkçe'),
  zh('zh', '中文');

  const AppLanguage(this.code, this.nativeName, {this.rightToLeft = false});

  /// The ISO 639-1 code, which is also what is stored.
  final String code;

  /// The language named in itself, so a parent can find their own.
  final String nativeName;

  /// Arabic and Persian run from right to left.
  final bool rightToLeft;

  Locale get locale => Locale(code);

  TextDirection get direction =>
      rightToLeft ? TextDirection.rtl : TextDirection.ltr;

  /// Whether letters are drawn joined to one another. Spacing them out, as
  /// the tight headings of the Latin type scale do, would pull the joins
  /// apart.
  bool get joinedScript => this == fa || this == ar;

  /// Whether the type scale's Latin proportions hold. Scripts with marks
  /// above and below the line, or with square characters, need more room
  /// between lines.
  bool get latinScript => this == en || this == es || this == tr;

  static AppLanguage? fromCode(String? code) =>
      values.where((language) => language.code == code).firstOrNull;

  /// The plural form a count takes in this language: `zero`, `one`, `two`,
  /// `few`, `many` or `other`.
  String pluralCategory(int n) {
    switch (this) {
      case en || es || tr:
        return n == 1 ? 'one' : 'other';
      case fa || hi:
        return n == 0 || n == 1 ? 'one' : 'other';
      case zh:
        return 'other';
      case ar:
        if (n == 0) return 'zero';
        if (n == 1) return 'one';
        if (n == 2) return 'two';
        final last = n % 100;
        if (last >= 3 && last <= 10) return 'few';
        if (last >= 11) return 'many';
        return 'other';
    }
  }
}
