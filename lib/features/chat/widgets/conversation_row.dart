import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/text_direction.dart';
import '../../../core/models/child_profile.dart';
import '../../../core/models/conversation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/care.dart';
import '../../../core/widgets/child_monogram.dart';

/// One past conversation: who it was about, what was asked, what Mother AI
/// said last, when, and the most serious care level it reached.
class ConversationRow extends StatelessWidget {
  const ConversationRow({
    super.key,
    required this.conversation,
    required this.child,
    required this.onTap,
    this.divider = false,
  });

  final Conversation conversation;

  /// Who it was about; null for a general question.
  final ChildProfile? child;
  final VoidCallback onTap;

  /// A hairline above the row, inset to the text so the monograms stay a
  /// clean column. Every row but a group's first carries one.
  final bool divider;

  static const _textInset = 54.0;

  @override
  Widget build(BuildContext context) {
    final care = conversation.care;
    final row = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChildMonogram(child: child, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title,
                    textDirection: directionOfText(conversation.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.rowTitle,
                  ),
                  if (conversation.preview.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      conversation.preview,
                      textDirection: directionOfText(conversation.preview),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.secondary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    conversation.time(context.l10n),
                    style: AppText.figure,
                  ),
                ),
                if (care != null) ...[
                  const SizedBox(height: 6),
                  CarePill(level: care),
                ],
              ],
            ),
          ],
        ),
      ),
    );
    if (!divider) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.only(start: _textInset),
          child: Divider(height: 1, thickness: 1, color: AppColors.line),
        ),
        row,
      ],
    );
  }
}
