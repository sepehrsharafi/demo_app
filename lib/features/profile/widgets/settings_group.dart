import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/directional_icons.dart';

/// A group of rows under a small heading: open, closed by full-width
/// hairlines, with inset hairlines between rows, like the lists in Chats.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.heading,
    required this.rows,
    this.dividerInset = 36,
  });

  final String? heading;
  final List<Widget> rows;

  /// Where the hairlines start: past the icon column by default.
  final double dividerInset;

  @override
  Widget build(BuildContext context) {
    final heading = this.heading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(heading, style: AppText.label),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.line),
        Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i != 0)
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: dividerInset),
                    child: const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.line,
                    ),
                  ),
                rows[i],
              ],
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.line),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.icon,
    this.leading,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String title;
  final IconData? icon;

  /// Replaces [icon] when a row needs something richer, like a monogram.
  final Widget? leading;
  final String? subtitle;

  /// The current setting, e.g. "English".
  final String? value;

  /// Replaces the chevron, e.g. with a switch.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ink = destructive ? const Color(0xFFD92D40) : AppColors.ink;
    final subtitle = this.subtitle;
    final value = this.value;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child:
                    leading ??
                    Icon(
                      icon,
                      size: 20,
                      color: destructive ? ink : AppColors.muted,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.body.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: AppText.secondary.copyWith(
                          fontSize: 13,
                          fontFeatures: AppFonts.tabular,
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 12),
                Text(value, style: AppText.secondary),
              ],
              const SizedBox(width: 8),
              trailing ??
                  (onTap == null
                      ? const SizedBox.shrink()
                      : Icon(
                          context.forwardChevron,
                          size: 18,
                          color: AppColors.muted,
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
