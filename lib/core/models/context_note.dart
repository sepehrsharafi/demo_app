/// One thing Mother AI has picked up about a child from the parent's chats,
/// kept so a later chat can carry on from an earlier one: "Fell and hurt
/// her knee on 29 Sep 2026".
///
/// Mother AI writes and rewrites these itself as chats go on; the parent can
/// change or remove any of them.
class ContextNote {
  const ContextNote({
    required this.id,
    required this.childId,
    required this.text,
    required this.updatedAt,
  });

  final int id;
  final int childId;

  /// One short sentence, in the language the parent was speaking.
  final String text;

  /// When it was written or last changed, by Mother AI or the parent.
  final DateTime updatedAt;
}

/// What an exchange changes in a child's context: notes to add, notes to
/// rewrite (by id) and notes that no longer hold (by id).
class ContextUpdate {
  const ContextUpdate({
    this.added = const [],
    this.edited = const {},
    this.removed = const {},
  });

  final List<String> added;
  final Map<int, String> edited;
  final Set<int> removed;

  bool get isEmpty => added.isEmpty && edited.isEmpty && removed.isEmpty;

  /// Only the parts that name a note of [known] (by id) and say something.
  /// The model's reply is read through this, so an id it made up, or an
  /// empty note, is never applied.
  ContextUpdate within(Iterable<int> known) {
    final ids = known.toSet();
    String? said(String text) {
      final trimmed = text.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    final removed = {...this.removed.where(ids.contains)};
    return ContextUpdate(
      added: [for (final text in added) ?said(text)],
      edited: {
        for (final MapEntry(key: id, value: text) in edited.entries)
          if (ids.contains(id) && !removed.contains(id)) id: ?said(text),
      },
      removed: removed,
    );
  }
}
