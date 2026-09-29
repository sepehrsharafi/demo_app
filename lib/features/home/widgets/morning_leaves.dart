import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../core/theme/app_theme.dart';

/// A sprig of leaves reaching in from the edge of Home's lavender morning.
///
/// They move when something happens and come to rest after it:
///  * they sway in as Home appears,
///  * they lean in and breathe while the composer has focus, as if Mother
///    AI is listening, and rustle on each keystroke,
///  * a change of child re-tints them toward that child's hue.
/// Then they settle and the ticker stops, so an idle Home costs nothing.
/// Under reduced motion they hold still.
class MorningLeaves extends StatefulWidget {
  const MorningLeaves({
    super.key,
    required this.hue,
    required this.listening,
    required this.typing,
  });

  /// The child's hue, blended lightly into the leaves.
  final Color hue;

  /// Whether the composer has focus.
  final bool listening;

  /// Notifies on every keystroke.
  final Listenable typing;

  @override
  State<MorningLeaves> createState() => _MorningLeavesState();
}

class _MorningLeavesState extends State<MorningLeaves>
    with SingleTickerProviderStateMixin {
  // Long enough to read as a change of light rather than a switch.
  static const _hueChange = 1.4;

  late final Ticker _ticker = createTicker(_tick);
  final _frame = ValueNotifier<int>(0);

  Duration _last = Duration.zero;
  double _clock = 0;

  /// How much the leaves are moving, 0 at rest.
  double _energy = 0;

  /// How far they lean toward the composer, 0 at rest.
  double _lean = 0;

  /// The leaves keep moving until this point on [_clock].
  double _awakeUntil = 0;

  late Color _from = widget.hue;
  late Color _to = widget.hue;
  double _hueT = 1;

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    widget.typing.addListener(_onTyping);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      _ticker.stop();
    } else if (_awakeUntil == 0) {
      _energy = 1;
      _wake(3.5);
    }
  }

  @override
  void didUpdateWidget(covariant MorningLeaves oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.typing != widget.typing) {
      oldWidget.typing.removeListener(_onTyping);
      widget.typing.addListener(_onTyping);
    }
    if (widget.listening != oldWidget.listening) _wake(2.5);
    if (widget.hue != _to) {
      _from = _currentHue;
      _to = widget.hue;
      if (_still) {
        _hueT = 1;
        _frame.value++;
      } else {
        _hueT = 0;
        _energy = math.max(_energy, 0.8);
        _wake(3.5);
      }
    }
  }

  void _onTyping() {
    if (_still) return;
    _energy = math.min(1, _energy + 0.35);
    _wake(1.4);
  }

  void _wake(double seconds) {
    if (_still) return;
    _awakeUntil = math.max(_awakeUntil, _clock + seconds);
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _clock += dt;

    final awake = _clock < _awakeUntil;
    final energyTarget = !awake
        ? 0.0
        : widget.listening
        ? 0.7
        : 0.4;
    // Both ease toward their targets, so the leaves glide rather than jump.
    _energy += (energyTarget - _energy) * math.min(1, dt * (awake ? 1.6 : 1.1));
    final leanTarget = awake && widget.listening ? 1.0 : 0.0;
    _lean += (leanTarget - _lean) * math.min(1, dt * 2.2);
    if (_hueT < 1) _hueT = math.min(1, _hueT + dt / _hueChange);
    _frame.value++;

    final settled = !awake && _energy < 0.004 && _lean < 0.004 && _hueT >= 1;
    if (settled) {
      _energy = 0;
      _lean = 0;
      _ticker.stop();
    }
  }

  Color get _currentHue =>
      Color.lerp(_from, _to, Curves.easeInOutCubic.transform(_hueT))!;

  @override
  void dispose() {
    widget.typing.removeListener(_onTyping);
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _LeavesPainter(state: this, repaint: _frame),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One leaf of the sprig: where it grows from on the stem (as a fraction of
/// the stem), which way it points, and its size.
class _Leaf {
  const _Leaf(this.along, this.angle, this.length, this.width, this.phase);

  final double along;
  final double angle;
  final double length;
  final double width;
  final double phase;
}

class _LeavesPainter extends CustomPainter {
  _LeavesPainter({required this.state, required Listenable repaint})
    : super(repaint: repaint);

  final _MorningLeavesState state;

  /// Angles in radians, 0 pointing right, negative pointing up.
  static const _leaves = [
    _Leaf(0.18, -2.55, 118, 44, 0.0),
    _Leaf(0.34, -1.35, 104, 38, 1.7),
    _Leaf(0.50, -2.95, 132, 48, 3.1),
    _Leaf(0.66, -1.70, 120, 42, 4.4),
    _Leaf(0.84, -2.30, 150, 54, 5.6),
    _Leaf(1.00, -1.95, 96, 36, 2.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final hue = state._currentHue;
    final light = Color.lerp(AppColors.leaf, hue, 0.06)!;
    final deep = Color.lerp(const Color(0xFFDDD0F6), hue, 0.08)!;
    final t = state._clock;
    final energy = state._energy;
    final lean = Curves.easeInOut.transform(state._lean.clamp(0, 1));

    // The stem rises from beyond the trailing edge, low on the field, and
    // curls up and in toward the top.
    final w = size.width;
    final start = Offset(w + 30, size.height * 0.62);
    final c1 = Offset(w - 30, size.height * 0.40);
    final c2 = Offset(w - 40, size.height * 0.16);
    final end = Offset(w - 118, -8);

    Offset stemAt(double u) {
      final a = 1 - u;
      return start * (a * a * a) +
          c1 * (3 * a * a * u) +
          c2 * (3 * a * u * u) +
          end * (u * u * u);
    }

    // The whole sprig bends a little toward the composer while listening.
    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(-0.05 * lean);
    canvas.translate(-start.dx, -start.dy);

    final stem = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = deep,
    );

    final vein = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.ground.withValues(alpha: 0.75);

    for (final (i, leaf) in _leaves.indexed) {
      final base = stemAt(leaf.along);
      final sway = energy * 0.10 * math.sin(t * 2.1 + leaf.phase) - 0.06 * lean;
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(leaf.angle + sway);
      canvas.drawPath(
        _leafPath(leaf.length, leaf.width),
        Paint()..color = i.isEven ? light : deep,
      );
      canvas.drawLine(Offset(6, 0), Offset(leaf.length * 0.86, 0), vein);
      canvas.restore();
    }
    canvas.restore();
  }

  /// A leaf lying along the x axis from its base at the origin to its tip,
  /// fuller toward the base, as a real leaf is.
  static Path _leafPath(double length, double width) {
    final half = width / 2;
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(length * 0.18, -half * 1.15, length * 0.62, -half, length, 0)
      ..cubicTo(length * 0.62, half, length * 0.18, half * 1.15, 0, 0)
      ..close();
  }

  @override
  bool shouldRepaint(_LeavesPainter old) => false;
}
