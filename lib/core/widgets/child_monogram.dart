import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/child_profile.dart';
import '../theme/app_theme.dart';

/// A child's initial on their own colour. With no child it stands for a
/// general question that isn't about anyone in particular.
class ChildMonogram extends StatelessWidget {
  const ChildMonogram({super.key, required this.child, this.size = 36});

  final ChildProfile? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: child?.hueTint ?? AppColors.panel,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: child == null
                ? Icon(
                    LucideIcons.usersRound,
                    size: size * 0.44,
                    color: AppColors.muted,
                  )
                : Text(
                    child.initial,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      color: child.hue,
                      fontSize: size * 0.46,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
