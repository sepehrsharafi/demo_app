import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/child_profile.dart';
import '../theme/app_motion.dart';
import 'child_monogram.dart';
import 'rolling_text.dart';

/// Who a question is about, as the control that changes it shows them.
/// Whenever the child changes the badge turns over into the new one, and the
/// name and age roll to theirs. Home's pill and a new chat's header both
/// show this, so choosing someone else moves the same way on both.
class ChildLabel extends StatelessWidget {
  const ChildLabel({
    super.key,
    required this.child,
    required this.badge,
    required this.gap,
    required this.name,
    required this.age,
    this.shortAge = false,
  });

  final ChildProfile? child;

  /// The badge's size.
  final double badge;

  /// The space between the badge and the name.
  final double gap;
  final TextStyle name;
  final TextStyle age;

  /// "6 mo" rather than "6 months", where there is little room.
  final bool shortAge;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchingMonogram(child: child, size: badge),
        SizedBox(width: gap),
        RollingText(
          child?.name ?? context.tr('General question'),
          style: name,
          duration: const Duration(milliseconds: 820),
        ),
        RollingText(
          child == null
              ? ''
              : '  ·  ${context.l10n.age(child, short: shortAge)}',
          style: age,
          duration: const Duration(milliseconds: 900),
        ),
      ],
    );
  }
}

/// A [ChildMonogram] that turns over into the next one when the child
/// changes: it shrinks away and the new one grows in on a small cushion.
class SwitchingMonogram extends StatelessWidget {
  const SwitchingMonogram({super.key, required this.child, required this.size});

  final ChildProfile? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 560),
        reverseDuration: const Duration(milliseconds: 240),
        switchInCurve: AppMotion.cushion,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (monogram, animation) => ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween(begin: -0.18, end: 0.0).animate(animation),
            child: monogram,
          ),
        ),
        child: ChildMonogram(
          key: ValueKey(child?.id),
          child: child,
          size: size,
        ),
      ),
    );
  }
}
