import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// A teaser for one article pulled from the Learn tab, shown on Home instead
/// of a generic "daily support" prompt so the card always points at real,
/// informational content.
class LearnSpotlightCard extends StatelessWidget {
  const LearnSpotlightCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: compact ? 164 : 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/learn_growth_feature.webp',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.35, -0.05),
                    filterQuality: FilterQuality.high,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFA091A3E),
                          Color(0xE6091A3E),
                          Color(0x8A091A3E),
                          Color(0x08091A3E),
                        ],
                        stops: [0, 0.42, 0.7, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 17,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          'FROM LEARN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: compact ? 52 : 56,
                    width: constraints.maxWidth * (compact ? 0.72 : 0.66),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Understanding\ngrowth spurts',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: compact ? 20 : 22,
                                height: 1.02,
                                letterSpacing: -0.6,
                              ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Icon(
                              Icons.public_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'From Cleveland Clinic',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 15,
                    bottom: 15,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 43,
                        height: 43,
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          color: AppColors.navy,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 19,
                    top: 20,
                    child: Text(
                      '5 MIN READ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.05,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.green,
                              Color(0xFF73D2B4),
                              Colors.transparent,
                            ],
                            stops: [0, 0.5, 1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
