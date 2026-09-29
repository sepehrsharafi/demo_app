import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:shadcn_ui/shadcn_ui.dart' show LucideIcons;

import '../l10n/app_language.dart';
import 'app_theme.dart';

/// Draws, once and off screen while the splash is up, every kind of thing
/// the app's transitions draw, so the phone has it ready before the first
/// tap.
///
/// On phones where the renderer runs on OpenGL (most cheaper Android
/// phones), the GPU driver compiles a program the first time each kind of
/// drawing appears: a fade layer, a rounded clip, a blurred shadow, a
/// gradient, a scaled photo. Text is the same: each font, weight and size
/// has its letters drawn into a cache the first time it is shown. Without
/// this, the first sheet, toast or photo flight of a session stutters while
/// that happens, and later ones are smooth. None of it can be done when the
/// app is built, because it belongs to each phone's own driver.
///
/// Set as [PaintingBinding.shaderWarmUp] in `main`, before the binding
/// starts.
class MotionWarmUp extends ShaderWarmUp {
  const MotionWarmUp();

  /// Physical pixels. The work is drawn at the screen's own density so text
  /// is cached at the size it will really be drawn.
  static const _side = 1024.0;

  @override
  Size get size => const Size(_side, _side);

  static double get _pixelRatio =>
      ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 2.75;

  @override
  Future<void> warmUpOnCanvas(ui.Canvas canvas) async {
    final ratio = _pixelRatio;
    canvas.save();
    canvas.scale(ratio);

    final photo = _photo();
    _shapes(canvas);
    _clipsAndLayers(canvas, photo);
    _text(canvas);

    canvas.restore();
    photo.dispose();
  }

  /// A small raster standing in for photos, snapshots and the logo.
  static ui.Image _photo() {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 64, 64),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(64, 64), const [
          AppColors.mist,
          AppColors.voice,
        ]),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(64, 64);
    picture.dispose();
    return image;
  }

  /// Fills, strokes, hairline borders, shadows, gradients and the leaves.
  static void _shapes(ui.Canvas canvas) {
    final fill = Paint()..isAntiAlias = true;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const box = Rect.fromLTWH(8, 8, 120, 80);

    // Solid and translucent fills: panels, scrims, veils, tints.
    for (final color in const [
      AppColors.ground,
      AppColors.panel,
      Color(0x521F1B3D),
      Color(0x80FFFCF9),
    ]) {
      canvas.drawRect(box, fill..color = color);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(14)),
        fill,
      );
    }
    canvas.drawCircle(const Offset(60, 60), 22, fill..color = AppColors.voice);
    canvas.drawOval(const Rect.fromLTWH(10, 10, 60, 30), fill);

    // Borders: a rounded box's hairline is a ring between two rounded rects.
    final outer = RRect.fromRectAndRadius(box, const Radius.circular(26));
    canvas.drawDRRect(outer, outer.deflate(1), fill..color = AppColors.line);
    canvas.drawRRect(
      outer,
      stroke
        ..strokeWidth = 1
        ..color = AppColors.line,
    );
    canvas.drawLine(
      const Offset(8, 100),
      const Offset(200, 100),
      stroke..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      const Offset(80, 80),
      30,
      stroke
        ..strokeWidth = 3
        ..color = AppColors.leaf,
    );

    // Soft shadows: the composer's lift, the island, the toast, the push.
    for (final sigma in const [1.5, 3.0, 5.0, 12.0, 14.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(20)),
        Paint()
          ..color = const Color(0x1F3B2A7A)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma),
      );
    }
    canvas.drawRect(
      box,
      Paint()
        ..color = const Color(0x1A1F1B3D)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // The morning's gradient wash.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 200, 200),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(0, 200),
          const [AppColors.mist, AppColors.mist, AppColors.ground],
          const [0, 0.45, 1],
        ),
    );

    // Leaves and sprigs: curved fills, rotated.
    final leaf = Path()
      ..moveTo(0, 0)
      ..cubicTo(20, -26, 70, -22, 110, 0)
      ..cubicTo(70, 22, 20, 26, 0, 0)
      ..close();
    for (final angle in const [-2.5, -1.4, 0.3]) {
      canvas.save();
      canvas.translate(120, 120);
      canvas.rotate(angle);
      canvas.drawPath(leaf, fill..color = AppColors.leaf);
      canvas.restore();
    }
    final stem = Path()
      ..moveTo(10, 180)
      ..cubicTo(40, 120, 60, 80, 120, 20);
    canvas.drawPath(
      stem,
      stroke
        ..strokeWidth = 3
        ..color = AppColors.leaf,
    );
  }

  /// Rounded clips, the island cut-out, fade layers and scaled photos.
  static void _clipsAndLayers(ui.Canvas canvas, ui.Image photo) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final source = Rect.fromLTWH(
      0,
      0,
      photo.width.toDouble(),
      photo.height.toDouble(),
    );
    const target = Rect.fromLTWH(10, 10, 180, 140);

    // A photo in a rounded frame, as thumbnails and the lead are.
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(target, const Radius.circular(18)),
    );
    canvas.drawImageRect(photo, source, target, paint);
    canvas.restore();

    // The page stepping back: a snapshot scaled and dropped under a
    // rounded clip that is itself changing.
    for (final t in const [0.3, 1.0]) {
      canvas.save();
      canvas.translate(0, 10 * t);
      canvas.scale(1 - 0.06 * t);
      canvas.clipRRect(
        RRect.fromRectAndRadius(target, Radius.circular(28 * t)),
      );
      canvas.drawImageRect(photo, source, target, paint);
      canvas.restore();
    }

    // A photo in flight beneath the island: the island cut out of it.
    final hole = Path.combine(
      PathOperation.difference,
      Path()..addRect(target),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 100, 160, 64),
          const Radius.circular(32),
        ),
      ),
    );
    canvas.save();
    canvas.clipPath(hole);
    canvas.drawImageRect(photo, source, target, paint);
    canvas.restore();

    // A plain clip, as the name's roll and the attachment strip use.
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(10, 10, 100, 40));
    canvas.drawImageRect(photo, source, target, paint);
    canvas.restore();

    // Fade layers: toasts, and the fades that aren't on a flat ground.
    for (final alpha in const [0.35, 0.8]) {
      canvas.saveLayer(target, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
      canvas.drawRRect(
        RRect.fromRectAndRadius(target, const Radius.circular(20)),
        Paint()..color = AppColors.ground,
      );
      canvas.drawImageRect(photo, source, target.deflate(20), paint);
      canvas.restore();
    }
    canvas.saveLayer(null, Paint());
    canvas.drawImageRect(photo, source, target, paint);
    canvas.restore();

    // Rotated and scaled glyph-sized images, as icons in motion are.
    canvas.save();
    canvas.translate(100, 100);
    canvas.rotate(0.3);
    canvas.scale(1.2);
    canvas.drawImageRect(
      photo,
      source,
      const Rect.fromLTWH(0, 0, 30, 30),
      paint,
    );
    canvas.restore();
  }

  /// Every face, weight and size the app sets, with the characters its
  /// copy uses, so each is laid out and cached once before it is needed.
  static void _text(ui.Canvas canvas) {
    const sample =
        'What’s on your mind about Emma Daniel? ABCDEFGHIJKLMNOPQRSTUVWXYZ '
        'abcdefghijklmnopqrstuvwxyz 0123456789 · “”‘’,.:;!?-–()&/%';
    const display = [24.0, 26.0, 30.0, 34.0, 36.0, 38.0];
    // 15.5 is the reading size of notices, the terms and the policy.
    const uiSizes = [12.0, 13.0, 14.0, 15.0, 15.5, 16.0, 16.5, 17.0];

    void draw(TextStyle style, {String text = sample}) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 320);
      // Everything is drawn at the same spot: only that it is drawn once
      // matters, not where.
      painter.paint(canvas, Offset.zero);
      painter.dispose();
    }

    for (final size in display) {
      draw(AppText.display.copyWith(fontSize: size));
    }
    // Monogram initials.
    for (final size in const [9.2, 15.6, 18.4, 20.2]) {
      draw(
        TextStyle(
          fontFamily: AppFonts.display,
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
        text: 'EDSM',
      );
    }
    for (final weight in const [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ]) {
      for (final size in uiSizes) {
        draw(AppText.body.copyWith(fontSize: size, fontWeight: weight));
      }
    }
    // The language list names each language in itself. Hindi and Chinese
    // are drawn in the phone's own fonts, which are only found and loaded
    // the first time one of their letters is set: behind the splash, not
    // as the sheet rises. A Chinese font is the largest file on the phone.
    for (final language in AppLanguage.values) {
      if (!language.rightToLeft) {
        draw(AppText.rowTitle, text: language.nativeName);
      }
    }
    // Arabic and Persian are set in Vazirmatn, in the list and wherever the
    // app is in either language.
    const arabic = 'فارسی العربية مادر هوش مصنوعی 0123456789 ،؟';
    for (final weight in const [
      FontWeight.w400,
      FontWeight.w600,
      FontWeight.w700,
    ]) {
      for (final size in const [13.0, 14.0, 15.5, 16.0, 17.0, 24.0]) {
        draw(
          TextStyle(
            fontFamily: AppFonts.arabic,
            fontSize: size,
            fontWeight: weight,
          ),
          text: arabic,
        );
      }
    }
    // Tabular figures are separate glyphs.
    for (final size in const [12.0, 13.0, 14.0, 16.0, 24.0]) {
      draw(
        AppText.figure.copyWith(fontSize: size),
        text: '0123456789 · min read months years',
      );
    }
    // The icons, at the sizes they are drawn.
    final icons = String.fromCharCodes([
      for (final icon in const [
        LucideIcons.house,
        LucideIcons.messagesSquare,
        LucideIcons.bookOpen,
        LucideIcons.userRound,
        LucideIcons.x,
        LucideIcons.chevronDown,
        LucideIcons.chevronRight,
        LucideIcons.chevronLeft,
        LucideIcons.arrowUp,
        LucideIcons.arrowRight,
        LucideIcons.arrowUpRight,
        LucideIcons.arrowLeft,
        LucideIcons.arrowUpLeft,
        LucideIcons.sparkles,
        LucideIcons.plus,
        LucideIcons.check,
        LucideIcons.stethoscope,
        LucideIcons.milk,
        LucideIcons.moon,
        LucideIcons.sprout,
        LucideIcons.smile,
        LucideIcons.camera,
        LucideIcons.images,
        LucideIcons.fileText,
        LucideIcons.search,
        LucideIcons.globe,
        LucideIcons.usersRound,
        LucideIcons.bookmarkCheck,
        LucideIcons.mail,
        LucideIcons.copy,
        LucideIcons.pencil,
        LucideIcons.messageCircle,
        LucideIcons.shieldAlert,
      ])
        icon.codePoint,
    ]);
    for (final size in const [
      13.0,
      14.0,
      15.0,
      16.0,
      17.0,
      18.0,
      20.0,
      22.0,
      26.0,
      30.0,
    ]) {
      draw(
        TextStyle(
          fontFamily: LucideIcons.house.fontFamily,
          package: LucideIcons.house.fontPackage,
          fontSize: size,
        ),
        text: icons,
      );
    }
  }
}
