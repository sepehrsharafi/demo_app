import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Icons that point somewhere, pointing the way the language reads: "back"
/// is towards the trailing edge in Arabic and Persian, and "forward" towards
/// the leading one.
extension DirectionalIcons on BuildContext {
  bool get _rtl => Directionality.of(this) == TextDirection.rtl;

  IconData get backChevron =>
      _rtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft;

  IconData get forwardChevron =>
      _rtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight;

  IconData get forwardArrow =>
      _rtl ? LucideIcons.arrowLeft : LucideIcons.arrowRight;

  /// Towards something opened elsewhere or asked further.
  IconData get outArrow =>
      _rtl ? LucideIcons.arrowUpLeft : LucideIcons.arrowUpRight;
}
