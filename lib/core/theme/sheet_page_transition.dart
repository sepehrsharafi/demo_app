import 'package:flutter/material.dart';

import 'app_motion.dart';

/// Pushed screens arrive as a weighted sheet laid over the page: fast off
/// the mark, then a long settle, while the page underneath drifts back a
/// little. iOS keeps its native push (see `AppTheme.material`) so the
/// edge-swipe gesture still works.
///
/// Going back is the same movement played the other way, at the same pace: a
/// screen leaves as quickly as it arrived (see [AppMotion.settle] and its
/// mirror). The back button, the system back button and the system back
/// gesture all pop the route and so all play this one motion. The screen is
/// deliberately not dragged along by a swipe: a gesture that steered the
/// screen itself played a different, slower motion from the button's.
class SheetPageTransitionsBuilder extends PageTransitionsBuilder {
  const SheetPageTransitionsBuilder();

  /// Arriving and leaving take the same time.
  static const duration = Duration(milliseconds: 340);

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    return _SheetTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      textDirection: Directionality.of(context),
      child: child,
    );
  }
}

class _SheetTransition extends StatelessWidget {
  const _SheetTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.textDirection,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final TextDirection textDirection;
  final Widget child;

  /// The same curve both ways, mirrored on the way out: whatever the screen
  /// did in its first tenth of the time coming in, it does in its first tenth
  /// going out.
  static final _curve = (
    forward: AppMotion.settle,
    reverse: AppMotion.settle.flipped,
  );

  @override
  Widget build(BuildContext context) {
    // Screens arrive from the side the language reads towards: the slides
    // below are measured from the leading edge.
    final side = textDirection == TextDirection.rtl ? -1.0 : 1.0;
    final incoming = Tween(begin: const Offset(1, 0), end: Offset.zero);
    final outgoing = Tween(begin: Offset.zero, end: const Offset(-0.24, 0));

    Animation<double> eased(Animation<double> parent) => CurvedAnimation(
      parent: parent,
      curve: _curve.forward,
      reverseCurve: _curve.reverse,
    );

    return SlideTransition(
      textDirection: textDirection,
      position: outgoing.animate(eased(secondaryAnimation)),
      child: SlideTransition(
        textDirection: textDirection,
        position: incoming.animate(eased(animation)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A1F1B3D),
                blurRadius: 24,
                offset: Offset(-6 * side, 0),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
