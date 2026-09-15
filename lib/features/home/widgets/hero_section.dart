import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    // The hero flows edge-to-edge behind the status bar, so reserve its height
    // and push the copy down by the top safe-area inset.
    final topInset = MediaQuery.of(context).padding.top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return SizedBox(
          height: topInset + (compact ? 242 : 250),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/journey_hero_illustration.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
              // The illustration is cover-cropped, so how much of its two
              // corner blobs show up (right under the copy) shifts with the
              // device's aspect ratio. This is a plain gradient with no
              // shape or edge of its own — it just quietly settles the
              // image back toward the page's own cream wherever the copy
              // sits, so the text keeps its contrast regardless of crop,
              // and has fully faded out before it reaches the illustration.
              const Positioned.fill(child: _HeroLegibilityWash()),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 96,
                child: _HeroBottomFade(),
              ),
              Positioned(
                left: 30,
                top: topInset + 16,
                right: constraints.maxWidth * 0.42,
                child: _HeroCopy(compact: compact),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroLegibilityWash extends StatelessWidget {
  const _HeroLegibilityWash();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xF2FFFCF9),
              Color(0xD1FFFCF9),
              Color(0x8FFFFCF9),
              Color(0x40FFFCF9),
              Color(0x00FFFCF9),
            ],
            stops: [0.0, 0.26, 0.44, 0.58, 0.7],
          ),
        ),
      ),
    );
  }
}

class _HeroBottomFade extends StatelessWidget {
  const _HeroBottomFade();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x00FFFCF9),
              Color(0x40FFFCF9),
              Color(0x99FFFCF9),
              Color(0xE6FFFCF9),
              AppColors.background,
            ],
            stops: [0.0, 0.35, 0.62, 0.84, 1.0],
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.wb_sunny_outlined,
              color: Color(0xFFF2B24C),
              size: 20,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'Good morning',
                maxLines: 1,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                  fontSize: compact ? 11.5 : 12.5,
                  height: 1,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 18 : 25),
        // Both lines of the headline share one size — previously each line
        // (and the gradient one) quietly drifted to its own number.
        Text(
          'Here for\nevery question',
          style: textTheme.displayLarge?.copyWith(
            fontSize: compact ? 30 : 32,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFA177EF), Color(0xFF8F72DF)],
          ).createShader(bounds),
          child: Text(
            'in your journey',
            maxLines: 1,
            softWrap: false,
            style: textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: compact ? 30 : 32,
            ),
          ),
        ),
        SizedBox(height: compact ? 12 : 15),
        Text(
          'Real answers. Kinder days.\nBrighter tomorrows.',
          style: textTheme.bodyLarge?.copyWith(
            fontSize: compact ? 15 : 16,
          ),
        ),
        const SizedBox(height: 11),
        SvgPicture.asset(
          'assets/icons/heart.svg',
          width: compact ? 20 : 22,
          height: compact ? 20 : 22,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFF9FA8),
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}
