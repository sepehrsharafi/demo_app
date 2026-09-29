import 'package:flutter/widgets.dart';

import 'rolling_text.dart';

/// A sentence with names in it, where only the names roll when they change
/// (see [RollingText]) and the words around them stay put.
///
/// The [template] is a translated sentence with `{blanks}`; each blank is
/// filled from [values] and may have a colour of its own in [colours]. The
/// sentence can run over several lines (`\n`), each kept on one line and
/// shrunk to fit rather than wrapped, so a long name never pushes the
/// layout about. A language puts its blanks wherever its grammar wants them.
class RollingTemplate extends StatelessWidget {
  const RollingTemplate({
    super.key,
    required this.template,
    required this.values,
    required this.style,
    this.colours = const {},
  });

  final String template;
  final Map<String, String> values;
  final TextStyle style;
  final Map<String, Color> colours;

  static final _blank = RegExp(r'\{(\w+)\}');

  /// The sentence as it reads, for screen readers.
  static String plain(String template, Map<String, String> values) => template
      .replaceAllMapped(_blank, (match) => values[match.group(1)] ?? '')
      .replaceAll('\n', ' ');

  @override
  Widget build(BuildContext context) {
    final lines = template.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (l, line) in lines.indexed)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _segments(l, line),
            ),
          ),
      ],
    );
  }

  List<Widget> _segments(int lineIndex, String line) {
    final segments = <Widget>[];
    var from = 0;
    void words(String text) {
      if (text.isNotEmpty) segments.add(Text(text, style: style));
    }

    for (final blank in _blank.allMatches(line)) {
      words(line.substring(from, blank.start));
      final name = blank.group(1)!;
      segments.add(
        RollingText(
          // Keyed by place, so it is the same roller when the name changes.
          key: ValueKey('$lineIndex.$name'),
          values[name] ?? '',
          style: colours[name] == null
              ? style
              : style.copyWith(color: colours[name]),
        ),
      );
      from = blank.end;
    }
    words(line.substring(from));
    return segments;
  }
}

/// A translated sentence with `{blanks}` as text spans, so a blank can take a
/// colour or weight of its own: "Emma at **6 months**".
List<InlineSpan> templateSpans(
  String template,
  Map<String, String> values, {
  Map<String, TextStyle> styles = const {},
}) {
  final spans = <InlineSpan>[];
  var from = 0;
  for (final blank in RollingTemplate._blank.allMatches(template)) {
    if (blank.start > from) {
      spans.add(TextSpan(text: template.substring(from, blank.start)));
    }
    final name = blank.group(1)!;
    spans.add(TextSpan(text: values[name] ?? '', style: styles[name]));
    from = blank.end;
  }
  if (from < template.length) {
    spans.add(TextSpan(text: template.substring(from)));
  }
  return spans;
}
