import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The Learn tab's body: one big featured article followed by a list of
/// smaller article cards. Every card — featured or not — carries an image.
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  static const _featured = _Article(
    category: 'GROWTH',
    accent: AppColors.green,
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
      accent: Color(0xFFF16468),
      title: 'Fever 101: when to worry',
      snippet: 'What counts as mild, and the signs that mean call the doctor.',
      imagePath: 'assets/images/learn_fever.webp',
      readTime: '4 min read',
      source: 'HealthyChildren.org',
    ),
    _Article(
      category: 'SLEEP',
      accent: Color(0xFF4564E7),
      title: 'Building a bedtime routine',
      snippet: 'A simple, repeatable wind-down that helps sleep click.',
      imagePath: 'assets/images/learn_bedtime.webp',
      readTime: '6 min read',
      source: 'NHS',
    ),
    _Article(
      category: 'PARENTING',
      accent: AppColors.coral,
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
                        const SizedBox(height: 20),
                        for (var i = 0; i < _articles.length; i++) ...[
                          _ArticleCard(
                            data: _articles[i],
                            storyNumber: i + 2,
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
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 420,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
                alignment: const Alignment(0.3, -0.1),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1006132D),
                      Color(0x0006132D),
                      Color(0xE80A1A3D),
                    ],
                    stops: [0, 0.36, 1],
                  ),
                ),
              ),
              const Positioned(left: 16, top: 16, child: _FeaturedBadge()),
              Positioned(
                right: 16,
                top: 16,
                child: _SourcePill(source: data.source),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryTag(
                      text: data.category,
                      color: data.accent,
                      onDark: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 27,
                            height: 1.02,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.85,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(14, 9, 10, 9),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Read story',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  color: AppColors.navy,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          data.readTime.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A smaller, horizontal card used for every article below the featured one.
class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.data,
    required this.storyNumber,
    required this.onTap,
  });

  final _Article data;
  final int storyNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [data.accent.withValues(alpha: 0.06), Colors.white],
            stops: const [0, 0.5],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: data.accent.withValues(alpha: 0.1)),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 158,
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -48,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.055),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 132,
                      height: 158,
                      child: ClipPath(
                        clipper: const _EditorialImageClipper(),
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
                                    Color(0x3D07142E),
                                  ],
                                  stops: [0.55, 1],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              top: 12,
                              child: _StoryNumber(number: storyNumber),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 13, 14, 12),
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
                                    color: data.accent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_outward_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
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
                            const SizedBox(height: 3),
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
                Positioned(
                  left: 132,
                  right: 0,
                  bottom: 0,
                  child: Container(height: 3, color: data.accent),
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
  const _CategoryTag({
    required this.text,
    required this.color,
    this.onDark = false,
  });

  final String text;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onDark
            ? Colors.white.withValues(alpha: 0.17)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: onDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.16))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            color: onDark ? Colors.white : color,
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

class _SourcePill extends StatelessWidget {
  const _SourcePill({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xC70A1A3D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_rounded,
              color: Colors.white.withValues(alpha: 0.82),
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              'From $source',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryNumber extends StatelessWidget {
  const _StoryNumber({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          number.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _EditorialImageClipper extends CustomClipper<Path> {
  const _EditorialImageClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width - 18, 0)
      ..quadraticBezierTo(
        size.width + 10,
        size.height * 0.47,
        size.width - 8,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Color(0x180A1733), blurRadius: 12)],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Text(
          "EDITOR'S PICK",
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _LearnBackground extends StatelessWidget {
  const _LearnBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4FBF7), AppColors.background],
            stops: [0.0, 0.4],
          ),
        ),
      ),
    );
  }
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
