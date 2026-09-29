/// How Mother AI writes measurements. The label and examples are English
/// sentences, said in the app's language by the screens (see `L10n.tr`);
/// Mother AI is told them as they are.
enum Units {
  metric('Metric', 'kg, cm, ml, °C'),
  imperial('Imperial', 'lb, oz, in, fl oz, °F');

  const Units(this.label, this.examples);

  final String label;
  final String examples;
}
