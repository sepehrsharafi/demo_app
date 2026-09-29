import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/ai/context_keeper.dart';
import '../../core/ai/mother_ai.dart';
import '../../core/ai/system_prompt.dart';
import '../../core/data/app_scope.dart';
import '../../core/data/app_store.dart';
import '../../core/l10n/l10n.dart';
import '../../core/l10n/text_direction.dart';
import '../../core/models/ask_topic.dart';
import '../../core/models/child_profile.dart';
import '../../core/models/conversation.dart';
import '../../core/models/reply.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/care.dart';
import '../../core/widgets/child_switch.dart';
import '../../core/widgets/directional_icons.dart';
import '../../core/widgets/mother_mark.dart';
import '../../core/widgets/rolling_template.dart';
import '../../core/widgets/sheet_depth.dart';
import '../profile/child_sheet.dart';
import 'widgets/ask_composer.dart';
import 'widgets/child_picker_sheet.dart';
import 'widgets/prompt_list.dart';
import 'widgets/topic_chips.dart';

/// Opens a past conversation. Its messages are read first, which takes a
/// few milliseconds, so the page never opens empty.
Future<void> openConversation(
  BuildContext context,
  Conversation conversation,
) async {
  final store = AppScope.of(context, listen: false);
  final navigator = Navigator.of(context);
  final messages = await store.messages(conversation.id);
  await navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => ChatPage(
        conversation: conversation,
        initialMessages: messages,
        selectedChild: store.child(conversation.childId),
        topic: conversation.topic,
      ),
    ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.conversation,
    this.initialMessages = const [],
    this.initialPrompt,
    this.initialDraft,
    this.selectedChild,
    this.prompts,
    this.fromArticle,
    this.topic,
  });

  /// The past conversation being continued, if any; see [openConversation].
  final Conversation? conversation;

  /// Its messages, shown instead of the welcome.
  final List<ChatMessage> initialMessages;

  /// Sent as soon as the page opens, for a question typed on Home.
  final String? initialPrompt;

  /// Put in the field, not sent, so the parent finishes the question in
  /// their own words (a Learn search that found nothing, for example).
  final String? initialDraft;
  final ChildProfile? selectedChild;

  /// Questions to start from, e.g. an article's follow-ups. Without them a
  /// new chat offers topics instead.
  final List<String>? prompts;

  /// The article this chat was started from, if any.
  final String? fromArticle;

  /// The topic chosen before asking, if any.
  final AskTopic? topic;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  late final _messages = List<ChatMessage>.of(widget.initialMessages);
  late ChildProfile? _child = widget.selectedChild;
  late AskTopic? _topic = widget.topic;
  late int? _conversationId = widget.conversation?.id;
  late AppStore _store;
  late MotherAi _ai;

  /// Questions asked during this visit animate in; history does not.
  final _arrived = <ChatMessage>{};

  /// The answer being written, as far as it has got. Null when none is.
  final _live = ValueNotifier<String?>(null);
  final _written = StringBuffer();
  StreamSubscription<String>? _reply;
  bool _redrawQueued = false;

  /// Why the last question has no answer, when asking failed.
  String? _error;

  /// The latest answer after which the child's context changed, if any.
  ChatMessage? _remembered;

  /// Saves run in order, and never hold up an answer.
  Future<void> _saving = Future.value();

  @override
  void initState() {
    super.initState();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(prompt));
    }
    final draft = widget.initialDraft;
    if (draft != null && draft.trim().isNotEmpty) {
      _controller.text = draft;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = AppScope.of(context, listen: false);
    _ai = AppScope.aiOf(context);
  }

  @override
  void dispose() {
    // Leaving mid-answer stops it and closes the connection.
    _reply?.cancel();
    _live.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _busy => _reply != null;

  /// Who a chat is about is settled by its first question. Changing it
  /// afterwards would leave earlier answers about the wrong child.
  bool get _canChangeChild => _messages.isEmpty && !_busy;

  /// The last question has no answer: asking failed, or the app was closed
  /// before the answer came.
  bool get _unanswered =>
      !_busy && _messages.isNotEmpty && _messages.last.isMine;

  String _title(BuildContext context) =>
      _messages.where((m) => m.isMine).firstOrNull?.content ??
      context.tr('New chat');

  void _send([String? suggestedPrompt]) {
    final text = (suggestedPrompt ?? _controller.text).trim();
    if (_busy || text.isEmpty) return;

    FocusScope.of(context).unfocus();
    _controller.clear();
    final question = ChatMessage(text, isMine: true);
    setState(() {
      _messages.add(question);
      _arrived.add(question);
    });
    _save(question);
    _answer();
    _scrollToEnd();
  }

  /// Asks Mother AI to answer the last question.
  void _answer() {
    final child = _child;
    final answer = _ai.answer(
      history: List.of(_messages),
      context: questionContext(
        child: child,
        topic: _topic,
        language: _store.languageName,
        units: _store.units,
        article: widget.fromArticle,
        context: _store.contextOf(child),
        earlierChats: [
          if (child != null)
            for (final chat in _store.conversations)
              if (chat.childId == child.id && chat.id != _conversationId) chat,
        ],
      ),
    );
    _written.clear();
    setState(() {
      _error = null;
      _live.value = '';
      _reply = answer.listen(
        _write,
        onError: _fail,
        onDone: _finish,
        cancelOnError: true,
      );
    });
  }

  void _write(String words) {
    _written.write(words);
    if (_redrawQueued) return;
    _redrawQueued = true;
    // However fast the words come, the answer is redrawn once a frame, and
    // only the answer is.
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _redrawQueued = false;
      if (!mounted || !_busy) return;
      _live.value = _written.toString();
      _followEnd();
    });
  }

  void _finish() {
    final answer = ChatMessage(_written.toString().trim(), isMine: false);
    if (answer.reply.isEmpty) return _fail(MotherAiException.silent);
    setState(() {
      _reply = null;
      _live.value = null;
      _messages.add(answer);
    });
    _save(answer);
    _remember(answer);
  }

  /// Has Mother AI take what this exchange said about the child into their
  /// context, and says so under the answer when something changed.
  void _remember(ChatMessage answer) {
    final child = _child;
    if (child == null) return;
    ContextKeeper.review(
      store: _store,
      ai: _ai,
      child: child,
      history: List.of(_messages),
    ).then((update) {
      if (mounted && !update.isEmpty) setState(() => _remembered = answer);
    });
  }

  void _fail(Object error) {
    if (error is! MotherAiException) debugPrint('Mother AI failed: $error');
    setState(() {
      _reply = null;
      _live.value = null;
      _error = error is MotherAiException
          ? error.message
          : MotherAiException.failed.message;
    });
    _scrollToEnd();
  }

  void _retry() {
    if (_busy) return;
    _answer();
    _scrollToEnd();
  }

  /// The first message starts the conversation in the store; the rest are
  /// added to it.
  void _save(ChatMessage message) {
    final store = _store;
    final child = _child;
    final topic = _topic;
    _saving = _saving
        .then((_) async {
          final id = _conversationId;
          if (id == null) {
            _conversationId = await store.startConversation(
              message,
              child: child,
              topic: topic,
            );
          } else {
            await store.addMessage(id, message);
          }
        })
        .catchError((Object error) {
          debugPrint('Couldn’t save the chat: $error');
        });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: AppMotion.settle,
      );
    });
  }

  /// Keeps the end of a growing answer in view, unless the parent has
  /// scrolled up to read.
  void _followEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (position.maxScrollExtent - position.pixels < 160) {
        position.jumpTo(position.maxScrollExtent);
      }
    });
  }

  Future<void> _chooseChild() async {
    final choice = await pickChild(context, current: _child);
    if (!mounted || choice == null || !_canChangeChild) return;
    setState(() => _child = choice.child);
  }

  void _chooseTopic(AskTopic? topic) {
    setState(() => _topic = topic);
    if (topic != null) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return RecedeBehindSheets(child: _buildPage());
  }

  Widget _buildPage() {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                _Header(
                  title: _title(context),
                  child: _child,
                  topic: _topic,
                  onChildTap: _canChangeChild ? _chooseChild : null,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // A dip through the ground rather than a cross-fade: two
                    // full-screen opacity layers are what low-end GPUs choke
                    // on, and two veils cost a rectangle each.
                    transitionBuilder: _dipThroughGround,
                    child: _messages.isEmpty
                        ? _Welcome(
                            key: const ValueKey('welcome'),
                            child: _child,
                            prompts: widget.prompts,
                            fromArticle: widget.fromArticle,
                            onPrompt: _send,
                            topic: _topic,
                            onTopic: _chooseTopic,
                          )
                        : _Thread(
                            key: const ValueKey('thread'),
                            controller: _scrollController,
                            messages: _messages,
                            arrived: _arrived,
                            live: _busy ? _live : null,
                            unanswered: _unanswered
                                ? context.tr(
                                    _error ??
                                        'This question hasn’t been answered.',
                                  )
                                : null,
                            onRetry: _retry,
                            remembered: _remembered,
                            onRemembered: _child == null
                                ? null
                                : () => showChildSheet(context, _child!),
                            rememberedLabel: _child == null
                                ? null
                                : context.tr('{name}’s context updated', {
                                    'name': _child!.name,
                                  }),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: AskComposer(
                    fieldKey: const Key('chatMessageField'),
                    controller: _controller,
                    focusNode: _focusNode,
                    busy: _busy,
                    placeholder: _messages.isEmpty && _topic != null
                        ? _topic!.placeholder(context.l10n, _child)
                        : _child == null
                        ? context.tr('Ask Mother AI')
                        : context.tr('Ask about {name}', {
                            'name': _child!.name,
                          }),
                    onSend: _send,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// For an [AnimatedSwitcher] on the plain ground: the old child is covered
/// over the first half, then the new one uncovered over the second, so the
/// two are never both showing. Each child runs its own animation (the old
/// one in reverse), so one interval serves both.
Widget _dipThroughGround(Widget child, Animation<double> animation) =>
    AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => GroundVeil(
        visible: const Interval(0.5, 1).transform(animation.value),
        child: child!,
      ),
    );

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.child,
    required this.topic,
    required this.onChildTap,
  });

  final String title;
  final ChildProfile? child;
  final AskTopic? topic;

  /// Null once the chat has started, when who it is about is fixed.
  final VoidCallback? onChildTap;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final topic = this.topic;
    final onChildTap = this.onChildTap;
    final colour = child?.hue ?? AppColors.muted;
    final label = AppText.label.copyWith(
      color: colour,
      fontFeatures: AppFonts.tabular,
    );

    // The same badge, name and age Home's pill shows, turning over and
    // rolling to the next child in the same way.
    final subtitle = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChildLabel(
              child: child,
              badge: 20,
              gap: 6,
              name: label,
              age: label,
              shortAge: true,
            ),
            if (onChildTap != null) ...[
              const SizedBox(width: 2),
              Icon(LucideIcons.chevronDown, size: 16, color: colour),
            ],
            if (topic != null) ...[
              const SizedBox(width: 10),
              Icon(topic.icon, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(context.tr(topic.label), style: AppText.label),
            ],
          ],
        ),
      ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 16, 8),
        child: Row(
          children: [
            ShadIconButton.ghost(
              width: 44,
              height: 44,
              iconSize: 22,
              icon: Icon(
                context.backChevron,
                semanticLabel: context.tr('Back'),
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: _dipThroughGround,
                    layoutBuilder: (current, previous) => Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [...previous, ?current],
                    ),
                    child: Text(
                      title,
                      key: ValueKey(title),
                      textDirection: directionOfText(title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.rowTitle.copyWith(fontSize: 17),
                    ),
                  ),
                  Semantics(
                    container: true,
                    button: onChildTap != null,
                    label: [
                      child == null
                          ? context.tr('General question')
                          : context.tr('About {name}', {'name': child.name}),
                      if (topic != null) context.tr(topic.label),
                      if (onChildTap != null)
                        context.tr('Change who this is about'),
                    ].join('. '),
                    child: ExcludeSemantics(
                      child: onChildTap == null
                          ? subtitle
                          : InkWell(
                              onTap: onChildTap,
                              borderRadius: BorderRadius.circular(8),
                              child: subtitle,
                            ),
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

class _Welcome extends StatelessWidget {
  const _Welcome({
    super.key,
    required this.child,
    required this.prompts,
    required this.fromArticle,
    required this.onPrompt,
    required this.topic,
    required this.onTopic,
  });

  final ChildProfile? child;

  /// An article's follow-up questions. Without them the welcome offers
  /// topics, and the parent says what is happening themselves.
  final List<String>? prompts;
  final String? fromArticle;
  final ValueChanged<String> onPrompt;
  final AskTopic? topic;
  final ValueChanged<AskTopic?> onTopic;

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    final prompts = this.prompts;
    final fromArticle = this.fromArticle;
    final headline = context.tr('Ask me anything\nabout {name}.');
    final names = {'name': child?.name ?? context.tr('your family')};
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MotherMark(size: 44),
                const SizedBox(height: 20),
                // Only the name changes with the child, and it rolls into the
                // next one the way Home's headline does.
                Semantics(
                  container: true,
                  header: true,
                  label: RollingTemplate.plain(headline, names),
                  child: ExcludeSemantics(
                    child: RollingTemplate(
                      template: headline,
                      values: names,
                      style: AppText.display.copyWith(fontSize: 32),
                      colours: {'name': child?.hue ?? AppColors.voice},
                    ),
                  ),
                ),
                if (fromArticle != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.bookOpen,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('Picking up from “{article}”', {
                            'article': context.tr(fromArticle),
                          }),
                          style: AppText.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                if (prompts != null)
                  PromptList(prompts: prompts, onPrompt: onPrompt)
                else ...[
                  Text(context.tr('Start from a topic'), style: AppText.label),
                  const SizedBox(height: 12),
                  TopicChips(selected: topic, onSelected: onTopic),
                ],
                const Spacer(),
                const SizedBox(height: 24),
                Text(
                  context.tr(
                    'Mother AI gives general guidance and isn’t a medical '
                    'service. If you’re worried about breathing, alertness or '
                    'hydration, call your local emergency number.',
                  ),
                  style: AppText.secondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The conversation, run down one rail. Mother AI's answers sit on the rail;
/// the parent's questions hang off to the right.
class _Thread extends StatelessWidget {
  const _Thread({
    super.key,
    required this.controller,
    required this.messages,
    required this.arrived,
    required this.live,
    required this.unanswered,
    required this.onRetry,
    required this.remembered,
    required this.rememberedLabel,
    required this.onRemembered,
  });

  final ScrollController controller;
  final List<ChatMessage> messages;
  final Set<ChatMessage> arrived;

  /// The answer being written, while one is.
  final ValueListenable<String?>? live;

  /// Why the last question has no answer, when it hasn't.
  final String? unanswered;
  final VoidCallback onRetry;

  /// The answer after which the child's context changed, the note that
  /// says so, and what tapping it opens.
  final ChatMessage? remembered;
  final String? rememberedLabel;
  final VoidCallback? onRemembered;

  @override
  Widget build(BuildContext context) {
    final live = this.live;
    final unanswered = this.unanswered;
    final count =
        messages.length + (live != null || unanswered != null ? 1 : 0);
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 20, 24),
      itemCount: count,
      itemBuilder: (context, index) {
        final isLast = index == count - 1;
        if (index == messages.length) {
          return _RailItem(
            isLast: true,
            node: true,
            child: live != null
                // Only this rebuilds as the words arrive.
                ? ValueListenableBuilder(
                    valueListenable: live,
                    builder: (context, written, _) {
                      final reply = Reply.parse(written ?? '');
                      return reply.isEmpty && reply.care == null
                          ? const _Typing()
                          : _Answer(reply: reply, live: true);
                    },
                  )
                : _Unanswered(reason: unanswered!, onRetry: onRetry),
          );
        }
        final message = messages[index];
        return _RailItem(
          isFirst: index == 0,
          isLast: isLast,
          node: !message.isMine,
          child: message.isMine
              ? _Question(
                  message: message,
                  animate:
                      arrived.contains(message) &&
                      !MediaQuery.disableAnimationsOf(context),
                )
              : message == remembered && rememberedLabel != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Answer(reply: message.reply),
                    _Remembered(label: rememberedLabel!, onTap: onRemembered),
                  ],
                )
              : _Answer(reply: message.reply),
        );
      },
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.child,
    required this.node,
    this.isFirst = false,
    this.isLast = false,
  });

  final Widget child;

  /// Whether this item is Mother AI speaking, and so sits on the rail.
  final bool node;
  final bool isFirst;
  final bool isLast;

  static const _gutter = 40.0;
  static const _nodeSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PositionedDirectional(
          start: _nodeSize / 2 - 0.75,
          width: 1.5,
          top: isFirst ? _nodeSize / 2 : 0,
          bottom: isLast ? null : 0,
          height: isLast ? _nodeSize / 2 : null,
          child: const ColoredBox(color: AppColors.line),
        ),
        if (node)
          const PositionedDirectional(
            start: 0,
            top: 0,
            child: MotherMark(size: _nodeSize),
          ),
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: _gutter,
            bottom: isLast ? 0 : 20,
          ),
          child: child,
        ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({required this.message, required this.animate});

  final ChatMessage message;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final text = message.content;
    final bubble = Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.mist,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(20),
              topEnd: Radius.circular(20),
              bottomStart: Radius.circular(20),
              bottomEnd: Radius.circular(6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              textDirection: directionOfText(text),
              style: AppText.body,
            ),
          ),
        ),
      ),
    );
    if (!animate) return bubble;
    return bubble
        .animate()
        .veilIn(duration: 200.ms)
        .slideY(begin: 0.4, end: 0, duration: 380.ms, curve: AppMotion.settle)
        .scaleXY(
          begin: 0.96,
          end: 1,
          alignment: AlignmentDirectional.bottomEnd.resolve(
            Directionality.of(context),
          ),
        );
  }
}

/// An answer: its care level first, then what to know, then what to do.
///
/// While it is [live], each part rises in as it is written; once finished
/// it is drawn still, exactly where the live one ended.
class _Answer extends StatelessWidget {
  const _Answer({required this.reply, this.live = false});

  final Reply reply;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final care = reply.care;
    final animate = live && !MediaQuery.disableAnimationsOf(context);

    // Keyed, so parts already showing keep their place as new ones arrive.
    Widget arrive(String key, Widget child) {
      if (!animate) return KeyedSubtree(key: ValueKey(key), child: child);
      return child
          .animate(key: ValueKey(key))
          .veilIn(duration: 280.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 420.ms,
            curve: AppMotion.settle,
          );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (care != null) ...[
          CareStrip(key: const ValueKey('care'), level: care, reveal: animate),
          const SizedBox(height: 12),
        ],
        Directionality(
          textDirection: directionOfText('${reply.text} ${reply.steps.join()}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reply.text.isNotEmpty)
                arrive(
                  'text',
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(reply.text, style: AppText.body),
                  ),
                ),
              if (reply.steps.isNotEmpty) const SizedBox(height: 12),
              for (var i = 0; i < reply.steps.length; i++)
                arrive('step$i', _Step(number: i + 1, text: reply.steps[i])),
            ],
          ),
        ),
      ],
    );
  }
}

/// Under an answer: Mother AI took something from this exchange into the
/// child's context. Tapping it shows what it now remembers.
class _Remembered extends StatelessWidget {
  const _Remembered({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      liveRegion: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.bookmarkCheck,
                size: 15,
                color: AppColors.voice,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppText.label.copyWith(color: AppColors.voiceDeep),
                ),
              ),
              Icon(context.forwardChevron, size: 15, color: AppColors.voice),
            ],
          ),
        ),
      ),
    ).maybeAnimate(
      context,
      (note) => note
          .animate()
          .veilIn(duration: 280.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: 0.3,
            end: 0,
            duration: 420.ms,
            curve: AppMotion.settle,
          ),
    );
  }
}

/// Where an answer would be, when there isn't one: why, and a way to ask
/// again.
class _Unanswered extends StatelessWidget {
  const _Unanswered({required this.reason, required this.onRetry});

  final String reason;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            reason,
            style: AppText.body.copyWith(color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 10),
        ShadButton.outline(
          size: ShadButtonSize.sm,
          leading: const Icon(LucideIcons.rotateCcw, size: 16),
          onPressed: onRetry,
          child: Text(context.tr('Try again')),
        ),
      ],
    );
  }
}

/// A numbered step, its number held in the margin so the text aligns.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$number',
              style: AppText.body.copyWith(
                color: AppColors.voice,
                fontWeight: FontWeight.w700,
                fontFeatures: AppFonts.tabular,
              ),
            ),
          ),
          Expanded(child: Text(text, style: AppText.body)),
        ],
      ),
    );
  }
}

/// Mother AI thinking: three dots breathing in its colour.
class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr('Mother AI is writing'),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 5),
                child:
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.voice,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(dimension: 7),
                    ).maybeAnimate(
                      context,
                      (dot) => dot
                          .animate(
                            onPlay: (c) => c.repeat(reverse: true),
                            delay: (150 * i).ms,
                          )
                          .fadeIn(begin: 0.25, duration: 450.ms)
                          .scaleXY(begin: 0.7, end: 1, duration: 450.ms),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
