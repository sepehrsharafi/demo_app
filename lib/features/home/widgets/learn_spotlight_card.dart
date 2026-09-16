import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A compact editorial preview of the lead story from the Learn tab.
class LearnSpotlightCard extends StatelessWidget {
  const LearnSpotlightCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.line),
            ),
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: compact ? 178 : 188,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: constraints.maxWidth * (compact ? 0.42 : 0.46),
                      child: ClipPath(
                        clipper: const _SpotlightImageClipper(),
                        child: Image.asset(
                          'assets/images/learn_growth_feature.webp',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.55, -0.05),
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 19,
                      top: 18,
                      width: constraints.maxWidth * (compact ? 0.55 : 0.53),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A read for today',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.green,
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Understanding growth spurts',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontSize: compact ? 20 : 22,
                                  height: 1.02,
                                  letterSpacing: -0.55,
                                ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            'Cleveland Clinic  ·  5 min',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 19,
                      bottom: 17,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue reading',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.navy,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 11.5,
                                ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.green,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gives the photograph a soft, irregular page-edge rather than another box.
class _SpotlightImageClipper extends CustomClipper<Path> {
  const _SpotlightImageClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.28, 0)
      ..cubicTo(
        0,
        size.height * 0.22,
        size.width * 0.22,
        size.height * 0.7,
        0,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
