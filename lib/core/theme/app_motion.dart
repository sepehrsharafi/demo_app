import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_theme.dart';

/// The app's motion curves and its one opt-out.
abstract final class AppMotion {
  /// Exponential ease-out: quick off the mark, long settle, no overshoot.
  static const settle = Cubic(0.16, 1, 0.3, 1);

  /// Eases in and out with a soft overshoot at the end, like something light
  /// set down on a cushion. Only for things that arrive, such as toasts.
  static const cushion = Cubic(0.34, 1.32, 0.64, 1);

  /// How long a sheet takes to rise. The page behind it steps back over the
  /// same time, since both run off the sheet's route.
  static const sheetIn = Duration(milliseconds: 520);
  static const sheetOut = Duration(milliseconds: 260);
}

/// Fades [child] in or out over a solid [ground] by painting a veil of the
/// ground's colour on top of it, rather than an opacity layer.
///
/// Where the background behind a widget is one flat colour the two look the
/// same, but an opacity layer renders the widget into a texture of its own
/// every frame, which is what makes staggered rows stutter on low-end GPUs.
/// The veil is a single rectangle.
class GroundVeil extends StatelessWidget {
  const GroundVeil({
    super.key,
    required this.visible,
    required this.child,
    this.ground = AppColors.ground,
  });

  /// 0 hides [child] completely, 1 shows it as it is.
  final double visible;
  final Color ground;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cover = 1 - visible.clamp(0.0, 1.0);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: cover == 0
          ? const BoxDecoration()
          : BoxDecoration(color: ground.withValues(alpha: cover)),
      child: child,
    );
  }
}

extension VeilEffect on Animate {
  /// flutter_animate's `fadeIn`, drawn as a [GroundVeil]. Use it only where
  /// the widget sits on the plain ground (sheets, chat, lists).
  Animate veilIn({
    Duration? delay,
    Duration? duration,
    Curve? curve,
    Color ground = AppColors.ground,
  }) => custom(
    delay: delay,
    duration: duration,
    curve: curve,
    begin: 0,
    end: 1,
    builder: (context, value, child) =>
        GroundVeil(visible: value, ground: ground, child: child),
  );
}

extension MaybeAnimate on Widget {
  /// Applies [effects] unless the person has asked for reduced motion.
  Widget maybeAnimate(BuildContext context, Widget Function(Widget) effects) =>
      MediaQuery.disableAnimationsOf(context) ? this : effects(this);

  /// The rows of a sheet arriving one after another as it rises, [order]
  /// counting from the top. Each is visible and in place by ~0.6s.
  ///
  /// Inside a sheet every row runs off the sheet's one [CascadeClock]
  /// rather than an animation of its own: a language list is seven rows,
  /// and seven tickers and controllers set up on the sheet's first frame
  /// were part of what made it catch on a slow phone.
  Widget cascadeIn(BuildContext context, int order) {
    if (MediaQuery.disableAnimationsOf(context)) return this;
    final clock = CascadeClock.maybeOf(context);
    if (clock != null) {
      return _CascadeRow(clock: clock, order: order, child: this);
    }
    return animate(delay: _Cascade.delay(order).ms)
        .veilIn(duration: _Cascade.veil.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: _Cascade.rise,
          end: 0,
          duration: _Cascade.slide.ms,
          curve: AppMotion.settle,
        );
  }
}

/// The cascade's timing, in milliseconds.
abstract final class _Cascade {
  static int delay(int order) => 110 + 45 * order;
  static const veil = 240;
  static const slide = 460;

  /// How far below its place a row starts, in its own heights.
  static const rise = 0.45;
}

/// The one clock the rows of a sheet cascade in on (see
/// [MaybeAnimate.cascadeIn]), counting milliseconds from the sheet's first
/// frame. `SheetRise` provides it.
class CascadeClock extends InheritedWidget {
  const CascadeClock({super.key, required this.elapsed, required super.child});

  /// Milliseconds since the sheet appeared, up to [length].
  final Animation<double> elapsed;

  /// Long enough for fourteen rows to finish; any later row is shown in
  /// place once the clock stops.
  static const length = Duration(milliseconds: 1200);

  static Animation<double>? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<CascadeClock>()?.elapsed;

  @override
  bool updateShouldNotify(CascadeClock old) => elapsed != old.elapsed;
}

class _CascadeRow extends StatelessWidget {
  const _CascadeRow({
    required this.clock,
    required this.order,
    required this.child,
  });

  final Animation<double> clock;
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = _Cascade.delay(order);
    return AnimatedBuilder(
      animation: clock,
      child: child,
      builder: (context, child) {
        final done = clock.isCompleted;
        final ms = clock.value - start;
        final veil = done ? 1.0 : (ms / _Cascade.veil).clamp(0.0, 1.0);
        final slide = done ? 1.0 : (ms / _Cascade.slide).clamp(0.0, 1.0);
        // The same two widgets at every step, so the row is never rebuilt
        // from scratch when it settles.
        return FractionalTranslation(
          translation: Offset(
            0,
            _Cascade.rise * (1 - AppMotion.settle.transform(slide)),
          ),
          child: GroundVeil(
            visible: Curves.easeOutCubic.transform(veil),
            child: child!,
          ),
        );
      },
    );
  }
}
