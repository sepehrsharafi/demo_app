import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/models/care_level.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/beneath_island.dart';
import '../../core/widgets/directional_icons.dart';
import '../chat/chat_page.dart';
import 'articles.dart';
import 'widgets/article_meta.dart';

/// Reading an article. It ends where the product loops: asking Mother AI
/// about what you just read.
class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key, required this.article});

  final Article article;

  void _ask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ChatPage(prompts: article.followUps, fromArticle: article.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Capped, so on a tablet the reader still opens on the title.
    final photoHeight = math.min(
      MediaQuery.sizeOf(context).width * 3 / 4,
      440.0,
    );
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // The photo collapses into a plain bar, so the back button
              // never ends up floating over the text.
              SliverAppBar(
                pinned: true,
                expandedHeight: photoHeight,
                backgroundColor: AppColors.ground,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                shape: const Border(bottom: BorderSide(color: AppColors.line)),
                leadingWidth: 68,
                leading: Center(
                  child: ShadIconButton.secondary(
                    width: 44,
                    height: 44,
                    iconSize: 22,
                    backgroundColor: Colors.white,
                    hoverBackgroundColor: AppColors.panel,
                    icon: Icon(
                      context.backChevron,
                      semanticLabel: context.tr('Back'),
                    ),
                    decoration: ShadDecoration(
                      border: ShadBorder.all(
                        color: AppColors.line,
                        radius: const BorderRadius.all(Radius.circular(22)),
                      ),
                    ),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Hero(
                    flightShuttleBuilder: flyBeneathIsland,
                    tag: article.imagePath!,
                    child: Image.asset(
                      article.imagePath!,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.2, 0),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                      child: _Body(article: article),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.ground,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 592),
                    child: ShadButton(
                      size: ShadButtonSize.lg,
                      textStyle: AppText.button,
                      width: double.infinity,
                      leading: const Icon(LucideIcons.messageCircle, size: 18),
                      onPressed: () => _ask(context),
                      child: Flexible(
                        child: Text(
                          context.tr('Ask Mother AI about this'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(article.title),
          style: AppText.display.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 12),
        ArticleMeta(article: article),
        const SizedBox(height: 24),
        Text(
          context.tr(article.summary),
          style: AppText.body.copyWith(
            fontSize: 19,
            height: 1.45,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 20),
        for (final paragraph in article.body) ...[
          Text(
            context.tr(paragraph),
            style: AppText.body.copyWith(fontSize: 17, height: 1.6),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 20),
        Text(context.tr('What helps'), style: AppText.title),
        const SizedBox(height: 12),
        for (var i = 0; i < article.keyPoints.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}',
                    style: AppText.body.copyWith(
                      fontSize: 17,
                      color: AppColors.voice,
                      fontWeight: FontWeight.w700,
                      fontFeatures: AppFonts.tabular,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.tr(article.keyPoints[i]),
                    style: AppText.body.copyWith(fontSize: 17, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        Text(context.tr('When to get help'), style: AppText.title),
        const SizedBox(height: 12),
        for (final (level, text) in article.whenToGetHelp) ...[
          _HelpRow(level: level, text: text),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        Text(
          context.tr(
            'General guidance from Mother AI, not a medical service. If you’re '
            'worried, talk to your GP or health visitor.',
          ),
          style: AppText.secondary,
        ),
      ],
    );
  }
}

/// One rung of "when to get help", in the same colours chat answers use.
class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.level, required this.text});

  final CareLevel level;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: level.tint,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 28,
                child: Icon(level.icon, size: 15, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(level.label),
                    style: AppText.rowTitle.copyWith(
                      color: level.deep,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.tr(text),
                    style: AppText.body.copyWith(fontSize: 15, height: 1.45),
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
