/// English is the language the app's words are written in, so a sentence is
/// its own key and needs no entry. What is here is what a sentence can't be:
/// words that change with a number, and the calendar.
///
/// `key#one` and `key#other` are the forms of a plural; the other languages
/// add `zero`, `two`, `few` and `many` where theirs have them.
const stringsEn = <String, String>{
  'age.year#one': '{n} year',
  'age.year#other': '{n} years',
  'age.month#one': '{n} month',
  'age.month#other': '{n} months',
  'age.week#one': '{n} week',
  'age.week#other': '{n} weeks',
  'age.day#one': '{n} day',
  'age.day#other': '{n} days',
  'age.year.short': '{n} yr',
  'age.month.short': '{n} mo',
  'age.week.short': '{n} wk',
  'age.day.short': '{n} d',
  'month.1': 'Jan',
  'month.2': 'Feb',
  'month.3': 'Mar',
  'month.4': 'Apr',
  'month.5': 'May',
  'month.6': 'Jun',
  'month.7': 'Jul',
  'month.8': 'Aug',
  'month.9': 'Sep',
  'month.10': 'Oct',
  'month.11': 'Nov',
  'month.12': 'Dec',
  // "14 Mar 2026" and "14 Mar".
  'date.full': '{d} {m} {y}',
  'date.dayMonth': '{d} {m}',
};
