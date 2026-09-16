import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The Learn tab's body: one big featured article followed by a list of
/// smaller article cards. Every card — featured or not — carries an image.
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  static const _featured = _Article(
    category: 'GROWTH',
    accent: Color(0xFF6C8E7D),
    title: 'Understanding growth spurts',
    snippet:
        'Why sudden growth and crankiness often go together, and how to '
        'support your child through one.',
    imagePath: 'assets/images/learn_growth_feature.webp',
    readTime: '5 min read',
    source: 'Cleveland Clinic',
  );

  static const _articles = <_Article>[
    _Article(
      category: 'HEALTH',
      accent: Color(0xFFB96F72),
      title: 'Fever 101: when to worry',
      snippet: 'What counts as mild, and the signs that mean call the doctor.',
      imagePath: 'assets/images/learn_fever.webp',
      readTime: '4 min read',
      source: 'HealthyChildren.org',
    ),
    _Article(
      category: 'SLEEP',
      accent: Color(0xFF65749B),
      title: 'Building a bedtime routine',
      snippet: 'A simple, repeatable wind-down that helps sleep click.',
      imagePath: 'assets/images/learn_bedtime.webp',
      readTime: '6 min read',
      source: 'NHS',
    ),
    _Article(
      category: 'PARENTING',
      accent: Color(0xFFB87564),
      title: 'Positive discipline basics',
      snippet: 'Setting boundaries with warmth instead of power struggles.',
      imagePath: 'assets/images/learn_positive_discipline.webp',
      readTime: '7 min read',
      source: 'UNICEF Parenting',
    ),
  ];

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('“$title” — full article coming soon'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        const Positioned.fill(child: _LearnBackground()),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 4),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Learn', style: textTheme.displayLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Practical tips, trusted guidance.',
                            style: textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 128),
                    sliver: SliverList.list(
                      children: [
                        _FeaturedArticleCard(
                          data: _featured,
                          onTap: () =>
                              _showComingSoon(context, _featured.title),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Text(
                              'More to explore',
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Divider(color: AppColors.line, height: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        for (var i = 0; i < _articles.length; i++) ...[
                          _ArticleCard(
                            data: _articles[i],
                            onTap: () =>
                                _showComingSoon(context, _articles[i].title),
                          ),
                          if (i != _articles.length - 1)
                            const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The lead story is treated like an editorial cover rather than a standard
/// image-and-text card.
class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard({required this.data, required this.onTap});

  final _Article data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 245,
              child: ClipPath(
                clipper: const _FeatureImageClipper(),
                child: Image.asset(
                  data.imagePath,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.3, -0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Editor’s selection',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: data.accent, fontSize: 12.5),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '${data.source}  ·  ${data.readTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 67,
                        margin: const EdgeInsets.only(top: 2, right: 13),
                        decoration: BoxDecoration(
                          color: data.accent,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontSize: 29,
                                    height: 1,
                                    letterSpacing: -0.95,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.snippet,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 13, height: 1.32),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Read the story',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.navy,
                              fontStyle: FontStyle.normal,
                              fontSize: 12.5,
                            ),
                      ),
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.green,
                        size: 17,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureImageClipper extends CustomClipper<Path> {
  const _FeatureImageClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 18)
      ..cubicTo(
        size.width * 0.28,
        size.height - 50,
        size.width * 0.7,
        size.height + 8,
        size.width,
        size.height - 28,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// A smaller, horizontal card used for every article below the featured one.
/// The photograph is anchored to the card edge, with only a slight editorial
/// angle where it meets the article copy.
class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.data, required this.onTap});

  final _Article data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFC),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFECE8E3)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D10265A),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 164,
            child: Stack(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 126,
                      height: double.infinity,
                      child: ClipPath(
                        clipper: const _AngledImageClipper(),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(data.imagePath, fit: BoxFit.cover),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x2B13213B),
                                  ],
                                  stops: [0.64, 1],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 14, 14, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _CategoryTag(
                                  text: data.category,
                                  color: data.accent,
                                ),
                                const Spacer(),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: data.accent.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_outward_rounded,
                                    color: data.accent,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.snippet,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11.7, height: 1.25),
                            ),
                            const Spacer(),
                            _SourceLine(
                              source: data.source,
                              readTime: data.readTime,
                              color: data.accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.25,
          ),
        ),
      ),
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({
    required this.source,
    required this.readTime,
    required this.color,
  });

  final String source;
  final String readTime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.public_rounded, color: color, size: 11),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              children: [
                const TextSpan(text: 'From  '),
                TextSpan(
                  text: source,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              color: AppColors.inkMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          readTime.toUpperCase(),
          style: const TextStyle(
            color: AppColors.inkMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.65,
          ),
        ),
      ],
    );
  }
}

class _AngledImageClipper extends CustomClipper<Path> {
  const _AngledImageClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width - 12, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _LearnBackground extends StatelessWidget {
  const _LearnBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: CustomPaint(painter: _LearnBackgroundPainter()),
      ),
    );
  }
}

class _LearnBackgroundPainter extends CustomPainter {
  const _LearnBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Overlapping translucent fields bring the multi-color atmosphere from
    // the other tabs into Learn while leaving the title area calm and clear.
    final blushBounds = Rect.fromLTWH(-90, -48, 265, 220);
    canvas.drawOval(
      blushBounds,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.15, -0.2),
          colors: [Color(0x99FFE1DD), Color(0x00FFE1DD)],
        ).createShader(blushBounds),
    );

    final lavenderWash = Path()
      ..moveTo(size.width * 0.3, 0)
      ..cubicTo(
        size.width * 0.38,
        54,
        size.width * 0.43,
        137,
        size.width * 0.67,
        165,
      )
      ..cubicTo(size.width * 0.84, 184, size.width + 18, 132, size.width, 0)
      ..close();
    canvas.drawPath(lavenderWash, Paint()..color = const Color(0x66EEE8FF));

    final skyBounds = Rect.fromLTWH(size.width * 0.42, -42, 210, 175);
    canvas.drawOval(
      skyBounds,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x88DCEAFF), Color(0x00DCEAFF)],
        ).createShader(skyBounds),
    );

    final topCenter = Offset(size.width + 5, 82);
    canvas.drawCircle(topCenter, 112, Paint()..color = const Color(0x88DDF4EC));
    canvas.drawCircle(
      Offset(size.width - 5, 72),
      71,
      Paint()
        ..color = const Color(0x336C8E7D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    final blushContour = Path()
      ..moveTo(0, 116)
      ..cubicTo(38, 100, 82, 108, 112, 143);
    canvas.drawPath(
      blushContour,
      Paint()
        ..color = const Color(0x40E96862)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // A broad paper-like fold enters from the left and sits behind the list.
    final leftFold = Path()
      ..moveTo(0, size.height * 0.42)
      ..cubicTo(
        48,
        size.height * 0.39,
        78,
        size.height * 0.46,
        61,
        size.height * 0.54,
      )
      ..cubicTo(
        45,
        size.height * 0.61,
        17,
        size.height * 0.64,
        0,
        size.height * 0.65,
      )
      ..close();
    canvas.drawPath(leftFold, Paint()..color = const Color(0x55E7F0FF));

    // One fine contour gives the flat color fields a little dimensionality.
    final contour = Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(
        30,
        size.height * 0.46,
        58,
        size.height * 0.49,
        49,
        size.height * 0.56,
      );
    canvas.drawPath(
      contour,
      Paint()
        ..color = const Color(0x305E83A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final bottomShape = Path()
      ..moveTo(size.width, size.height * 0.73)
      ..cubicTo(
        size.width - 50,
        size.height * 0.75,
        size.width - 78,
        size.height * 0.84,
        size.width - 45,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(bottomShape, Paint()..color = const Color(0x4DF1ECFA));
  }

  @override
  bool shouldRepaint(covariant _LearnBackgroundPainter oldDelegate) => false;
}

class _Article {
  const _Article({
    required this.category,
    required this.accent,
    required this.title,
    required this.snippet,
    required this.imagePath,
    required this.readTime,
    required this.source,
  });

  final String category;
  final Color accent;
  final String title;
  final String snippet;
  final String imagePath;
  final String readTime;
  final String source;
}
