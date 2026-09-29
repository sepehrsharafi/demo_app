import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/app_motion.dart';

/// A word that changes by rolling. The old letters lift out of the line one
/// after another, the new ones rise in from below behind them and settle
/// with a little give, and the width eases from one word to the next so
/// whatever follows slides along.
///
/// Letters are painted, not laid out as widgets, and leave through the top
/// of the line rather than fading. So the change costs no opacity layers and
/// no relayout of the text around it. Under reduced motion it simply swaps.
class RollingText extends StatefulWidget {
  const RollingText(
    this.text, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final String text;

  /// Its colour is part of the change: new letters arrive in the new colour.
  final TextStyle style;
  final Duration duration;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  _Word? _to;
  _Word? _from;
  TextScaler? _scaler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scaler = MediaQuery.textScalerOf(context);
    if (scaler != _scaler) {
      _scaler = scaler;
      _to?.dispose();
      _to = _Word(widget.text, widget.style, scaler);
      _from?.dispose();
      _from = null;
    }
  }

  @override
  void didUpdateWidget(covariant RollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text == oldWidget.text) {
      // The same word set differently (the app changed language, so its type
      // settings did) is drawn afresh, not rolled.
      if (widget.style != oldWidget.style) {
        _to?.dispose();
        _to = _Word(widget.text, widget.style, _scaler!);
        _from?.dispose();
        _from = null;
        _controller.value = 1;
      }
      return;
    }
    _from?.dispose();
    _from = _to;
    _to = _Word(widget.text, widget.style, _scaler!);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _to?.dispose();
    _from?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final to = _to!;
    return Semantics(
      label: widget.text,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final from = t < 1 ? _from : null;
          final width = from == null
              ? to.width
              : from.width +
                    (to.width - from.width) *
                        const Interval(
                          0.08,
                          0.75,
                          curve: AppMotion.settle,
                        ).transform(t);
          return SizedBox(
            width: width,
            height: to.height,
            child: CustomPaint(
              painter: _RollPainter(from: from, to: to, t: t),
            ),
          );
        },
      ),
    );
  }
}

/// Scripts whose letters change shape with their neighbours or combine into
/// clusters (Arabic and Persian, Hindi and its relatives). Cut into single
/// letters they stop joining, so such a word is rolled as one piece.
final _shaped = RegExp(r'[֐-෿יִ-﷿ﹰ-﻿]');

/// Arabic and Persian read from right to left.
final _rightToLeft = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');

/// One word laid out once: the whole line for spacing, and each letter on
/// its own so it can move by itself.
class _Word {
  _Word(this.text, TextStyle style, TextScaler scaler) {
    final direction = _rightToLeft.hasMatch(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
    final line = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    width = line.width;
    height = line.height;
    if (_shaped.hasMatch(text)) {
      letters.add((
        0,
        TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout(),
      ));
      line.dispose();
      return;
    }
    var offset = 0;
    for (final char in text.characters) {
      final x = line
          .getOffsetForCaret(TextPosition(offset: offset), Rect.zero)
          .dx;
      offset += char.length;
      letters.add((
        x,
        TextPainter(
          text: TextSpan(text: char, style: style),
          textDirection: direction,
          textScaler: scaler,
        )..layout(),
      ));
    }
    line.dispose();
  }

  final String text;
  late final double width;
  late final double height;
  final letters = <(double, TextPainter)>[];

  void dispose() {
    for (final (_, painter) in letters) {
      painter.dispose();
    }
  }
}

class _RollPainter extends CustomPainter {
  _RollPainter({required this.from, required this.to, required this.t});

  final _Word? from;
  final _Word to;
  final double t;

  /// How far apart letters start, as a share of the whole change. Long words
  /// close up so the last letter still has time to land.
  static double _stagger(int count) =>
      count <= 1 ? 0 : math.min(0.05, 0.3 / (count - 1));

  @override
  void paint(Canvas canvas, Size size) {
    final from = this.from;
    if (from == null) {
      for (final (x, letter) in to.letters) {
        letter.paint(canvas, Offset(x, 0));
      }
      return;
    }
    final travel = size.height;
    // The line is a window: letters leave through its top edge and arrive
    // through its bottom, so nothing crosses into the line above. The
    // overshoot on landing stays well inside, since glyphs sit below the
    // top of their line box.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(-8, 0, size.width + 16, size.height + 6));

    final out = _stagger(from.letters.length);
    for (final (i, (x, letter)) in from.letters.indexed) {
      final p = ((t - i * out) / 0.34).clamp(0.0, 1.0);
      if (p >= 1) continue;
      final lift = Curves.easeInCubic.transform(p);
      letter.paint(canvas, Offset(x, -travel * lift));
    }

    final inn = _stagger(to.letters.length);
    for (final (i, (x, letter)) in to.letters.indexed) {
      final p = ((t - 0.16 - i * inn) / 0.52).clamp(0.0, 1.0);
      if (p <= 0) continue;
      final rise = AppMotion.cushion.transform(p);
      final y = travel * (1 - rise);
      // Each letter tips back upright as it lands.
      final tilt = 0.22 * (1 - Curves.easeOut.transform(p));
      canvas.save();
      canvas.translate(x, y + letter.height);
      canvas.rotate(tilt);
      canvas.translate(0, -letter.height);
      letter.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RollPainter old) =>
      old.t != t || old.from != from || old.to != to;
}
