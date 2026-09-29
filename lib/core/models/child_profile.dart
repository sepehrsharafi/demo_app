import 'package:flutter/widgets.dart';

/// A child the parent has told Mother AI about. Home, Chat and Profile all
/// read the same record, so every surface talks about the same family.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.birthday,
    required this.hueIndex,
    this.allergies,
    this.conditions,
    this.medications,
    this.notes,
  });

  final int id;
  final String name;
  final DateTime birthday;

  /// Which of [childHues] is theirs, fixed when they are added so it never
  /// changes under them.
  final int hueIndex;

  /// In the parent's own words; null when nothing is recorded.
  final String? allergies;
  final String? conditions;
  final String? medications;
  final String? notes;

  /// The child's own colour: their monogram, and their name wherever it is
  /// the thing you tap to switch who a question is about.
  Color get hue => childHues[hueIndex % childHues.length].hue;
  Color get hueTint => childHues[hueIndex % childHues.length].tint;

  String get initial =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();

  /// "6 months", for sentences. English, which is what Mother AI is told;
  /// the screens say it in the app's language (see `L10n.age`).
  String get age => _english(short: false);

  /// "6 mo", for chips and rows.
  String get ageShort => _english(short: true);

  /// "14 Mar 2026".
  String get birthdayLabel => formatDate(birthday);

  /// Whole months lived, counting a month only once its day has come.
  int get months {
    final now = DateTime.now();
    final months = (now.year - birthday.year) * 12 + now.month - birthday.month;
    return now.day < birthday.day ? months - 1 : months;
  }

  /// How old they are in the unit ages are said in for young children:
  /// days, then weeks, then months up to two years, then years.
  ({int n, AgeUnit unit}) get ageSpan {
    final months = this.months;
    if (months >= 24) return (n: months ~/ 12, unit: AgeUnit.year);
    if (months >= 1) return (n: months, unit: AgeUnit.month);
    // In UTC, so a clock change doesn't turn a day into 23 hours.
    final now = DateTime.now();
    final days = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(birthday.year, birthday.month, birthday.day))
        .inDays;
    if (days >= 7) return (n: days ~/ 7, unit: AgeUnit.week);
    return (n: days, unit: AgeUnit.day);
  }

  String _english({required bool short}) {
    final (:n, :unit) = ageSpan;
    return short
        ? '$n ${unit.shortEnglish}'
        : '$n ${unit.name}${n == 1 ? '' : 's'}';
  }

  /// What is typical at this age, said plainly. Home shows it as context,
  /// never as a question put in the parent's mouth.
  List<String> get stage => childStages
      .firstWhere((stage) => months < stage.$1, orElse: () => childStages.last)
      .$2;
}

enum AgeUnit {
  year('yr'),
  month('mo'),
  week('wk'),
  day('d');

  const AgeUnit(this.shortEnglish);

  final String shortEnglish;
}

/// A child's hue and the tint it sits on. None is green, amber or red,
/// which belong to care levels, or Mother AI's own violet.
const childHues = <({Color hue, Color tint})>[
  (hue: Color(0xFFC23F84), tint: Color(0xFFFBEAF3)),
  (hue: Color(0xFF3462D6), tint: Color(0xFFE8EEFD)),
  (hue: Color(0xFF0B7892), tint: Color(0xFFE2F3F7)),
  (hue: Color(0xFF9A3DB8), tint: Color(0xFFF5E9FA)),
];

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "14 Mar 2026".
String formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// Up to (but not including) an age in months, what is typical by then.
/// Public so the translations can be checked against it.
const childStages = <(int, List<String>)>[
  (
    2,
    [
      'Feeding every two to three hours, day and night',
      'Sleeping most of the day, in short stretches',
      'A first real smile, often around six weeks',
    ],
  ),
  (
    4,
    [
      'Smiling, cooing and watching faces',
      'Holding their head up during tummy time',
      'Longer stretches of sleep at night, for some',
    ],
  ),
  (
    6,
    [
      'Rolling over, often tummy to back first',
      'Reaching for toys and bringing them to the mouth',
      'Laughing and babbling back at you',
    ],
  ),
  (
    9,
    [
      'Ready to try first foods',
      'Sitting up with a little support',
      'First teeth may be on the way',
    ],
  ),
  (
    12,
    [
      'Crawling, and pulling up to stand',
      'Picking up small things between finger and thumb',
      'Waving, pointing and first words',
    ],
  ),
  (
    18,
    [
      'First steps, often with a hand to hold',
      'A few words, and understanding many more',
      'Eating family meals, cut small',
    ],
  ),
  (
    24,
    [
      'New words most weeks',
      'Climbing and exploring everything',
      'Wanting to do things on their own',
    ],
  ),
  (
    36,
    [
      'Starting to put two words together',
      'Big feelings, and tantrums with them',
      'Running, climbing and kicking a ball',
    ],
  ),
  (
    60,
    [
      'Talking in full sentences',
      'Pretend play, and learning to take turns',
      'Dry during the day, most of the time',
    ],
  ),
  (
    1 << 30,
    [
      'Starting school and making friends',
      'Reading and writing first words',
      'Losing baby teeth, from around six',
    ],
  ),
];
