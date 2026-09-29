import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/data/app_scope.dart';
import '../../core/l10n/l10n.dart';
import '../../core/l10n/text_direction.dart';
import '../../core/models/ask_topic.dart';
import '../../core/models/child_profile.dart';
import '../../core/models/conversation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/beneath_island.dart';
import '../../core/widgets/care.dart';
import '../../core/widgets/child_switch.dart';
import '../../core/widgets/directional_icons.dart';
import '../../core/widgets/rolling_template.dart';
import '../chat/chat_page.dart';
import '../chat/widgets/ask_composer.dart';
import '../chat/widgets/child_picker_sheet.dart';
import '../chat/widgets/topic_chips.dart';
import '../learn/open_article.dart';
import '../learn/articles.dart';
import '../profile/child_form_page.dart';
import 'widgets/morning_leaves.dart';

/// Home asks. One question, about one child, in a lavender morning with the
/// composer as its one primary action. Below it: topics to start from, the
/// conversation to pick back up, where the child is right now, and two
/// things worth reading for that stage.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onSwitchTab});

  /// Lets Home hand off to another tab ("See all" opens Chats or Learn).
  final ValueChanged<int> onSwitchTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  AskTopic? _topic;

  /// Who the question is about: the child chosen, else the first child, or
  /// nobody once the parent has picked a general question. Kept as an id,
  /// so an edit or a removal elsewhere shows up here.
  int? _childId;
  bool _general = false;

  ChildProfile? get _child {
    final store = AppScope.of(context, listen: false);
    if (_general) return null;
    return store.child(_childId) ?? store.children.firstOrNull;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _ask() {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    final topic = _topic;
    final child = _child;
    _controller.clear();
    setState(() => _topic = null);
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          initialPrompt: question,
          selectedChild: child,
          topic: topic,
        ),
      ),
    );
  }

  void _chooseTopic(AskTopic? topic) {
    setState(() => _topic = topic);
    if (topic != null) _focusNode.requestFocus();
  }

  void _read(Article article) => openArticle(context, article);

  void _select(ChildProfile? child) => setState(() {
    _general = child == null;
    _childId = child?.id;
  });

  Future<void> _chooseChild() async {
    final choice = await pickChild(context, current: _child);
    if (!mounted || choice == null) return;
    _select(choice.child);
  }

  Future<void> _addChild() async {
    final child = await editChild(context);
    if (mounted && child != null) _select(child);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final child = _child;
    final latest = store.latestFor(child);
    return ListView(
      padding: const EdgeInsets.only(bottom: 128),
      children: [
        _Morning(
          child: child,
          topic: _topic,
          controller: _controller,
          focusNode: _focusNode,
          onChildTap: _chooseChild,
          onSend: _ask,
        ),
        _Column(
          children: [
            // Until there is a child, adding one comes first after the
            // question: every answer is better for it.
            if (store.children.isEmpty) ...[
              _AddChild(onAdd: _addChild),
              const SizedBox(height: 36),
            ],
            _SectionHead(context.tr('Start from a topic')),
            const SizedBox(height: 14),
            TopicChips(selected: _topic, onSelected: _chooseTopic),
            const SizedBox(height: 36),
            if (latest != null) ...[
              _SectionHead(
                context.tr('Continue where you left off'),
                onSeeAll: () => widget.onSwitchTab(1),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1, color: AppColors.line),
              _ContinueRow(
                conversation: latest,
                onTap: () => openConversation(context, latest),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.line),
              const SizedBox(height: 36),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: AppMotion.settle,
              // Over the ground with a veil, not an opacity layer.
              transitionBuilder: (panel, animation) => AnimatedBuilder(
                animation: animation,
                child: panel,
                builder: (context, panel) =>
                    GroundVeil(visible: animation.value, child: panel!),
              ),
              child: child == null
                  ? const SizedBox(key: ValueKey('no-stage'), width: 0)
                  : Padding(
                      key: ValueKey(child.id),
                      padding: const EdgeInsets.only(bottom: 36),
                      child: _Stage(child: child),
                    ),
            ),
            _SectionHead(
              context.tr('Worth reading'),
              onSeeAll: () => widget.onSwitchTab(2),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, article) in _readingFor(child).indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: _ArticleTile(
                      article: article,
                      onTap: () => _read(article),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The two articles Home puts forward for the child's stage: growth
/// spurts for a baby, discipline for a toddler, and bedtime for both.
List<Article> _readingFor(ChildProfile? child) => switch (child?.months) {
  null => [moreArticles[0], moreArticles[1]],
  < 12 => [featuredArticle, moreArticles[1]],
  _ => [moreArticles[2], moreArticles[1]],
};

/// "Good afternoon", by the phone's clock.
String _greeting(DateTime now) => switch (now.hour) {
  < 12 => 'Good morning',
  < 18 => 'Good afternoon',
  _ => 'Good evening',
};

/// Home's content column: centred, phone-width on tablet, 24px gutters.
class _Column extends StatelessWidget {
  const _Column({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// A section's heading, with "See all" when there is more elsewhere.
class _SectionHead extends StatelessWidget {
  const _SectionHead(this.title, {this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final onSeeAll = this.onSeeAll;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: AppText.section),
            ),
          ),
          if (onSeeAll != null)
            ShadButton.link(
              size: ShadButtonSize.sm,
              padding: EdgeInsets.zero,
              height: 32,
              foregroundColor: AppColors.voiceDeep,
              hoverForegroundColor: AppColors.voice,
              gap: 2,
              trailing: Icon(context.forwardChevron, size: 16),
              onPressed: onSeeAll,
              child: Text(context.tr('See all')),
            ),
        ],
      ),
    );
  }
}

/// The lavender morning the question is asked in. It runs up under the
/// status bar and fades into the milk ground, with a sprig of leaves
/// reaching in from the trailing edge (see [MorningLeaves]).
class _Morning extends StatelessWidget {
  const _Morning({
    required this.child,
    required this.topic,
    required this.controller,
    required this.focusNode,
    required this.onChildTap,
    required this.onSend,
  });

  final ChildProfile? child;
  final AskTopic? topic;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChildTap;
  final VoidCallback onSend;

  static const _wash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.mist, AppColors.mist, AppColors.ground],
    stops: [0, 0.45, 1],
  );

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pulling Home down past the top shows more morning, not a seam.
          const Positioned(
            left: 0,
            right: 0,
            top: -600,
            height: 601,
            child: ColoredBox(color: AppColors.mist),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: _wash),
              child: ClipRect(
                // The sprig reaches in from the trailing edge, so it is drawn
                // from the left when the language reads from the right.
                child: Transform.flip(
                  flipX: Directionality.of(context) == TextDirection.rtl,
                  child: ListenableBuilder(
                    listenable: focusNode,
                    builder: (context, _) => MorningLeaves(
                      hue: child?.hue ?? AppColors.voice,
                      listening: focusNode.hasFocus,
                      typing: controller,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _Column(
            children: [
              SizedBox(height: top + 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _ChildPill(child: child, onTap: onChildTap),
              ),
              const SizedBox(height: 28),
              _Headline(child: child),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  '{greeting}. Ask in your own words, and you’ll hear plainly '
                  'when it needs a doctor.',
                  {'greeting': context.tr(_greeting(DateTime.now()))},
                ),
                style: AppText.secondary.copyWith(fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 24),
              AskComposer(
                fieldKey: const Key('motherPromptField'),
                controller: controller,
                focusNode: focusNode,
                raised: true,
                leading: ComposerTopicMark(topic: topic),
                placeholder:
                    topic?.placeholder(context.l10n, child) ??
                    (child == null
                        ? context.tr('Ask Mother AI anything')
                        : context.tr('Ask anything about {name}', {
                            'name': child.name,
                          })),
                onSend: onSend,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ],
      ),
    );
  }
}

/// Who the question is about, and the control that changes it. On a
/// change of child the monogram turns over into the new one, the name and
/// age roll to theirs, and the pill eases to its new width.
class _ChildPill extends StatelessWidget {
  const _ChildPill({required this.child, required this.onTap});

  final ChildProfile? child;
  final VoidCallback onTap;

  static const _shape = StadiumBorder(side: BorderSide(color: AppColors.line));

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    return Semantics(
      container: true,
      button: true,
      label: child == null
          ? context.tr(
              'Asking about nobody in particular. Change who this is about',
            )
          : context.tr('Asking about {name}. Change who this is about', {
              'name': child.name,
            }),
      child: Material(
        color: Colors.white,
        shape: _shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 14, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChildLabel(
                    child: child,
                    badge: 34,
                    gap: 10,
                    name: AppText.rowTitle.copyWith(fontSize: 15),
                    age: AppText.figure.copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: AppColors.muted,
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

/// The screen's one headline. Only the name in it changes with the child:
/// it rolls letter by letter into the next one, in their hue, and whatever
/// follows it slides along with the new width.
class _Headline extends StatelessWidget {
  const _Headline({required this.child});

  final ChildProfile? child;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final template = context.tr('What’s on your mind\nabout {name}?');
    final values = {'name': child?.name ?? context.tr('your family')};
    return Semantics(
      container: true,
      header: true,
      label: RollingTemplate.plain(template, values),
      child: ExcludeSemantics(
        child: RollingTemplate(
          template: template,
          values: values,
          style: AppText.tune(
            AppText.display.copyWith(
              fontSize: 38,
              height: 1.06,
              letterSpacing: -1.3,
            ),
          ),
          colours: {'name': child?.hue ?? AppColors.voiceDeep},
        ),
      ),
    );
  }
}

/// The conversation to pick back up: its topic, what was asked, when, and
/// the care level it reached.
class _ContinueRow extends StatelessWidget {
  const _ContinueRow({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topic = conversation.topic;
    final care = conversation.care;
    // Short enough to sit at the end of the title: the time today, then
    // "Yesterday", then the date.
    final when = conversation.bucket == DayBucket.yesterday
        ? context.tr(DayBucket.yesterday.label)
        : conversation.time(context.l10n);
    final preview = conversation.preview;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Its topic's square, or Mother AI's own when it had none.
            DecoratedBox(
              decoration: BoxDecoration(
                color: topic?.tint ?? AppColors.voiceTint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SizedBox.square(
                dimension: 64,
                child: Icon(
                  topic?.icon ?? LucideIcons.messageCircle,
                  size: 26,
                  color: topic?.tone ?? AppColors.voice,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title,
                          textDirection: directionOfText(conversation.title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.rowTitle.copyWith(fontSize: 17),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(when, style: AppText.figure),
                    ],
                  ),
                  if (preview.isNotEmpty || care != null) ...[
                    const SizedBox(height: 6),
                    // The care level leads the answer it came with, on its
                    // first line.
                    Text.rich(
                      TextSpan(
                        children: [
                          if (care != null) ...[
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: CarePill(level: care),
                            ),
                            if (preview.isNotEmpty) const TextSpan(text: '  '),
                          ],
                          TextSpan(text: preview),
                        ],
                      ),
                      textDirection: preview.isEmpty
                          ? null
                          : directionOfText(preview),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.secondary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(context.forwardChevron, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Before any child is added: what adding one does, and the way to do it.
/// It sits where the child's own panel will, on Mother AI's tint.
class _AddChild extends StatelessWidget {
  const _AddChild({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: AppColors.voiceTint,
        child: Stack(
          children: [
            PositionedDirectional(
              top: -6,
              end: -10,
              width: 132,
              height: 120,
              child: CustomPaint(
                painter: _SprigPainter(AppColors.voice.withValues(alpha: 0.16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('Add your child'), style: AppText.title),
                  const SizedBox(height: 6),
                  Padding(
                    // Clear of the sprig.
                    padding: const EdgeInsetsDirectional.only(end: 72),
                    child: Text(
                      context.tr(
                        'Mother AI fits every answer to their age, allergies and health.',
                      ),
                      style: AppText.secondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ShadButton(
                    leading: const Icon(LucideIcons.plus, size: 18),
                    onPressed: onAdd,
                    child: Text(context.tr('Add a child')),
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

/// Where the child is right now: a few plain facts for their age, on their
/// own tint with a sprig of their hue. Context for the question, not a
/// question itself.
class _Stage extends StatelessWidget {
  const _Stage({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: child.hueTint,
        child: Stack(
          children: [
            PositionedDirectional(
              top: -6,
              end: -10,
              width: 132,
              height: 120,
              child: CustomPaint(
                painter: _SprigPainter(child.hue.withValues(alpha: 0.16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: templateSpans(
                        context.tr('{name} at {age}'),
                        {'name': child.name, 'age': context.l10n.age(child)},
                        styles: {'age': TextStyle(color: child.hue)},
                      ),
                    ),
                    style: AppText.title.copyWith(
                      fontFeatures: AppFonts.tabular,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('What’s typical right now'),
                    style: AppText.secondary,
                  ),
                  const SizedBox(height: 14),
                  for (final fact in child.stage)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: child.hue,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(dimension: 8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(context.tr(fact), style: AppText.body),
                          ),
                        ],
                      ),
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

/// A young sprout: a stem and two leaves opening from it.
class _SprigPainter extends CustomPainter {
  const _SprigPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final stem = Path()
      ..moveTo(w * 0.52, h)
      ..quadraticBezierTo(w * 0.50, h * 0.62, w * 0.56, h * 0.36);
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    final base = Offset(w * 0.55, h * 0.44);
    for (final (angle, length) in [(-2.55, w * 0.46), (-0.55, w * 0.50)]) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      final half = length * 0.2;
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(length * 0.2, -half * 1.2, length * 0.65, -half, length, 0)
          ..cubicTo(length * 0.65, half, length * 0.2, half * 1.2, 0, 0),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SprigPainter old) => old.color != color;
}

/// One article for this stage: its photo, its title and how long it takes.
class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr('{title}. {minutes} minute read', {
        'title': context.tr(article.title),
        'minutes': article.minutes!,
      }),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                flightShuttleBuilder: flyBeneathIsland,
                tag: article.imagePath!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    // The same full-size photo the article opens with, so
                    // the flight back is one image the whole way. A decode
                    // sized from layout would be asked for at a new size on
                    // every frame of the flight, which blanked the first
                    // close until those sizes had been cached.
                    child: Image.asset(article.imagePath!, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(article.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.rowTitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    LucideIcons.bookOpen,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      context.tr('{minutes} min read', {
                        'minutes': article.minutes!,
                      }),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.figure,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
