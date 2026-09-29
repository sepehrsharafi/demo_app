import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

/// Sheets and dialogs are layered over the page, so the page steps back as
/// one rises: it shrinks a little, rounds its corners and sits on ink, the
/// way a card lies under the one placed on top of it. It comes forward
/// again as the sheet leaves.
///
/// Every sheet and dialog is a [PopupRoute], so one navigator observer drives
/// this for all of them, off each route's own animation.
abstract final class SheetDepth {
  static final observer = _PopupObserver();

  /// The popups currently over the page, newest last.
  static final _open = <Animation<double>>[];
  static final _top = ValueNotifier<Animation<double>?>(null);
}

class _PopupObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! PopupRoute) return;
    final animation = route.animation;
    if (animation == null) return;
    SheetDepth._open.add(animation);
    SheetDepth._top.value = animation;

    void onStatus(AnimationStatus status) {
      if (status != AnimationStatus.dismissed) return;
      animation.removeStatusListener(onStatus);
      SheetDepth._open.remove(animation);
      SheetDepth._top.value = SheetDepth._open.lastOrNull;
    }

    animation.addStatusListener(onStatus);
  }

  /// A popup taken away without animating out (removeRoute or a
  /// replacement) never reaches `dismissed`, and would otherwise
  /// leave the page stepped back under a sheet that is no longer there.
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! PopupRoute) return;
    _forget(route.animation);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute is PopupRoute) _forget(oldRoute.animation);
  }

  static void _forget(Animation<double>? animation) {
    if (animation == null || !SheetDepth._open.remove(animation)) return;
    SheetDepth._top.value = SheetDepth._open.lastOrNull;
  }
}

/// Wraps a page so it steps back under any sheet or dialog.
class RecedeBehindSheets extends StatefulWidget {
  const RecedeBehindSheets({super.key, required this.child});

  final Widget child;

  @override
  State<RecedeBehindSheets> createState() => _RecedeBehindSheetsState();
}

class _RecedeBehindSheetsState extends State<RecedeBehindSheets> {
  CurvedAnimation? _depth;

  /// While the page is stepped back it is drawn from a snapshot. Scaling
  /// the live page would make the renderer lay its text out again at each
  /// new scale, every frame, which is what made sheets stutter on a slow
  /// phone. A snapshot scales as one picture. The page also holds still
  /// underneath (its tickers pause), so the snapshot is taken once.
  final _snapshot = SnapshotController();
  bool _receded = false;

  static const _scale = 0.06;
  static const _drop = 10.0;
  static const _corner = 28.0;
  static const _inkGround = BoxDecoration(color: AppColors.ink);

  @override
  void initState() {
    super.initState();
    SheetDepth._top.addListener(_follow);
    _depth = _curve(SheetDepth._top.value)?..addListener(_sync);
  }

  CurvedAnimation? _curve(Animation<double>? animation) => animation == null
      ? null
      : CurvedAnimation(
          parent: animation,
          curve: AppMotion.settle,
          reverseCurve: Curves.easeInCubic,
        );

  void _follow() {
    final animation = SheetDepth._top.value;
    if (animation == _depth?.parent) return;
    _depth?.removeListener(_sync);
    _depth?.dispose();
    setState(() => _depth = _curve(animation)?..addListener(_sync));
    _sync();
  }

  /// Snapshot and pause only while the page is actually stepped back.
  void _sync() {
    final receded = (_depth?.value ?? 0) > 0;
    if (receded == _receded) return;
    _snapshot.allowSnapshotting = receded;
    setState(() => _receded = receded);
  }

  @override
  void dispose() {
    SheetDepth._top.removeListener(_follow);
    _depth?.removeListener(_sync);
    _depth?.dispose();
    _snapshot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final depth = still ? null : _depth;
    // The same widgets at rest and in motion: swapping the wrapper in and out
    // would remount the page and lose what was typed or scrolled.
    return AnimatedBuilder(
      animation: depth ?? kAlwaysDismissedAnimation,
      child: RepaintBoundary(
        child: SnapshotWidget(
          controller: _snapshot,
          mode: SnapshotMode.permissive,
          child: TickerMode(enabled: !_receded, child: widget.child),
        ),
      ),
      builder: (context, child) {
        final t = depth?.value ?? 0;
        // The ink only shows once the page has stepped back, so at rest it
        // isn't painted at all: a full-screen fill under an opaque page is
        // pure overdraw, which low-end GPUs pay for on every frame.
        return DecoratedBox(
          decoration: t == 0 ? const BoxDecoration() : _inkGround,
          child: Transform.translate(
            offset: Offset(0, _drop * t),
            child: Transform.scale(
              scale: 1 - _scale * t,
              child: ClipRRect(
                clipBehavior: t == 0 ? Clip.none : Clip.antiAlias,
                borderRadius: BorderRadius.circular(_corner * t),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A sheet's rise, driven by its route's own animation: the same clock and
/// the same curve the page behind it steps back on, so the two move as one.
///
/// shadcn slides sheets with a flutter_animate controller of its own that
/// only starts after the sheet's first frame. On a slow phone that left the
/// page receding with nothing arriving yet, then the sheet catching up. The
/// theme gives shadcn silent effects of the same length (which is what
/// times the route), and every sheet wraps its content in this.
class SheetRise extends StatefulWidget {
  const SheetRise({super.key, required this.child});

  final Widget child;

  @override
  State<SheetRise> createState() => _SheetRiseState();
}

class _SheetRiseState extends State<SheetRise>
    with SingleTickerProviderStateMixin {
  CurvedAnimation? _rise;

  /// The clock the sheet's rows cascade in on, in milliseconds (see
  /// `cascadeIn`). One for the whole sheet, however many rows it has.
  late final _cascade = AnimationController(
    vsync: this,
    upperBound: CascadeClock.length.inMilliseconds.toDouble(),
    duration: CascadeClock.length,
  )..forward();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (route == null || route == _rise?.parent) return;
    _rise?.dispose();
    _rise = CurvedAnimation(
      parent: route,
      curve: AppMotion.settle,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _rise?.dispose();
    _cascade.dispose();
    super.dispose();
  }

  static final _travel = Tween(begin: const Offset(0, 1), end: Offset.zero);

  @override
  Widget build(BuildContext context) {
    final rise = _rise;
    final content = CascadeClock(elapsed: _cascade, child: widget.child);
    if (rise == null || MediaQuery.disableAnimationsOf(context)) {
      return content;
    }
    return SlideTransition(position: _travel.animate(rise), child: content);
  }
}

/// Opens a dialog the app's way: the theme's rounded, bouncing card, held
/// clear of the screen's edges, which shadcn's own layout doesn't do.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showShadDialog<T>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: builder(context),
    ),
  );
}

/// Opens a bottom sheet the app's way: over the scrim, rising with the page
/// stepping back behind it (see [SheetRise]).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showShadSheet<T>(
    context: context,
    side: ShadSheetSide.bottom,
    barrierColor: const Color(0x521F1B3D),
    builder: (context) => SheetRise(child: builder(context)),
  );
}
