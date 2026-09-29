import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/data/app_scope.dart';
import '../../core/l10n/l10n.dart';
import '../../core/l10n/text_direction.dart';
import '../../core/models/child_profile.dart';
import '../../core/models/context_note.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sheet_depth.dart';
import '../../core/widgets/child_monogram.dart';
import '../chat/chat_page.dart';
import 'child_form_page.dart';

/// What Mother AI knows about one child, and a way to ask about them.
Future<void> showChildSheet(BuildContext context, ChildProfile child) {
  final navigator = Navigator.of(context);
  return showAppSheet<void>(
    context,
    builder: (context) => ShadSheet(
      draggable: true,
      scrollable: true,
      // Sized to its content rather than capped at 9/16 of the screen, which
      // cut the last fact off.
      isScrollControlled: true,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clear of the close button in the top corner.
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 48),
              child: Row(
                children: [
                  ChildMonogram(child: child, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.name, style: AppText.title),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('{age} · born {date}', {
                            'age': context.l10n.age(child),
                            'date': context.l10n.date(child.birthday),
                          }),
                          style: AppText.secondary.copyWith(
                            fontFeatures: AppFonts.tabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: AppColors.line),
            _Fact(
              label: context.tr('Allergies'),
              value: child.allergies,
            ).cascadeIn(context, 0),
            _Fact(
              label: context.tr('Conditions'),
              value: child.conditions,
            ).cascadeIn(context, 1),
            _Fact(
              label: context.tr('Medicines'),
              value: child.medications,
            ).cascadeIn(context, 2),
            _Fact(
              label: context.tr('Notes'),
              value: child.notes,
            ).cascadeIn(context, 3),
            const SizedBox(height: 28),
            _Context(child: child),
            const SizedBox(height: 14),
            Text(
              context.tr(
                'Mother AI keeps all of this in mind when you ask about '
                'them. Edit to change or remove anything.',
              ),
              style: AppText.secondary,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ShadButton.outline(
                  size: ShadButtonSize.lg,
                  textStyle: AppText.button,
                  leading: const Icon(LucideIcons.pencil, size: 17),
                  onPressed: () {
                    Navigator.of(context).pop();
                    editChild(navigator.context, child: child);
                  },
                  child: Text(context.tr('Edit')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ShadButton(
                    size: ShadButtonSize.lg,
                    textStyle: AppText.button,
                    leading: const Icon(LucideIcons.messageCircle, size: 18),
                    onPressed: () {
                      Navigator.of(context).pop();
                      navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatPage(selectedChild: child),
                        ),
                      );
                    },
                    child: Flexible(
                      child: Text(
                        context.tr('Ask about {name}', {'name': child.name}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// What Mother AI has picked up about the child from chats, newest first.
/// It reads the store itself, so a note arriving while the sheet is open
/// shows up in it.
class _Context extends StatelessWidget {
  const _Context({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    final notes = AppScope.of(context).contextOf(child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(context.tr('Context'), style: AppText.section),
        ).cascadeIn(context, 4),
        const SizedBox(height: 4),
        Text(
          context.tr(
            'What Mother AI has picked up from your chats, so it remembers '
            'between them.',
          ),
          style: AppText.secondary,
        ).cascadeIn(context, 4),
        const SizedBox(height: 6),
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.tr(
                'Nothing yet. What you tell Mother AI about {name} will show '
                'up here.',
                {'name': child.name},
              ),
              style: AppText.body.copyWith(
                fontSize: 15,
                color: AppColors.muted,
              ),
            ),
          ).cascadeIn(context, 5)
        else
          for (final (i, note) in notes.indexed)
            _NoteRow(
              note: note,
              divider: i > 0,
            ).cascadeIn(context, 5 + (i < 4 ? i : 4)),
      ],
    );
  }
}

/// One note in a child’s context: what was picked up, and when.
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, this.divider = true});

  final ContextNote note;

  /// A hairline above it; every note but the first has one.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.text,
              textDirection: directionOfText(note.text),
              style: AppText.body.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 3),
            Text(context.l10n.date(note.updatedAt), style: AppText.figure),
          ],
        ),
      ),
    );
  }
}

/// One thing Mother AI knows, label beside value, closed off by a hairline.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 108,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(label, style: AppText.secondary),
              ),
            ),
            Expanded(
              child: Text(
                value ?? context.tr('None recorded'),
                style: AppText.body.copyWith(
                  fontSize: 15,
                  color: value == null ? AppColors.muted : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
