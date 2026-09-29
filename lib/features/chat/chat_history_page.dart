import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/data/app_scope.dart';
import '../../core/data/app_store.dart';
import '../../core/l10n/l10n.dart';
import '../../core/models/conversation.dart';
import '../../core/theme/app_theme.dart';
import 'chat_page.dart';
import '../../core/widgets/text_menu.dart';
import 'widgets/conversation_row.dart';

/// The Chats tab: every past conversation, grouped by day, and the way to
/// start a new one.
class ChatHistoryTab extends StatefulWidget {
  const ChatHistoryTab({super.key});

  @override
  State<ChatHistoryTab> createState() => _ChatHistoryTabState();
}

class _ChatHistoryTabState extends State<ChatHistoryTab> {
  String _query = '';

  void _startNew() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ChatPage()));
  }

  bool _matches(AppStore store, Conversation conversation) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return conversation.title.toLowerCase().contains(query) ||
        conversation.preview.toLowerCase().contains(query) ||
        (store
                .child(conversation.childId)
                ?.name
                .toLowerCase()
                .contains(query) ??
            false);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final results = [
      for (final conversation in store.conversations)
        if (_matches(store, conversation)) conversation,
    ];
    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(context.tr('Chats'), style: AppText.display),
                  ),
                  ShadButton(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.plus, size: 16),
                    onPressed: _startNew,
                    child: Text(context.tr('New chat')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (store.conversations.isEmpty)
                const _Empty()
              else ...[
                ShadInput(
                  contextMenuBuilder: textMenu,
                  placeholder: Text(context.tr('Search conversations')),
                  style: AppText.body,
                  placeholderStyle: AppText.body.copyWith(
                    color: AppColors.muted,
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (value) => setState(() => _query = value),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  decoration: const ShadDecoration(
                    color: AppColors.panel,
                    border: ShadBorder(
                      radius: BorderRadius.all(
                        Radius.circular(AppTheme.radius),
                      ),
                    ),
                    focusedBorder: ShadBorder(
                      radius: BorderRadius.all(
                        Radius.circular(AppTheme.radius),
                      ),
                    ),
                  ),
                  leading: const Icon(
                    LucideIcons.search,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                if (results.isEmpty)
                  _NoResults(query: _query.trim())
                else
                  for (final bucket in DayBucket.values)
                    if (results.where((c) => c.bucket == bucket).toList()
                        case final group when group.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 28, 0, 10),
                        child: Text(
                          context.tr(bucket.label),
                          style: AppText.label,
                        ),
                      ),
                      // A full rule opens each day; rows inside it are split
                      // by hairlines inset to the text.
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.line,
                      ),
                      for (final (i, conversation) in group.indexed)
                        ConversationRow(
                          conversation: conversation,
                          child: store.child(conversation.childId),
                          divider: i != 0,
                          onTap: () => openConversation(context, conversation),
                        ),
                    ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Before the first question: where the chats will be.
class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        children: [
          const Icon(
            LucideIcons.messagesSquare,
            size: 28,
            color: AppColors.muted,
          ),
          const SizedBox(height: 12),
          Text(context.tr('No chats yet'), style: AppText.rowTitle),
          const SizedBox(height: 4),
          Text(
            context.tr('Every question you ask Mother AI is kept here.'),
            textAlign: TextAlign.center,
            style: AppText.secondary,
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        children: [
          const Icon(LucideIcons.searchX, size: 28, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            context.tr('Nothing matches “{query}”', {'query': query}),
            style: AppText.rowTitle,
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('Try a child’s name or a word from the question.'),
            textAlign: TextAlign.center,
            style: AppText.secondary,
          ),
        ],
      ),
    );
  }
}
