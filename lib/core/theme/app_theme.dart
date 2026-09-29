import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../l10n/l10n.dart';
import 'app_motion.dart';
import 'sheet_page_transition.dart';

/// Every colour the app is allowed to use.
///
/// A warm milk ground with lavender as Mother AI's own colour:
///  * plum ink and the warm neutrals do the work of the interface,
///  * [voice] is Mother AI itself: its sparkle, its typing, the send button
///    and the active tab,
///  * [mist] and [leaf] are Home's morning: the wash under its question and
///    the leaves drawn on it,
///  * the three care colours live on [CareLevel] and are never used for
///    decoration,
///  * each topic and each child carries a hue of its own (see [AskTopic]
///    and `ChildProfile.hue`).
abstract final class AppColors {
  /// The brand's milk white, the same field the app icon sits on.
  static const ground = Color(0xFFFFFCF9);

  /// Quiet fills: the chat composer, search, attachment tiles.
  static const panel = Color(0xFFF5F0F7);

  /// Hover and pressed fills on ghost and outline controls.
  static const accentFill = Color(0xFFEEE7F2);
  static const line = Color(0xFFEAE3EC);

  static const ink = Color(0xFF1F1B3D);

  /// Secondary text. 5.3:1 on the ground and 4.7:1 on [mist].
  static const muted = Color(0xFF6B6781);

  static const voice = Color(0xFF7B57DB);
  static const voiceTint = Color(0xFFF1EBFD);

  /// Violet text on the ground (6.2:1), and the send button when pressed.
  static const voiceDeep = Color(0xFF6A45CC);

  /// The lavender morning Home's question sits in.
  static const mist = Color(0xFFF3EDFB);

  /// The leaves drawn on [mist].
  static const leaf = Color(0xFFE9E0F9);
}

/// The two faces, each with one job. Urbanist is the brand's display voice
/// and only sets headlines; Geist (bundled with shadcn_ui) sets everything a
/// person reads or taps, and has the tabular figures the numbers need.
abstract final class AppFonts {
  static const display = 'Urbanist';
  static const ui = 'Geist';
  static const uiPackage = 'shadcn_ui';

  static const tabular = [FontFeature.tabularFigures()];

  /// Vazirmatn sets everything in Arabic and Persian, headlines included:
  /// it carries the Arabic letters, the Latin ones for names, and the
  /// figures, so a line never changes face half way. It is bundled by the
  /// app itself, hence no package.
  static const arabic = 'Vazirmatn';
}

/// The type scale. One display size per screen, then four steps down to the
/// 12pt caption floor. Sizes sit on a 4pt rhythm.
///
/// The scale is drawn for Latin letters. In another script it keeps its
/// sizes but loses what only suits Latin: the tight tracking of headings
/// (which would pull apart the joins of Arabic and Persian) and the tight
/// line heights (which would crowd marks above and below the line in Hindi,
/// Arabic and Persian, and the square characters of Chinese). Each style is
/// therefore read through [tune], with the app's current language.
abstract final class AppText {
  static AppLanguage _language = AppLanguage.en;

  /// Set by the app whenever its language changes, before it rebuilds.
  static void useLanguage(AppLanguage language) => _language = language;

  /// [style] as it should be set in the app's current language.
  static TextStyle tune(TextStyle style) {
    if (_language.latinScript) return style;
    final height = style.height;
    final tuned = style.copyWith(
      letterSpacing: 0,
      height: height == null ? null : math.max(height, 1.3),
    );
    if (!_language.joinedScript) return tuned;
    // A style borrowed from a package (Geist) can't be pointed at the app's
    // own font with copyWith, which would look for it inside the package.
    return TextStyle(
      fontFamily: AppFonts.arabic,
      color: tuned.color,
      fontSize: tuned.fontSize,
      fontWeight: tuned.fontWeight,
      height: tuned.height,
      letterSpacing: 0,
      fontFeatures: tuned.fontFeatures,
    );
  }

  /// The one headline a screen opens with.
  static TextStyle get display => tune(_display);
  static const _display = TextStyle(
    fontFamily: AppFonts.display,
    color: AppColors.ink,
    fontSize: 36,
    height: 1.04,
    letterSpacing: -1.1,
    fontWeight: FontWeight.w700,
  );

  /// A pushed screen's title, or a sheet's.
  static TextStyle get title => tune(_title);
  static const _title = TextStyle(
    fontFamily: AppFonts.display,
    color: AppColors.ink,
    fontSize: 24,
    height: 1.12,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
  );

  /// A section's heading inside a screen ("Continue where you left off").
  static TextStyle get section => tune(_section);
  static const _section = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.ink,
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// A row's primary line.
  static TextStyle get rowTitle => tune(_rowTitle);
  static const _rowTitle = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.ink,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static TextStyle get body => tune(_body);
  static const _body = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.ink,
    fontSize: 16,
    height: 1.5,
    letterSpacing: -0.1,
  );

  static TextStyle get secondary => tune(_secondary);
  static const _secondary = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.muted,
    fontSize: 14,
    height: 1.4,
  );

  /// Group headings and small labels. Sentence case, never tracked caps.
  static TextStyle get label => tune(_label);
  static const _label = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.muted,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// The label of a large button, the action a screen or sheet ends on.
  /// It matches the rows around it; shadcn's 14pt looked lost in a 52pt
  /// bar. The button sets the colour.
  static TextStyle get button => tune(_button);
  static const _button = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Times, ages, read lengths: anything that is a number.
  static TextStyle get figure => tune(_figure);
  static const _figure = TextStyle(
    fontFamily: AppFonts.ui,
    package: AppFonts.uiPackage,
    color: AppColors.muted,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    fontFeatures: AppFonts.tabular,
  );
}

abstract final class AppTheme {
  static const radius = 14.0;

  static ShadDialogTheme get _dialog => ShadDialogTheme(
    titleTextAlign: TextAlign.start,
    descriptionTextAlign: TextAlign.start,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    // shadcn squares a dialog off edge to edge on a phone; ours stays a
    // rounded card with room around it (see showAppDialog for the margin).
    removeBorderRadiusWhenTiny: false,
    radius: const BorderRadius.all(Radius.circular(24)),
    padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
    gap: 10,
    actionsGap: 10,
    shadows: const [],
    titleStyle: AppText.title.copyWith(fontSize: 22),
    descriptionStyle: AppText.secondary.copyWith(fontSize: 15, height: 1.5),
    // Pops in on the cushion curve, overshooting a touch before it
    // settles, and leaves quicker and flatter than it came.
    animateIn: const [
      FadeEffect(duration: Duration(milliseconds: 160)),
      ScaleEffect(
        begin: Offset(0.86, 0.86),
        end: Offset(1, 1),
        duration: Duration(milliseconds: 480),
        curve: AppMotion.cushion,
      ),
    ],
    animateOut: const [
      FadeEffect(begin: 1, end: 0, duration: Duration(milliseconds: 160)),
      ScaleEffect(
        begin: Offset(1, 1),
        end: Offset(0.94, 0.94),
        duration: Duration(milliseconds: 160),
        curve: Curves.easeIn,
      ),
    ],
  );

  static ShadThemeData shad(AppLanguage language) => ShadThemeData(
    brightness: Brightness.light,
    radius: const BorderRadius.all(Radius.circular(radius)),
    colorScheme: const ShadColorScheme(
      background: AppColors.ground,
      foreground: AppColors.ink,
      card: AppColors.ground,
      cardForeground: AppColors.ink,
      popover: AppColors.ground,
      popoverForeground: AppColors.ink,
      primary: AppColors.ink,
      primaryForeground: Colors.white,
      secondary: AppColors.panel,
      secondaryForeground: AppColors.ink,
      muted: AppColors.panel,
      mutedForeground: AppColors.muted,
      accent: AppColors.accentFill,
      accentForeground: AppColors.ink,
      destructive: Color(0xFFD92D40),
      destructiveForeground: Colors.white,
      border: AppColors.line,
      input: AppColors.line,
      ring: AppColors.voice,
      selection: Color(0x407B57DB),
    ),
    textTheme: language.joinedScript
        ? ShadTextTheme(family: AppFonts.arabic)
        : ShadTextTheme(family: AppFonts.ui, package: AppFonts.uiPackage),
    buttonSizesTheme: const ShadButtonSizesTheme(
      regular: ShadButtonSizeTheme(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 18),
      ),
      sm: ShadButtonSizeTheme(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 14),
      ),
      lg: ShadButtonSizeTheme(
        height: 52,
        padding: EdgeInsets.symmetric(horizontal: 22),
      ),
    ),
    sheetTheme: ShadSheetTheme(
      radius: const BorderRadius.vertical(top: Radius.circular(24)),
      removeBorderRadiusWhenTiny: false,
      // shadcn only draws the drag handle on resizable sheets, so the top
      // inset has to give the title room by itself.
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      closeIcon: const _SheetClose(),
      // The scrim already separates a sheet from the page, and a blurred
      // shadow the width of the screen is a cost on every frame it moves.
      shadows: const [],
      // Rises on the settle curve and drops away faster than it came, while
      // the page behind steps back. Both movements run off the route's own
      // animation (SheetRise, RecedeBehindSheets); these silent effects only
      // tell shadcn how long the route lasts.
      animateIn: const [
        CustomEffect(duration: AppMotion.sheetIn, builder: _unchanged),
      ],
      animateOut: const [
        CustomEffect(duration: AppMotion.sheetOut, builder: _unchanged),
      ],
      // Centred on the title's first line.
      closeIconPosition: ShadPosition.directional(
        top: 22,
        end: 20,
        textDirection: language.direction,
      ),
      titleTextAlign: TextAlign.start,
      descriptionTextAlign: TextAlign.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      titleStyle: AppText.title,
      descriptionStyle: AppText.secondary,
    ),
    primaryDialogTheme: _dialog,
    alertDialogTheme: _dialog,
    switchTheme: const ShadSwitchTheme(
      checkedTrackColor: AppColors.voice,
      width: 46,
    ),
  );

  /// The Material layer underneath, for Scaffold, text fields and routes.
  static ThemeData material(ThemeData base, AppLanguage language) {
    final arabic = language.joinedScript;
    return base.copyWith(
      textTheme: arabic
          ? base.textTheme.apply(fontFamily: AppFonts.arabic)
          : base.textTheme,
      primaryTextTheme: arabic
          ? base.primaryTextTheme.apply(fontFamily: AppFonts.arabic)
          : base.primaryTextTheme,
      scaffoldBackgroundColor: AppColors.ground,
      splashFactory: InkRipple.splashFactory,
      highlightColor: AppColors.panel,
      splashColor: const Color(0x0F1F1B3D),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          // iOS keeps its own push so the edge-swipe back gesture survives.
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: SheetPageTransitionsBuilder(),
          TargetPlatform.fuchsia: SheetPageTransitionsBuilder(),
          TargetPlatform.linux: SheetPageTransitionsBuilder(),
          TargetPlatform.windows: SheetPageTransitionsBuilder(),
        },
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.voice,
        selectionColor: Color(0x407B57DB),
        selectionHandleColor: AppColors.voice,
      ),
    );
  }
}

Widget _unchanged(BuildContext context, double value, Widget child) => child;

/// Every sheet's close button: a 36pt disc on the panel fill, big enough to
/// hit with a thumb, where shadcn's default is a 20pt grey cross.
class _SheetClose extends StatelessWidget {
  const _SheetClose();

  @override
  Widget build(BuildContext context) {
    return ShadIconButton(
      width: 36,
      height: 36,
      iconSize: 18,
      backgroundColor: AppColors.panel,
      hoverBackgroundColor: AppColors.accentFill,
      pressedBackgroundColor: AppColors.line,
      foregroundColor: AppColors.muted,
      hoverForegroundColor: AppColors.ink,
      icon: Icon(LucideIcons.x, semanticLabel: context.tr('Close')),
      decoration: const ShadDecoration(
        border: ShadBorder(radius: BorderRadius.all(Radius.circular(18))),
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
