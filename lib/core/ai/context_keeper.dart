import '../data/app_store.dart';
import '../models/child_profile.dart';
import '../models/context_note.dart';
import '../models/conversation.dart';
import 'mother_ai.dart';

/// Keeps each child's context true as chats about them go on: after every
/// answer, Mother AI reads the end of the chat and the store takes in what
/// it found.
abstract final class ContextKeeper {
  /// Each store's reviews run one after another, so each reads the context
  /// as the one before left it and two never add the same note.
  static final _queues = Expando<Future<void>>('context reviews');

  /// Reviews the end of [history], a chat about [child]. Resolves to what
  /// changed, which is often nothing. It carries on if the chat is closed.
  static Future<ContextUpdate> review({
    required AppStore store,
    required MotherAi ai,
    required ChildProfile child,
    required List<ChatMessage> history,
  }) {
    final queue = _queues[store] ?? Future.value();
    final done = queue.then((_) async {
      // As the child is now: the parent may have edited or removed them.
      final current = store.child(child.id);
      if (current == null) return const ContextUpdate();
      final update = await ai.reviewContext(
        child: current,
        notes: store.contextOf(current),
        history: history,
        language: store.languageName,
      );
      return store.reviseContext(current, update);
    });
    _queues[store] = done.then((_) {}, onError: (_) {});
    return done;
  }
}
