import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';

/// Mother AI's mark: the logo, kept small.
class MotherMark extends StatelessWidget {
  const MotherMark({super.key, required this.size});

  final double size;

  /// The logo is 1024px square. Decoded at full size it would be a 4MB
  /// bitmap resampled on every frame for a 28pt mark, so it is decoded at
  /// the size it is drawn.
  static ImageProvider<Object> _logo(double pixels) => ResizeImage(
    const AssetImage('assets/branding/mother_ai_icon.png'),
    width: pixels.ceil(),
    policy: ResizeImagePolicy.fit,
  );

  @override
  Widget build(BuildContext context) {
    final pixels = size * MediaQuery.devicePixelRatioOf(context);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          image: DecorationImage(image: _logo(pixels), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
