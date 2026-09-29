import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// How much help a situation needs. This is the only thing the green, amber
/// and red in the app ever mean.
enum CareLevel {
  home(
    label: 'Fine to handle at home',
    short: 'Home care',
    color: Color(0xFF00A86B),
    tint: Color(0xFFE2F5EC),
    deep: Color(0xFF006B45),
    icon: LucideIcons.house,
  ),
  gp(
    label: 'Call your GP or health visitor today',
    short: 'Call GP',
    color: Color(0xFFFFA412),
    tint: Color(0xFFFFF0D9),
    deep: Color(0xFF8A5200),
    icon: LucideIcons.phone,
    action: 'Call your GP',
  ),
  urgent(
    label: 'Get urgent help now',
    short: 'Urgent',
    color: Color(0xFFF2384A),
    tint: Color(0xFFFFE4E7),
    deep: Color(0xFFB0142A),
    icon: LucideIcons.siren,
    action: 'Call emergency services',
  );

  const CareLevel({
    required this.label,
    required this.short,
    required this.color,
    required this.tint,
    required this.deep,
    required this.icon,
    this.action,
  });

  /// The sentence shown on an answer.
  final String label;

  /// The word shown in a list, where there is only room for one.
  final String short;

  final Color color;
  final Color tint;

  /// Text colour on [tint]; at least 5.5:1.
  final Color deep;
  final IconData icon;

  /// Amber and red always come with the next step as a button.
  final String? action;
}
