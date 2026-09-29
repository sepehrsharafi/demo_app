import 'care_level.dart';

/// One of Mother AI's answers, read from the plain-text format the model is
/// asked to write (see `system_prompt.dart`):
///
///     CARE: home | gp | urgent | none
///     One to three short sentences.
///     1. A step
///     2. Another step
///
/// Plain lines keep an answer readable while it streams: the care level is
/// known once its line is in, and each step shows as it is written. Anything
/// that doesn't follow the format still reads as text.
class Reply {
  const Reply({required this.text, this.care, this.steps = const []});

  factory Reply.parse(String raw) {
    final lines = raw.replaceAll('**', '').split('\n');
    CareLevel? care;
    final head = lines.first.trim();
    if (_careLine.firstMatch(head) case final tag?) {
      care = _levels[tag.group(1)!.toLowerCase()];
      lines.removeAt(0);
    } else if (lines.length == 1 && 'care:'.startsWith(head.toLowerCase())) {
      // Still arriving, and it may yet be the care line: hold it back.
      lines.clear();
    }

    final text = <String>[];
    final steps = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (_stepLine.firstMatch(trimmed) case final step?) {
        // A bare "2." is a step whose words haven't arrived yet.
        final words = step.group(1)?.trim() ?? '';
        if (words.isNotEmpty) steps.add(words);
      } else {
        text.add(trimmed);
      }
    }
    return Reply(text: text.join('\n'), care: care, steps: steps);
  }

  final String text;

  /// Set on answers that assess a situation. Small talk has none.
  final CareLevel? care;

  /// What to do, in order.
  final List<String> steps;

  bool get isEmpty => text.isEmpty && steps.isEmpty;

  static final _careLine = RegExp(
    r'^care\s*:\s*([a-z]*)$',
    caseSensitive: false,
  );

  /// "1. Step", "- Step", or a bare "1" still waiting for its full stop.
  static final _stepLine = RegExp(
    r'^(?:\d{1,2}[.)]|[-•*])(?:\s+(.*))?$|^\d{1,2}$',
  );
  static final _levels = CareLevel.values.asNameMap();
}
