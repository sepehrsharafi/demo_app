import 'package:flutter/widgets.dart';

/// The way a piece of text the parent wrote (a question, a chat's title)
/// reads, whatever language the app is in: Arabic and Persian run right to
/// left, and an English question inside an Arabic app still reads left to
/// right, with its punctuation where it belongs.
TextDirection directionOfText(String text) {
  final letter = RegExp(r'\p{L}', unicode: true).firstMatch(text)?.group(0);
  return letter != null && _rightToLeft.hasMatch(letter)
      ? TextDirection.rtl
      : TextDirection.ltr;
}

final _rightToLeft = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');
