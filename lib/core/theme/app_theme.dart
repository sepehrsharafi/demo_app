import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFFFCF9);
  static const navy = Color(0xFF10265A);
  // The one muted grey for secondary/caption text and icons app-wide —
  // hints, captions, chevrons, timestamps. Reach for this instead of a new
  // one-off grey.
  static const inkMuted = Color(0xFF7380A7);
  // The one "handwritten aside" accent for the app's italic asides/quotes
  // (hero taglines, chat welcome asides, the Chats header quote).
  static const whisper = Color(0xFF8792C2);
  static const lavender = Color(0xFF9C79E8);
  static const blush = Color(0xFFFFDAD6);
  static const coral = Color(0xFFE96862);
  static const mint = Color(0xFFDDF4EC);
  static const green = Color(0xFF2D9B7A);
  static const sky = Color(0xFFDCEAFF);
  static const blue = Color(0xFF3972C8);
  static const line = Color(0xFFEAE7F1);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.lavender,
          brightness: Brightness.light,
          surface: AppColors.background,
        ).copyWith(
          primary: AppColors.lavender,
          onPrimary: Colors.white,
          onSurface: AppColors.navy,
          outline: AppColors.line,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Urbanist',
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      // Pushing a conversation should glide rather than snap. iOS keeps its
      // native slide (so the edge-swipe back gesture still reads correctly);
      // everywhere else uses Material's gentler fade-forwards motion.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // A deliberate, six-step scale — every screen should reach for one of
      // these roles rather than hand-rolling a fontSize. From biggest to
      // smallest:
      //  displayLarge  — the one big headline a screen introduces itself
      //                  with (Home's greeting, every tab's own header).
      //  headlineSmall — a section or card's own cover headline (a chat
      //                  bubble's opening line, a featured article).
      //  titleMedium   — a list/card row's title (a name, a conversation,
      //                  an article headline).
      //  bodyLarge     — the supporting line directly under a headline.
      //  bodyMedium    — secondary/paragraph copy (previews, descriptions).
      //  labelMedium   — a small italic aside or link ("read again →").
      //  labelSmall    — a small-caps eyebrow label or tag.
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.navy,
          fontSize: 32,
          height: 1.05,
          letterSpacing: -1.1,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.navy,
          fontSize: 25,
          height: 1.12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          color: AppColors.navy,
          fontSize: 16.5,
          height: 1.25,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.inkMuted,
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: AppColors.inkMuted,
          fontSize: 14,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: AppColors.inkMuted,
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
        labelSmall: TextStyle(
          color: AppColors.inkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
        ),
      ),
    );
  }
}
