import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../l10n/l10n.dart';
import 'child_profile.dart';

/// What a question is about. A parent picks one to start from, then says
/// what is happening in their own words.
///
/// [label] is an English sentence, said in the app's language with `context.tr`.
///
/// Each topic carries one of the logo's soft hues: a [tint] for its icon
/// square and a [tone] for the icon. None of them is green, amber or red,
/// which belong to care levels.
enum AskTopic {
  health(
    'Health',
    LucideIcons.stethoscope,
    tint: Color(0xFFFCE8EF),
    tone: Color(0xFFB8436A),
  ),
  feeding(
    'Feeding',
    LucideIcons.milk,
    tint: Color(0xFFFDEDE3),
    tone: Color(0xFFB45A2E),
  ),
  sleep(
    'Sleep',
    LucideIcons.moon,
    tint: Color(0xFFE7EEFB),
    tone: Color(0xFF3F66B8),
  ),
  growth(
    'Growth',
    LucideIcons.sprout,
    tint: Color(0xFFEFE9FC),
    tone: Color(0xFF7050C8),
  ),
  behaviour(
    'Behaviour',
    LucideIcons.smile,
    tint: Color(0xFFF6E8F8),
    tone: Color(0xFF9444A8),
  );

  const AskTopic(
    this.label,
    this.icon, {
    required this.tint,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color tone;

  /// The composer's invitation once this topic is chosen.
  String placeholder(L10n l10n, ChildProfile? child) {
    final topic = l10n.tr(label).toLowerCase();
    return child == null
        ? l10n.tr('Ask about {topic}', {'topic': topic})
        : l10n.tr('Tell me about {name}’s {topic}', {
            'name': child.name,
            'topic': topic,
          });
  }
}
