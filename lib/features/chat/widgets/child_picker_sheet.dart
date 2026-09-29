import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/data/app_scope.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/child_profile.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sheet_depth.dart';
import '../../../core/widgets/child_monogram.dart';

/// Asks who a question is about. Resolves to the choice, where a null
/// `child` means a general question; resolves to null if dismissed.
///
/// It resolves once the sheet has finished leaving, so the page's own
/// change of child (headline, panel, leaves) plays on a still page instead
/// of on top of the sheet's exit and the page coming forward.
Future<({ChildProfile? child})?> pickChild(
  BuildContext context, {
  required ChildProfile? current,
}) async {
  final choice = await _showPicker(context, current: current);
  if (choice != null) await Future<void>.delayed(AppMotion.sheetOut);
  return choice;
}

Future<({ChildProfile? child})?> _showPicker(
  BuildContext context, {
  required ChildProfile? current,
}) {
  final children = AppScope.of(context, listen: false).children;
  return showAppSheet<({ChildProfile? child})>(
    context,
    builder: (context) => ShadSheet(
      draggable: true,
      title: Text(context.tr('Who is this about?')),
      description: Text(context.tr('Mother AI uses their age as context.')),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, child) in children.indexed)
                _ChoiceRow(
                  child: child,
                  title: child.name,
                  subtitle: context.tr('{age} · born {date}', {
                    'age': context.l10n.age(child),
                    'date': context.l10n.date(child.birthday),
                  }),
                  selected: current?.id == child.id,
                ).cascadeIn(context, i),
              _ChoiceRow(
                child: null,
                title: context.tr('Nobody in particular'),
                subtitle: context.tr('A general parenting question'),
                selected: current == null,
              ).cascadeIn(context, children.length),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.child,
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final ChildProfile? child;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop((child: child));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              ChildMonogram(child: child, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.rowTitle),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.secondary.copyWith(
                        fontFeatures: AppFonts.tabular,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: const Icon(
                  LucideIcons.check,
                  size: 20,
                  color: AppColors.voice,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
