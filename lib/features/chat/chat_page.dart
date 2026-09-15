import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.title = 'Chat',
    this.subtitle = 'Always here for you',
    this.initialMessages = const [],
    this.initialPrompt,
  });

  /// Header title, e.g. a past conversation's topic.
  final String title;
  final String subtitle;

  /// A past conversation's messages, shown immediately instead of the
  /// welcome/suggestions screen.
  final List<ChatMessage> initialMessages;

  /// A message to send as soon as the page opens, for starting a brand new
  /// conversation straight from a prompt typed elsewhere in the app.
  final String? initialPrompt;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final _messages = List<ChatMessage>.of(widget.initialMessages);

  static const _suggestions = <_Suggestion>[
    _Suggestion(
      label: 'Fever & symptoms',
      prompt: 'My child has a fever. What symptoms should I watch for?',
      icon: Icons.device_thermostat_rounded,
      foreground: Color(0xFFF16468),
      background: Color(0xFFFFE8E6),
      cardColor: Color(0xFFFFF5F3),
    ),
    _Suggestion(
      label: 'Sleep help',
      prompt: 'Can you help me with my child’s sleep?',
      icon: Icons.bedtime_outlined,
      foreground: Color(0xFF4564E7),
      background: Color(0xFFE9EEFF),
      cardColor: Color(0xFFF3F6FF),
    ),
    _Suggestion(
      label: 'Development milestones',
      prompt: 'Which development milestones should I know about?',
      icon: Icons.eco_outlined,
      foreground: Color(0xFF2FA87B),
      background: Color(0xFFE4F7F0),
      cardColor: Color(0xFFF1FBF7),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(prompt));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? suggestedPrompt]) {
    final text = (suggestedPrompt ?? _controller.text).trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text, isMine: true));
      _messages.add(
        const ChatMessage(
          'I’m here with you. Mother AI can offer general guidance, but urgent or worrying symptoms should always be checked by a healthcare professional.',
          isMine: false,
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _FixedWatercolorBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    _ChatHeader(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: _messages.isEmpty
                          ? _WelcomeContent(
                              suggestions: _suggestions,
                              onSuggestionTap: _send,
                            )
                          : _Conversation(
                              controller: _scrollController,
                              messages: _messages,
                            ),
                    ),
                    _Composer(controller: _controller, onSend: _send),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixedWatercolorBackground extends StatelessWidget {
  const _FixedWatercolorBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: Image.asset(
          'assets/images/chat_watercolor_background.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 24, 18),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Back',
            child: Material(
              color: Colors.white.withValues(alpha: 0.72),
              shape: const CircleBorder(
                side: BorderSide(color: Color(0xCCFFFFFF)),
              ),
              elevation: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox.square(
                  dimension: 46,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 21,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<_Suggestion> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(18, compact ? 10 : 18, 18, 18),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFE8E1FF)],
                            ),
                            border: Border.all(color: Colors.white, width: 1.2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x18956EDC),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/heart.svg',
                            width: 29,
                            height: 29,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF7657EB),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _WelcomeBubble(compact: compact)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Transform.rotate(
                          angle: -0.08,
                          child: const Text(
                            'You’re not alone\nin this  ♡',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.whisper,
                              fontSize: 15,
                              height: 1.15,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 26),
                    _SuggestionRow(
                      suggestions: suggestions,
                      onTap: onSuggestionTap,
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: compact ? 12 : 20,
                        bottom: compact ? 10 : 22,
                      ),
                      child: Transform.rotate(
                        angle: -0.07,
                        child: const Text(
                          'Kinder days.\nBrighter tomorrows.  ♡',
                          style: TextStyle(
                            color: AppColors.whisper,
                            fontSize: 15,
                            height: 1.12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(17, compact ? 15 : 18, 15, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.82),
            const Color(0xFFF3EEFF).withValues(alpha: 0.74),
            const Color(0xFFFFFAFD).withValues(alpha: 0.78),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D2350),
            blurRadius: 28,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi there! I’m Mother AI.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: compact ? 18 : 19.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ask me anything about your child’s health, sleep, development, or parenting.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.3),
          ),
          const SizedBox(height: 7),
          const Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFFFFA2A6),
            size: 21,
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.suggestions, required this.onTap});

  final List<_Suggestion> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    // The welcome content lives in a SliverFillRemaining (which measures
    // intrinsics), so a LayoutBuilder here is not allowed. Derive the row width
    // from the screen instead: it just needs to cap an over-long pill so its
    // label ellipsizes rather than overflowing.
    final screenWidth = MediaQuery.of(context).size.width;
    final maxChipWidth = (screenWidth > 620 ? 620.0 : screenWidth) - 36;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 11),
          child: Text('Try asking', style: Theme.of(context).textTheme.labelSmall),
        ),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final suggestion in suggestions)
              _SuggestionChip(
                suggestion: suggestion,
                maxWidth: maxChipWidth,
                onTap: () => onTap(suggestion.prompt),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.suggestion,
    required this.maxWidth,
    required this.onTap,
  });

  final _Suggestion suggestion;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Material(
        color: suggestion.cardColor.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(7, 7, 15, 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: suggestion.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.foreground,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    suggestion.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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

class _Conversation extends StatelessWidget {
  const _Conversation({required this.controller, required this.messages});

  final ScrollController controller;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final message = messages[index];
        return Align(
          alignment: message.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
            decoration: BoxDecoration(
              color: message.isMine
                  ? const Color(0xFFEAE2FF).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(21),
                topRight: const Radius.circular(21),
                bottomLeft: Radius.circular(message.isMine ? 21 : 5),
                bottomRight: Radius.circular(message.isMine ? 5 : 21),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F1A2D60),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isMine ? AppColors.navy : AppColors.inkMuted,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(33),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x190D2350),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Add attachment',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F3FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.inkMuted,
                    size: 29,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: TextField(
                key: const Key('chatMessageField'),
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: AppColors.navy, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Ask Mother AI anything...',
                  hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 16),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: 'Send message',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSend,
                  child: Ink(
                    width: 49,
                    height: 49,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8499F3), Color(0xFFC078D8)],
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
          ],
        ),
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.label,
    required this.prompt,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.cardColor,
  });

  final String label;
  final String prompt;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color cardColor;
}

class ChatMessage {
  const ChatMessage(this.text, {required this.isMine});

  final String text;
  final bool isMine;
}
