import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/l10n/l10n.dart';
import '../../core/models/ask_topic.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/beneath_island.dart';
import '../../core/widgets/directional_icons.dart';
import '../../core/widgets/text_menu.dart';
import '../chat/chat_page.dart';
import 'articles.dart';
import 'open_article.dart';
import 'widgets/article_meta.dart';

/// The Learn tab: search and topics up top, a lead article with its photo,
/// then the rest. Most are read in the app; links to pages elsewhere look
/// different and open in the browser. When nothing matches, Mother AI
/// offers to answer the question instead.
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  final _search = TextEditingController();
  AskTopic? _topic;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Article article) {
    if (_topic != null && article.topic != _topic) return false;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    // Searched in the words the parent reads.
    return context.tr(article.title).toLowerCase().contains(query) ||
        context.tr(article.summary).toLowerCase().contains(query) ||
        context.tr(article.topic.label).toLowerCase().contains(query);
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  void _askInstead() {
    final query = _query.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // The search goes in the field for the parent to finish; a topic
        // only frames the chat when there was nothing typed.
        builder: (_) => ChatPage(
          initialDraft: query.isEmpty ? null : query,
          topic: query.isEmpty ? _topic : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final found = learnLibrary.where(_matches).toList();
    // A lead needs a photo, and a search reads better as a plain list.
    final lead = _query.trim().isEmpty
        ? found.where((a) => a.imagePath != null).firstOrNull
        : null;
    final rest = [
      for (final article in found)
        if (!identical(article, lead)) article,
    ];

    return SafeArea(
      bottom: false,
      // The column is phone-width and centred, but the topic row runs to the
      // screen's edges, so on a tablet it still reads as something to scroll.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(24.0, (constraints.maxWidth - 560) / 2 + 24);
          Widget pad(Widget child) => Padding(
            padding: EdgeInsets.symmetric(horizontal: side),
            child: child,
          );
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(top: 24, bottom: 128),
            children: [
              pad(Text(context.tr('Learn'), style: AppText.display)),
              const SizedBox(height: 8),
              pad(
                Text(
                  context.tr('Guides for every stage, in plain words.'),
                  style: AppText.secondary,
                ),
              ),
              const SizedBox(height: 20),
              pad(
                _SearchField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: _clearSearch,
                ),
              ),
              const SizedBox(height: 14),
              _TopicFilter(
                inset: side,
                selected: _topic,
                onSelected: (topic) => setState(() => _topic = topic),
              ),
              const SizedBox(height: 24),
              pad(
                _Results(
                  key: ValueKey('${_topic?.name}|${_query.trim()}'),
                  lead: lead,
                  rest: rest,
                  query: _query.trim(),
                  topic: _topic,
                  onOpen: (article) => openArticle(context, article),
                  onAsk: _askInstead,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  static const _border = ShadBorder(
    radius: BorderRadius.all(Radius.circular(AppTheme.radius)),
  );

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      contextMenuBuilder: textMenu,
      controller: controller,
      placeholder: Text(context.tr('Search guides and topics')),
      style: AppText.body,
      placeholderStyle: AppText.body.copyWith(color: AppColors.muted),
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      padding: const EdgeInsetsDirectional.fromSTEB(14, 4, 4, 4),
      constraints: const BoxConstraints(minHeight: 48),
      crossAxisAlignment: CrossAxisAlignment.center,
      decoration: const ShadDecoration(
        color: AppColors.panel,
        border: _border,
        focusedBorder: _border,
      ),
      leading: const Icon(LucideIcons.search, size: 18, color: AppColors.muted),
      trailing: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox(height: 40)
            : ShadIconButton.ghost(
                width: 40,
                height: 40,
                iconSize: 16,
                foregroundColor: AppColors.muted,
                icon: Icon(
                  LucideIcons.x,
                  semanticLabel: context.tr('Clear search'),
                ),
                onPressed: onClear,
              ),
      ),
    );
  }
}

/// "All" and the five topics, in a row that runs off the edge so it reads
/// as something to scroll. A chosen chip slides fully into view.
class _TopicFilter extends StatefulWidget {
  const _TopicFilter({
    required this.inset,
    required this.selected,
    required this.onSelected,
  });

  /// Where the first chip starts, in line with the column.
  final double inset;

  final AskTopic? selected;
  final ValueChanged<AskTopic?> onSelected;

  @override
  State<_TopicFilter> createState() => _TopicFilterState();
}

class _TopicFilterState extends State<_TopicFilter> {
  final _keys = {for (final topic in AskTopic.values) topic: GlobalKey()};

  void _choose(AskTopic? topic) {
    widget.onSelected(topic);
    final key = topic == null ? null : _keys[topic];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chip = key?.currentContext;
      if (chip == null || !chip.mounted) return;
      Scrollable.ensureVisible(
        chip,
        alignment: 0.5,
        duration: const Duration(milliseconds: 420),
        curve: AppMotion.settle,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: widget.inset),
        children: [
          _FilterChip(
            topic: null,
            selected: selected == null,
            onTap: () => _choose(null),
          ),
          for (final topic in AskTopic.values) ...[
            const SizedBox(width: 8),
            _FilterChip(
              key: _keys[topic],
              topic: topic,
              selected: selected == topic,
              onTap: () => _choose(selected == topic ? null : topic),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.topic,
    required this.selected,
    required this.onTap,
  });

  /// Null is "All".
  final AskTopic? topic;
  final bool selected;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final topic = this.topic;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: _duration,
        curve: AppMotion.settle,
        decoration: ShapeDecoration(
          color: selected ? AppColors.voice : AppColors.ground,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? AppColors.voice : AppColors.line,
            ),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                topic == null ? 18 : 5,
                0,
                16,
                0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (topic != null) ...[
                    AnimatedContainer(
                      duration: _duration,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0x33FFFFFF) : topic.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        topic.icon,
                        size: 15,
                        color: selected ? Colors.white : topic.tone,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    context.tr(topic?.label ?? 'All'),
                    style: AppText.rowTitle.copyWith(
                      fontSize: 14,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the search and topic turn up. A new filter's results rise into
/// place over the ground.
class _Results extends StatelessWidget {
  const _Results({
    super.key,
    required this.lead,
    required this.rest,
    required this.query,
    required this.topic,
    required this.onOpen,
    required this.onAsk,
  });

  final Article? lead;
  final List<Article> rest;
  final String query;
  final AskTopic? topic;
  final ValueChanged<Article> onOpen;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final lead = this.lead;
    final Widget content;
    if (lead == null && rest.isEmpty) {
      content = _Empty(query: query, topic: topic, onAsk: onAsk);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lead != null) ...[
            _LeadArticle(article: lead, onTap: () => onOpen(lead)),
            const SizedBox(height: 32),
          ],
          if (rest.isNotEmpty) ...[
            Text(
              lead == null
                  ? context.tr('{n} to read', {'n': rest.length})
                  : context.tr('More to read'),
              style: AppText.section,
            ),
            const SizedBox(height: 6),
            for (final (i, article) in rest.indexed)
              _ArticleRow(
                article: article,
                divider: i != 0,
                onTap: () => onOpen(article),
              ),
          ],
        ],
      );
    }
    return content.maybeAnimate(
      context,
      (content) => content
          .animate()
          .veilIn(duration: 240.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.03,
            end: 0,
            duration: 420.ms,
            curve: AppMotion.settle,
          ),
    );
  }
}

/// The lead: a large photo carrying its topic, then the title, what the
/// article will tell you, and the way in.
class _LeadArticle extends StatelessWidget {
  const _LeadArticle({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = article.imagePath!;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  flightShuttleBuilder: flyBeneathIsland,
                  tag: image,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.2, 0),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  top: 12,
                  child: _TopicTag(topic: article.topic),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(article.title),
                        style: AppText.title.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(article.summary),
                        style: AppText.secondary.copyWith(
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('{minutes} min read', {
                          'minutes': article.minutes!,
                        }),
                        style: AppText.figure,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.voiceTint,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: 48,
                      child: Icon(
                        context.forwardArrow,
                        size: 20,
                        color: AppColors.voice,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The lead article's topic, set on its photo so it isn't said twice.
class _TopicTag extends StatelessWidget {
  const _TopicTag({required this.topic});

  final AskTopic topic;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.ground,
        shape: StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 7, 12, 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(topic.icon, size: 15, color: topic.tone),
            const SizedBox(width: 6),
            Text(
              context.tr(topic.label),
              style: AppText.label.copyWith(color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// One item in the list: its picture, title, what it covers and how long it
/// is. A link elsewhere shows its topic in place of a photo, with the mark
/// for "opens a website" in both its corner and its trailing arrow.
class _ArticleRow extends StatelessWidget {
  const _ArticleRow({
    required this.article,
    required this.divider,
    required this.onTap,
  });

  final Article article;
  final bool divider;
  final VoidCallback onTap;

  static const thumb = 84.0;

  @override
  Widget build(BuildContext context) {
    final image = article.imagePath;
    final outside = article.opensOutside;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? const Border(top: BorderSide(color: AppColors.line))
            : null,
      ),
      child: Semantics(
        button: true,
        link: outside,
        hint: outside ? context.tr('Opens a website') : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                if (image != null)
                  Hero(
                    flightShuttleBuilder: flyBeneathIsland,
                    tag: image,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      // Full size, shared with the article it opens: the
                      // photo flies back into this square without going
                      // soft or being decoded again.
                      child: Image.asset(
                        image,
                        width: thumb,
                        height: thumb,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  _LinkThumb(topic: article.topic),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(article.title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.rowTitle.copyWith(fontSize: 16.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(article.summary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.secondary,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            article.topic.icon,
                            size: 14,
                            color: article.topic.tone,
                          ),
                          const SizedBox(width: 6),
                          Flexible(child: ArticleMeta(article: article)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  outside ? context.outArrow : context.forwardChevron,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A link's picture: its topic's square, marked in the corner as a page
/// elsewhere.
class _LinkThumb extends StatelessWidget {
  const _LinkThumb({required this.topic});

  final AskTopic topic;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _ArticleRow.thumb,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: topic.tint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Center(child: Icon(topic.icon, size: 30, color: topic.tone)),
            const PositionedDirectional(
              end: 6,
              bottom: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 24,
                  child: Icon(
                    LucideIcons.globe,
                    size: 13,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nothing matched. Learn doesn't leave it there: Mother AI can answer.
class _Empty extends StatelessWidget {
  const _Empty({required this.query, required this.topic, required this.onAsk});

  final String query;
  final AskTopic? topic;
  final VoidCallback onAsk;

  /// Says what was looked for, filter included.
  String _headline(BuildContext context) {
    final topic = this.topic;
    final args = {
      'topic': topic == null ? '' : context.tr(topic.label),
      'query': query,
    };
    return context.tr(switch ((topic != null, query.isNotEmpty)) {
      (false, false) => 'No guides yet',
      (true, false) => 'No {topic} guides yet',
      (false, true) => 'No guides on “{query}” yet',
      (true, true) => 'No {topic} guides on “{query}” yet',
    }, args);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.voiceTint,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: SizedBox.square(
              dimension: 52,
              child: Icon(
                LucideIcons.sparkles,
                size: 22,
                color: AppColors.voice,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(_headline(context), style: AppText.title),
          const SizedBox(height: 6),
          Text(
            context.tr(
              'Mother AI can still answer it for you, in plain words.',
            ),
            style: AppText.secondary,
          ),
          const SizedBox(height: 18),
          ShadButton(
            leading: const Icon(LucideIcons.messageCircle, size: 18),
            onPressed: onAsk,
            child: Text(context.tr('Ask Mother AI')),
          ),
        ],
      ),
    );
  }
}
