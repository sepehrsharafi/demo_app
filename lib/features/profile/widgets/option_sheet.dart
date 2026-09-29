import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/l10n/text_direction.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sheet_depth.dart';

/// Asks the parent to choose one of [options] (each a value and its label).
/// Resolves to the choice once the sheet has left, so the page changes on a
/// still screen; null if dismissed.
Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  String? description,
  required List<(T, String)> options,
  required T selected,
}) async {
  final choice = await showAppSheet<T>(
    context,
    builder: (context) => ShadSheet(
      draggable: true,
      scrollable: true,
      isScrollControlled: true,
      // A long list scrolls inside the sheet rather than pushing it up to
      // the status bar: the page keeps showing above it.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      title: Text(title),
      description: description == null ? null : Text(description),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, (value, label)) in options.indexed)
                _OptionRow(
                  label: label,
                  selected: value == selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(value);
                  },
                ).cascadeIn(context, i),
            ],
          ),
        ),
      ),
    ),
  );
  if (choice != null) await Future<void>.delayed(AppMotion.sheetOut);
  return choice;
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// A label in Arabic or Persian (a language named in itself) is set in
  /// Vazirmatn, the face the app uses for both, rather than whatever the
  /// phone falls back to: it matches, and it is bundled, so it's already
  /// loaded when the sheet rises.
  TextStyle _style(TextDirection direction) {
    final style = AppText.rowTitle;
    if (direction == TextDirection.ltr) return style;
    return TextStyle(
      fontFamily: AppFonts.arabic,
      color: style.color,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      height: 1.3,
    );
  }

  @override
  Widget build(BuildContext context) {
    final direction = directionOfText(label);
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: _style(direction))),
              if (selected)
                const Icon(LucideIcons.check, size: 20, color: AppColors.voice),
            ],
          ),
        ),
      ),
    );
  }
}
