// Finds every English sentence the app says, by reading its source, so the
// translations can be written against a complete list and checked against it
// (test/l10n_test.dart). Run it to print the list:
//
//     dart run tool/l10n_keys.dart
import 'dart:io';

/// The sentences passed to `tr(...)`, plus the ones the app keeps as data
/// (topics, care levels, articles, help and legal pages, what is typical at
/// each age, Mother AI’s error messages) and says later with
/// `context.tr(that)`.
Set<String> sentencesInSource(Directory lib) {
  final keys = <String>{};
  for (final file in lib.listSync(recursive: true).whereType<File>()) {
    final path = file.path.replaceAll(r'\', '/');
    if (!path.endsWith('.dart') || path.contains('/core/l10n/')) continue;
    final source = file.readAsStringSync();
    keys.addAll(_calls(source));
    if (path.endsWith('/models/ask_topic.dart')) {
      keys.addAll(_after(source, RegExp(r'^  \w+\(\s*$', multiLine: true)));
    }
    if (path.endsWith('/models/care_level.dart')) {
      keys.addAll(_named(source, ['label', 'short', 'action']));
    }
    if (path.endsWith('/models/conversation.dart')) {
      keys.addAll(_after(source, RegExp(r"^  \w+\(", multiLine: true)));
    }
    if (path.endsWith('/models/preferences.dart')) {
      keys.addAll(_literals(source.substring(source.indexOf('enum Units'))));
    }
    if (path.endsWith('/models/child_profile.dart')) {
      final start = source.indexOf('const childStages');
      keys.addAll(_literals(source.substring(start)));
    }
    if (path.endsWith('/learn/articles.dart')) {
      keys.addAll(
        _literals(source.substring(source.indexOf('class Article')))
            .where((s) => !s.startsWith('assets/') && !s.startsWith('http')),
      );
    }
    if (path.endsWith('/profile/documents.dart')) {
      keys.addAll(_literals(source.substring(source.indexOf('const help'))));
    }
    if (path.endsWith('/ai/mother_ai.dart')) {
      final start = source.indexOf('class MotherAiException');
      keys.addAll(_literals(source.substring(start)));
    }
    if (path.endsWith('/widgets/app_nav_bar.dart')) {
      final start = source.indexOf('static const _items');
      keys.addAll(_literals(source.substring(start, start + 240)));
    }
    if (path.endsWith('/home/home_page.dart')) {
      final start = source.indexOf('String _greeting');
      keys.addAll(_literals(source.substring(start, start + 240)));
    }
  }
  return keys..removeWhere((key) => key.isEmpty);
}

/// The first literal after each place [marker] matches, as enums write theirs.
Iterable<String> _after(String source, RegExp marker) sync* {
  for (final match in marker.allMatches(source)) {
    final run = _literalRunAt(source, match.end);
    if (run != null) yield run.$1;
  }
}

/// The literal following each `name:` in [names].
Iterable<String> _named(String source, List<String> names) sync* {
  for (final name in names) {
    for (final match in RegExp(r'\b' + name + r':').allMatches(source)) {
      final run = _literalRunAt(source, match.end);
      if (run != null) yield run.$1;
    }
  }
}

/// Every string literal in [source], adjacent ones joined the way Dart joins
/// them.
Iterable<String> _literals(String source) sync* {
  var i = 0;
  while (i < source.length) {
    final run = _literalRunAt(source, i, skipTo: true);
    if (run == null) break;
    yield run.$1;
    i = run.$2;
  }
}

/// The first argument of every `tr(...)`: each literal, or run of adjacent
/// literals, in it (a conditional names two sentences).
Iterable<String> _calls(String source) sync* {
  for (final call in RegExp(r'\btr\(').allMatches(source)) {
    var depth = 0;
    var i = call.end;
    while (i < source.length) {
      final char = source[i];
      if (char == "'" || char == '"') {
        final run = _literalRunAt(source, i);
        if (run == null) break;
        yield run.$1;
        i = run.$2;
        continue;
      }
      if ('([{'.contains(char)) depth++;
      if (')]}'.contains(char)) {
        if (depth == 0) break;
        depth--;
      }
      if (char == ',' && depth == 0) break;
      i++;
    }
  }
}

/// The literal (with any literals directly after it) that starts at or,
/// with [skipTo], after [from]: its text and where it ends.
(String, int)? _literalRunAt(String source, int from, {bool skipTo = false}) {
  var i = from;
  if (skipTo) {
    while (i < source.length && source[i] != "'" && source[i] != '"') {
      // Comments can hold quotes.
      if (source.startsWith('//', i)) {
        while (i < source.length && source[i] != '\n') {
          i++;
        }
      } else {
        i++;
      }
    }
  } else {
    while (i < source.length && ' \n\t'.contains(source[i])) {
      i++;
    }
  }
  if (i >= source.length || (source[i] != "'" && source[i] != '"')) {
    return null;
  }
  final text = StringBuffer();
  while (i < source.length && (source[i] == "'" || source[i] == '"')) {
    final quote = source[i++];
    while (i < source.length && source[i] != quote) {
      if (source[i] == r'\') {
        i++;
        text.write(switch (source[i]) {
          'n' => '\n',
          final other => other,
        });
      } else {
        text.write(source[i]);
      }
      i++;
    }
    i++;
    var j = i;
    while (j < source.length && ' \n\t'.contains(source[j])) {
      j++;
    }
    if (j < source.length && (source[j] == "'" || source[j] == '"')) {
      i = j;
    } else {
      break;
    }
  }
  final joined = text.toString();
  // Interpolated text is built at run time and isn't a key.
  return (joined.contains(r'$') ? '' : joined, i);
}

void main() {
  final keys = sentencesInSource(Directory('lib')).toList()..sort();
  stdout.writeln(keys.join('\n---\n'));
}
