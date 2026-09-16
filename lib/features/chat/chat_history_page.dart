import 'package:flutter/material.dart';

import '../../core/models/child_profile.dart';
import '../../core/theme/app_theme.dart';
import 'chat_page.dart';

/// The Chat tab's body: a calm list of past conversations with a clear
/// primary action to start a new one. Tapping "new chat" or any conversation
/// opens the immersive [ChatPage] on top of the persistent app shell.
class ChatHistoryTab extends StatefulWidget {
  const ChatHistoryTab({super.key});

  @override
  State<ChatHistoryTab> createState() => _ChatHistoryTabState();
}

class _ChatHistoryTabState extends State<ChatHistoryTab> {
  final _searchController = TextEditingController();
  String _query = '';

  static final _conversations = <_Conversation>[
    _Conversation(
      title: 'Baby fever after vaccines',
      child: demoChildren[0],
      preview: 'My 6-month-old has a fever after their vaccines. Is this normal and how can I help them feel better?',
      time: '10:24 AM',
      icon: Icons.favorite_rounded,
      color: AppColors.coral,
      background: Color(0xFFFCE1DF),
      bucket: _Bucket.today,
      messages: [
        ChatMessage(
          'My 6-month-old has a fever after their vaccines. Is this normal and how can I help them feel better?',
          isMine: true,
        ),
        ChatMessage(
          'A mild fever within 24–48 hours after vaccines is common — it means their immune system is responding. Keep them hydrated, dress them lightly, and you can use infant acetaminophen if your pediatrician has approved it for their age and weight.',
          isMine: false,
        ),
        ChatMessage('Her temp is 100.9°F. Should I be worried?', isMine: true),
        ChatMessage(
          'That\'s still in the mild range for a post-vaccine fever. Keep watching her — call your pediatrician if it climbs above 102°F, lasts more than 48 hours, or she seems unusually lethargic or hard to console.',
          isMine: false,
        ),
        ChatMessage('Okay, that\'s reassuring. Thank you!', isMine: true),
        ChatMessage(
          'Of course, I\'m here anytime. Give her extra cuddles today — she\'s doing great.',
          isMine: false,
        ),
      ],
    ),
    _Conversation(
      title: 'Sleep schedule for 8 months',
      preview: 'What does a good sleep schedule look like for an 8-month-old? They’re fighting every nap.',
      time: '8:17 AM',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF7657EB),
      background: Color(0xFFE7E1FB),
      bucket: _Bucket.today,
      messages: [
        ChatMessage(
          'What does a good sleep schedule look like for an 8-month-old? They’re fighting every nap.',
          isMine: true,
        ),
        ChatMessage(
          'At 8 months, most babies do well with 2 naps a day plus about 11 hours overnight. A typical rhythm is wake ~7am, nap 9–10:30am, nap 1–2:30pm, bedtime ~7pm.',
          isMine: false,
        ),
        ChatMessage('She only naps for 30 minutes lately.', isMine: true),
        ChatMessage(
          'Short naps are common around this age due to a developmental leap. Try an earlier, calmer wind-down and a consistent nap-time routine — it can help her link sleep cycles.',
          isMine: false,
        ),
        ChatMessage('I\'ll give that a try tonight.', isMine: true),
        ChatMessage('Sounds good — let me know how it goes!', isMine: false),
      ],
    ),
    _Conversation(
      title: 'Toddler picky eating',
      child: demoChildren[1],
      preview: 'My 2-year-old only wants crackers lately. How can I encourage more variety at meals?',
      time: '9:48 PM',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFE39A2E),
      background: Color(0xFFFCEBCF),
      bucket: _Bucket.yesterday,
      messages: [
        ChatMessage(
          'My 2-year-old only wants crackers lately. How can I encourage more variety at meals?',
          isMine: true,
        ),
        ChatMessage(
          'Picky eating is very common around age 2. Try serving one new food alongside familiar favorites, and let them help with simple prep — it builds curiosity without pressure.',
          isMine: false,
        ),
        ChatMessage('She won\'t even touch vegetables.', isMine: true),
        ChatMessage(
          'That\'s okay — it can take 10+ exposures before a child accepts a new food. Keep offering small amounts without pressure to eat it, and model enjoying it yourself.',
          isMine: false,
        ),
        ChatMessage(
          'Good to know, I\'ll stop stressing about it.',
          isMine: true,
        ),
        ChatMessage(
          'That\'s the right mindset — consistency over time matters more than any single meal.',
          isMine: false,
        ),
      ],
    ),
    _Conversation(
      title: 'Development milestones',
      preview:
          'What milestones should I look for at 12 months? Are they on track?',
      time: '6:20 PM',
      icon: Icons.eco_rounded,
      color: AppColors.green,
      background: Color(0xFFD8F1E7),
      bucket: _Bucket.yesterday,
      messages: [
        ChatMessage(
          'What milestones should I look for at 12 months? Are they on track?',
          isMine: true,
        ),
        ChatMessage(
          'By 12 months, many babies can stand alone briefly, say 1–2 words, wave bye-bye, and point at things they want. Every baby develops at their own pace though.',
          isMine: false,
        ),
        ChatMessage('He\'s not walking yet, is that a concern?', isMine: true),
        ChatMessage(
          'Not at all — walking typically happens between 9 and 18 months. As long as he\'s pulling up, cruising along furniture, or bearing weight on his legs, he\'s right on track.',
          isMine: false,
        ),
        ChatMessage('That\'s a relief, thank you.', isMine: true),
        ChatMessage(
          'Anytime! Feel free to check back in as he keeps growing.',
          isMine: false,
        ),
      ],
    ),
    _Conversation(
      title: 'Night waking again',
      child: demoChildren[0],
      preview: 'We’re back to frequent night wakings. Any tips for helping them settle on their own?',
      time: 'Mar 12',
      icon: Icons.favorite_rounded,
      color: AppColors.coral,
      background: Color(0xFFFCE1DF),
      bucket: _Bucket.earlier,
      messages: [
        ChatMessage(
          'We’re back to frequent night wakings. Any tips for helping them settle on their own?',
          isMine: true,
        ),
        ChatMessage(
          'Regressions like this often follow a growth spurt, teething, or a developmental leap. Try giving a few minutes before rushing in, so they get a chance to self-soothe.',
          isMine: false,
        ),
        ChatMessage(
          'We\'ve been going in right away every time.',
          isMine: true,
        ),
        ChatMessage(
          'That\'s understandable! You might try sitting near the crib for a few nights, gradually moving further away, so they still feel your presence while learning to settle.',
          isMine: false,
        ),
        ChatMessage('We\'ll try that this week.', isMine: true),
        ChatMessage(
          'Sending you calm nights ahead. Let me know how it goes.',
          isMine: false,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat([_Conversation? conversation]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          title: conversation?.title ?? 'Chat',
          selectedChild: conversation?.child,
          initialMessages: conversation?.messages ?? const [],
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    final query = _query.trim().toLowerCase();
    bool matches(_Conversation c) =>
        query.isEmpty ||
        c.title.toLowerCase().contains(query) ||
        (c.child?.name.toLowerCase().contains(query) ?? false) ||
        c.preview.toLowerCase().contains(query);

    final children = <Widget>[];

    if (query.isNotEmpty) {
      final results = _conversations.where(matches).toList();
      if (results.isEmpty) {
        children.add(const _EmptyResults());
      } else {
        for (final c in results) {
          children.add(_ConversationTile(data: c, onTap: () => _openChat(c)));
          children.add(const SizedBox(height: 12));
        }
      }
      return children;
    }

    for (final bucket in _Bucket.values) {
      final items = _conversations.where((c) => c.bucket == bucket).toList();
      if (items.isEmpty) continue;
      children.add(_SectionLabel(bucket.label));
      children.add(const SizedBox(height: 10));
      for (final c in items) {
        children.add(_ConversationTile(data: c, onTap: () => _openChat(c)));
        children.add(const SizedBox(height: 12));
      }
      children.add(const SizedBox(height: 8));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _HistoryBackground()),
        SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _HistoryHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                    sliver: SliverToBoxAdapter(
                      child: _SearchField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 128),
                    sliver: SliverList.list(
                      children: [
                        _NewChatCard(onTap: () => _openChat()),
                        const SizedBox(height: 22),
                        ..._buildList(),
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

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 0, 16),
      child: Semantics(
        container: true,
        label: 'Chats. Continue where you left off. Small questions, brighter tomorrows.',
        child: SizedBox(
          height: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 300,
                child: Image.asset(
                  'assets/images/chat_header_botanical_transparent.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text('Chats', style: textTheme.displayLarge),
                    ),
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: Text(
                        'Continue where you left off.',
                        style: textTheme.bodyLarge,
                      ),
                    ),
                    const Spacer(),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: const ExcludeSemantics(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: AppColors.lavender,
                            ),
                            SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                'Small questions. Brighter tomorrows.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.whisper,
                                  fontSize: 12.5,
                                  height: 1.1,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E263965),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.inkMuted, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: AppColors.navy, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(color: AppColors.inkMuted, fontSize: 16),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChatCard extends StatelessWidget {
  const _NewChatCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263965),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEE6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.lavender,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start a new chat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ask Mother AI something new',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge
            ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// A plain, flat inbox-style row: a topic icon centered against the title,
/// a truncated preview underneath, and a chevron — no card gimmicks.
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.data, required this.onTap});

  final _Conversation data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08263965),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: data.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: data.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data.time,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (data.child != null) ...[
                        Text(
                          'About ${data.child!.name}',
                          style: TextStyle(
                            color: data.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        data.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 13.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.inkMuted,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'No conversations found',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _HistoryBackground extends StatelessWidget {
  const _HistoryBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBF7FF), AppColors.background],
            stops: [0.0, 0.4],
          ),
        ),
      ),
    );
  }
}

enum _Bucket {
  today('Today'),
  yesterday('Yesterday'),
  earlier('Earlier');

  const _Bucket(this.label);

  final String label;
}

class _Conversation {
  const _Conversation({
    required this.title,
    this.child,
    required this.preview,
    required this.time,
    required this.icon,
    required this.color,
    required this.background,
    required this.bucket,
    required this.messages,
  });

  final String title;
  final ChildProfile? child;
  final String preview;
  final String time;
  final IconData icon;
  final Color color;
  final Color background;
  final _Bucket bucket;
  final List<ChatMessage> messages;
}
