import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../models/care_level.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import 'demo_toast.dart';

/// The line at the top of an answer that says how much help is needed.
///
/// When [reveal] is set it wipes in from the leading edge in its own colour,
/// the moment an answer lands. Amber and red strips carry the next step as a
/// button.
class CareStrip extends StatelessWidget {
  const CareStrip({super.key, required this.level, this.reveal = false});

  final CareLevel level;
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    final strip = Semantics(
      container: true,
      label: context.tr('Care level: {level}', {
        'level': context.tr(level.label),
      }),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: level.tint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 28,
                      child: Icon(level.icon, size: 15, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        context.tr(level.label),
                        style: AppText.rowTitle.copyWith(
                          color: level.deep,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // The next step gets a full-width button, not a footnote.
              if (level.action case final action?) ...[
                const SizedBox(height: 8),
                ShadButton(
                  backgroundColor: level.deep,
                  hoverBackgroundColor: level.deep.withValues(alpha: 0.9),
                  pressedBackgroundColor: level.deep.withValues(alpha: 0.8),
                  leading: const Icon(LucideIcons.phone, size: 16),
                  onPressed: () => _openDialer(context),
                  child: Flexible(
                    child: Text(
                      context.tr(action),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ],
          ),
        ),
      ),
    );

    if (!reveal || MediaQuery.disableAnimationsOf(context)) return strip;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: AppMotion.settle,
      builder: (context, t, child) => ClipRect(
        clipper: _WipeClipper(t, Directionality.of(context)),
        child: child,
      ),
      child: strip,
    );
  }
}

/// Opens the phone's dialer. It is left empty: the parent knows their
/// doctor's number, and the emergency number depends on the country.
Future<void> _openDialer(BuildContext context) async {
  var opened = false;
  try {
    opened = await launchUrl(Uri(scheme: 'tel'));
  } catch (_) {}
  if (!opened && context.mounted) {
    showDemoToast(
      context,
      title: context.tr('The phone app didn’t open'),
      description: context.tr('Call from your phone app instead.'),
    );
  }
}

class _WipeClipper extends CustomClipper<Rect> {
  const _WipeClipper(this.progress, this.direction);

  final double progress;
  final TextDirection direction;

  @override
  Rect getClip(Size size) {
    final width = size.width * progress;
    return direction == TextDirection.ltr
        ? Rect.fromLTWH(0, 0, width, size.height)
        : Rect.fromLTWH(size.width - width, 0, width, size.height);
  }

  @override
  bool shouldReclip(_WipeClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.direction != direction;
}

/// A care level where there is only room for a word: conversation rows.
class CarePill extends StatelessWidget {
  const CarePill({super.key, required this.level});

  final CareLevel level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('Care level: {level}', {
        'level': context.tr(level.label),
      }),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: level.tint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(7, 3, 9, 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: level.color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 7),
                ),
                const SizedBox(width: 5),
                Text(
                  context.tr(level.short),
                  style: AppText.label.copyWith(
                    color: level.deep,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
