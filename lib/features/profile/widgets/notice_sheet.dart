import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sheet_depth.dart';

/// Tells the parent something they should read, in the same bottom sheet the
/// language and unit choices use: [paragraphs] under a [title], and one way
/// to close it.
Future<void> showNoticeSheet(
  BuildContext context, {
  required String title,
  required List<String> paragraphs,
}) {
  return showAppSheet<void>(
    context,
    builder: (context) => ShadSheet(
      draggable: true,
      scrollable: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      title: Text(title),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, paragraph) in paragraphs.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    paragraph,
                    style: AppText.body.copyWith(fontSize: 15.5, height: 1.5),
                  ),
                ).cascadeIn(context, i),
              const SizedBox(height: 10),
              ShadButton(
                size: ShadButtonSize.lg,
                textStyle: AppText.button,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.tr('Got it')),
              ).cascadeIn(context, paragraphs.length),
            ],
          ),
        ),
      ),
    ),
  );
}
