import '../l10n/l10n.dart';
import 'ask_topic.dart';
import 'care_level.dart';
import 'reply.dart';

class ChatMessage {
  ChatMessage(this.content, {required this.isMine});

  /// Exactly what was said: the parent's words, or Mother AI's answer as
  /// the model wrote it. This is what is stored and sent back as history.
  final String content;
  final bool isMine;

  /// An answer read into its parts, once.
  late final Reply reply = isMine ? Reply(text: content) : Reply.parse(content);
}

/// The label is an English sentence, said in the app's language with
/// `context.tr`.
enum DayBucket {
  today('Today'),
  yesterday('Yesterday'),
  earlier('Earlier');

  const DayBucket(this.label);

  final String label;
}

/// A past conversation as the lists show it; its messages are read only
/// when it is opened.
class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.childId,
    required this.topic,
    required this.preview,
    required this.care,
    required this.updatedAt,
  });

  final int id;

  /// The first question asked.
  final String title;

  /// Null for a general question.
  final int? childId;

  /// What it was about, if the parent started from a topic.
  final AskTopic? topic;

  /// Mother AI's latest answer; empty until there is one.
  final String preview;

  /// The most serious level any answer in it reached.
  final CareLevel? care;
  final DateTime updatedAt;

  DayBucket get bucket {
    final now = DateTime.now();
    final day = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
    if (day == DateTime(now.year, now.month, now.day)) return DayBucket.today;
    if (day == DateTime(now.year, now.month, now.day - 1)) {
      return DayBucket.yesterday;
    }
    return DayBucket.earlier;
  }

  /// "10:24" today and yesterday, "12 Sep" before that.
  String time(L10n l10n) {
    if (bucket != DayBucket.earlier) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(updatedAt.hour)}:${two(updatedAt.minute)}';
    }
    return updatedAt.year == DateTime.now().year
        ? l10n.dayMonth(updatedAt)
        : l10n.date(updatedAt);
  }
}
