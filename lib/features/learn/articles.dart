import '../../core/models/ask_topic.dart';
import '../../core/models/care_level.dart';

/// Something in Learn. Most are articles written in Mother AI's own voice
/// and read inside the app; some are links to a page elsewhere, which open
/// in the browser. The bodies below are placeholder copy for the demo.
class Article {
  const Article({
    required this.topic,
    required this.title,
    required this.summary,
    this.imagePath,
    this.minutes,
    this.body = const [],
    this.keyPoints = const [],
    this.whenToGetHelp = const [],
    this.followUps = const [],
    this.url,
  });

  /// The same topics a question can start from, so Learn and chat share one
  /// vocabulary.
  final AskTopic topic;
  final String title;
  final String summary;

  /// The article's photo. Links have none of their own.
  final String? imagePath;

  /// How long it takes to read, when we know.
  final int? minutes;

  /// Set when this is a page elsewhere rather than an article in the app.
  final String? url;

  bool get opensOutside => url != null;

  final List<String> body;

  /// What to do, as numbered steps.
  final List<String> keyPoints;

  /// The same care levels an answer in chat uses.
  final List<(CareLevel, String)> whenToGetHelp;

  /// Starting questions when the parent asks Mother AI about the article.
  final List<String> followUps;
}

const featuredArticle = Article(
  topic: AskTopic.growth,
  title: 'Understanding growth spurts',
  summary:
      'Why sudden growth and fussiness often arrive together, and how to '
      'help your child through one.',
  imagePath: 'assets/images/learn_growth_feature.webp',
  minutes: 5,
  body: [
    'Growth spurts are short stretches, often just a few days, when a baby '
        'or child grows faster than usual. In babies they commonly show up '
        'around two to three weeks, six weeks, three months and six months, '
        'though every child keeps their own timetable.',
    'During a spurt your child may be hungrier, sleep more or less than '
        'usual, and be harder to settle. This is normal, and it usually '
        'passes within a week.',
  ],
  keyPoints: [
    'Feed on demand. Extra hunger is what a growth spurt is for.',
    'Expect sleep to wobble for a few days, then settle again.',
    'Keep the rest of the day familiar so the changes feel smaller.',
  ],
  whenToGetHelp: [
    (CareLevel.home, 'Extra hunger and fussiness for a few days.'),
    (
      CareLevel.gp,
      'Fewer wet nappies than usual, or not gaining weight at check-ups.',
    ),
  ],
  followUps: [
    'How can I tell a growth spurt is happening?',
    'How often should a 6-month-old feed?',
  ],
);

const moreArticles = <Article>[
  Article(
    topic: AskTopic.health,
    title: 'Fever 101: when to worry',
    summary:
        'What counts as mild, and the signs that mean it is time to call '
        'someone.',
    imagePath: 'assets/images/learn_fever.webp',
    minutes: 4,
    body: [
      'A fever is a temperature of 38°C or higher. It is the body’s normal '
          'way of fighting an infection, and most fevers in children come '
          'from common viruses that pass on their own.',
      'How your child is behaving matters more than the number on the '
          'thermometer. A child who is still feeding, alert between naps and '
          'comforted by you is usually doing well.',
    ],
    keyPoints: [
      'Offer plenty of fluids, little and often.',
      'Dress them lightly. Don’t bundle them up or cool them with cold water.',
      'Paracetamol or ibuprofen can help them feel better. Check the dose '
          'for their age.',
    ],
    whenToGetHelp: [
      (
        CareLevel.home,
        'A fever, but they are feeding, alert and settle with you.',
      ),
      (
        CareLevel.gp,
        'Under 3 months with 38°C or more, 3 to 6 months with 39°C or more, '
            'or a fever lasting over 5 days.',
      ),
      (
        CareLevel.urgent,
        'A rash that doesn’t fade under a glass, trouble breathing, or they '
            'are floppy or hard to wake.',
      ),
    ],
    followUps: [
      'What temperature counts as a fever?',
      'Which thermometer is best for a baby?',
    ],
  ),
  Article(
    topic: AskTopic.sleep,
    title: 'Building a bedtime routine',
    summary: 'A simple, repeatable wind-down that helps sleep come easier.',
    imagePath: 'assets/images/learn_bedtime.webp',
    minutes: 6,
    body: [
      'A predictable routine tells a child’s body that sleep is coming. The '
          'same few steps, in the same order, at about the same time each '
          'night matter more than which steps you choose.',
      'Start 20 to 30 minutes before you would like them asleep, and keep '
          'the room calm and dim.',
    ],
    keyPoints: [
      'Bath, pyjamas, a story, then lights out, in the same order.',
      'Switch screens off at least an hour before bed.',
      'Put them down drowsy but awake so they learn to settle themselves.',
    ],
    whenToGetHelp: [
      (CareLevel.home, 'Slow to settle, or waking once or twice a night.'),
      (
        CareLevel.gp,
        'Loud snoring with pauses in breathing, or poor sleep affecting their '
            'days.',
      ),
    ],
    followUps: [
      'How long should a bedtime routine take?',
      'How long should a 2-year-old nap?',
    ],
  ),
  Article(
    topic: AskTopic.behaviour,
    title: 'Positive discipline basics',
    summary: 'Setting limits with warmth instead of power struggles.',
    imagePath: 'assets/images/learn_positive_discipline.webp',
    minutes: 7,
    body: [
      'Positive discipline is about teaching rather than punishing. Children '
          'learn best from calm, consistent limits, and from watching how you '
          'handle big feelings yourself.',
      'Toddlers are still learning to control their impulses, so tantrums '
          'are a normal part of growing up, not a sign you are doing '
          'something wrong.',
    ],
    keyPoints: [
      'Name the feeling first: “You’re cross the tower fell down.”',
      'Offer two choices you are happy with either way.',
      'Praise the behaviour you want to see more of.',
    ],
    whenToGetHelp: [
      (CareLevel.home, 'Tantrums that pass and come now and then.'),
      (
        CareLevel.gp,
        'Behaviour that worries you, or that isn’t easing as they grow. Your '
            'health visitor can help too.',
      ),
    ],
    followUps: [
      'How do I handle tantrums at bedtime?',
      'Are time-outs okay for a 2-year-old?',
    ],
  ),
];

/// Pages elsewhere that Learn links to. Placeholder picks for the demo:
/// which sites Learn points to is still to be decided.
const outsideReading = <Article>[
  Article(
    topic: AskTopic.feeding,
    title: 'Starting solid foods',
    summary: 'When to begin, how to go about it, and which first foods to try.',
    url: 'https://www.who.int/health-topics/complementary-feeding',
  ),
  Article(
    topic: AskTopic.sleep,
    title: 'Safe sleep in the first year',
    summary:
        'How to set up a safe place for your baby to sleep, day and night.',
    url: 'https://safetosleep.nichd.nih.gov/',
  ),
];

/// Everything Learn lists under its lead, in reading order.
const learnLibrary = <Article>[
  featuredArticle,
  ...moreArticles,
  ...outsideReading,
];
