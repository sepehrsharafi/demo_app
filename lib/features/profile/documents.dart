/// The Help centre, the terms and the privacy policy, as data. Each is an
/// English text the screens say in the app's language with `context.tr`,
/// and every sentence below is in the translation tables.
///
/// What they say must stay true to what the app does: everything is kept on
/// the phone, and only what a question needs goes to the AI provider.
library;

/// A page of help or legal text: an opening paragraph, then sections.
class Document {
  const Document({
    required this.title,
    required this.intro,
    required this.sections,
    this.updated,
  });

  final String title;
  final String intro;
  final List<DocumentSection> sections;

  /// When the text last changed, for the terms and the policy.
  final ({int year, int month, int day})? updated;
}

/// A heading and what is said under it. In the Help centre the heading is
/// a question and the paragraphs its answer.
class DocumentSection {
  const DocumentSection(this.heading, this.paragraphs);

  final String heading;
  final List<String> paragraphs;
}

const helpCentre = Document(
  title: 'Help centre',
  intro:
      'Answers to the questions parents ask most about Mother AI. If yours '
      'isn’t here, contact support.',
  sections: [
    DocumentSection('What can I ask Mother AI?', [
      'Anything about a baby or young child’s health, feeding, sleep, '
          'growth, behaviour and everyday care. Say what is happening in '
          'your own words, as you would to a friend who knows children.',
      'Every answer starts with how much help the situation needs: fine at '
          'home, call your GP or health visitor today, or get urgent help '
          'now.',
    ]),
    DocumentSection('Is Mother AI a doctor?', [
      'No. It gives general guidance and can’t examine, diagnose or treat '
          'your child. If your child is seriously unwell, or you are worried '
          'about their breathing, alertness or hydration, call your local '
          'emergency number straight away.',
    ]),
    DocumentSection('How does Mother AI know about my child?', [
      'From two places. The details you add in their profile: name, date of '
          'birth, allergies, conditions, medicines and notes. And their '
          'context: what Mother AI picks up from your chats about them.',
      'Choose who a question is about before you ask, and the answer takes '
          'all of it into account.',
    ]),
    DocumentSection('What is a child’s context?', [
      'Short notes Mother AI keeps from your chats, such as a fall, a new '
          'food or a cough that started on a certain day. They let a new '
          'chat carry on from an earlier one, so you don’t have to explain '
          'everything again.',
      'Mother AI keeps them up to date as you talk: when you say something '
          'has got better, it changes the note. When a chat adds to the '
          'context, it says so under the answer.',
    ]),
    DocumentSection('How do I change what Mother AI remembers?', [
      'Go to Profile, tap the child, then Edit. Under Context you can '
          'rewrite any note or remove it. The details at the top of the '
          'page can be changed there too.',
    ]),
    DocumentSection('Can I add more than one child?', [
      'Yes. Add each child in Profile. On Home and in a new chat, tap the '
          'child’s name to choose who the question is about. Once a chat has '
          'started, who it is about stays fixed.',
    ]),
    DocumentSection('Why didn’t I get an answer?', [
      'Mother AI needs an internet connection to answer. If an answer '
          'doesn’t arrive, check your connection and tap Try again. Your '
          'question is kept, so you don’t need to type it again.',
      'On some networks the service can’t be reached at all. Another '
          'connection usually works.',
    ]),
    DocumentSection('How do I change the language or units?', [
      'In Profile, under Preferences. The language changes the whole app and '
          'the language Mother AI answers in. Units change how it writes '
          'weights, lengths and temperatures.',
    ]),
    DocumentSection('Where are my chats kept?', [
      'On your phone, with your children’s details. You can find every chat '
          'in the Chats tab. Removing a child deletes their details, their '
          'context and every chat about them.',
    ]),
  ],
);

const termsOfService = Document(
  title: 'Terms of service',
  updated: _updated,
  intro:
      'These terms apply when you use Mother AI. By using the app, you agree '
      'to them. Please read them together with the privacy policy.',
  sections: [
    DocumentSection('What Mother AI is', [
      'Mother AI is a companion for parents and caregivers. It answers '
          'questions about babies and young children with general guidance, '
          'and offers articles to read.',
      'It is not a medical service. It can’t examine, diagnose or treat your '
          'child, and it doesn’t replace advice from your doctor, midwife, '
          'health visitor or pharmacist.',
    ]),
    DocumentSection('In an emergency', [
      'If your child is seriously unwell or you think they may be in danger, '
          'call your local emergency number straight away. Don’t wait for '
          'an answer from the app.',
    ]),
    DocumentSection('Answers can be wrong', [
      'Answers are written by an artificial intelligence model. They can be '
          'incomplete, out of date or wrong, even when they sound sure. Use '
          'your own judgement, and check with a health professional before '
          'acting on anything that matters.',
      'Never give a medicine, or change a dose, on the strength of an answer '
          'alone. Follow the packet or ask a pharmacist.',
    ]),
    DocumentSection('Who can use it', [
      'Mother AI is for adults caring for a child. It isn’t meant to be used '
          'by children.',
    ]),
    DocumentSection('What you tell it', [
      'You are responsible for what you enter. Only add what you are happy '
          'to share, and only about children you care for. Don’t use Mother '
          'AI for anything unlawful or harmful, or try to make it produce '
          'such content.',
    ]),
    DocumentSection('Articles and other websites', [
      'Articles in Learn are general information. Some Learn items open a '
          'page on another website; those sites are not part of Mother AI, '
          'and their own terms apply.',
    ]),
    DocumentSection('Availability', [
      'Answers need an internet connection and a service outside the app, '
          'so they may sometimes be slow or unavailable. Features may change '
          'or be removed as the app develops.',
    ]),
    DocumentSection('Responsibility', [
      'Mother AI is provided as it is. As far as the law allows, we aren’t '
          'responsible for decisions made on the strength of its answers. '
          'Nothing in these terms limits rights you have by law that can’t '
          'be limited.',
    ]),
    DocumentSection('Changes to these terms', [
      'We may update these terms. When we do, the date at the top changes. '
          'Using the app after a change means you accept the new terms.',
    ]),
    DocumentSection('Contact', [
      'Questions about these terms are welcome through Contact support in '
          'Profile.',
    ]),
  ],
);

const privacyPolicy = Document(
  title: 'Privacy policy',
  updated: _updated,
  intro:
      'Mother AI is built to keep your family’s details on your phone. This '
      'policy explains what the app keeps, what leaves your phone and why, '
      'and how to remove it.',
  sections: [
    DocumentSection('What is kept on your phone', [
      'The details you add about each child (name, date of birth, allergies, '
          'conditions, medicines and notes), their context, your chats, and '
          'your language and units.',
      'They are stored in the app on your phone. There is no Mother AI '
          'account, and we don’t keep a copy on our own servers. Your '
          'phone’s own backup may include them, depending on its settings.',
    ]),
    DocumentSection('What leaves your phone', [
      'To answer a question, Mother AI sends it to Groq, the service that '
          'runs the AI model, along with what the answer needs: recent '
          'messages from the chat, your language and units, and, when the '
          'question is about a child, their profile details, their context '
          'and the titles of earlier chats about them.',
      'After each answer about a child, the latest messages and their '
          'context are sent again, so Mother AI can update what it remembers '
          'about them.',
      'Groq handles this under its own terms and privacy policy. Nothing '
          'else leaves your phone.',
    ]),
    DocumentSection('What we don’t do', [
      'Mother AI has no advertising, no analytics and no tracking. We don’t '
          'sell or share your information, and we don’t use it for anything '
          'other than answering you.',
    ]),
    DocumentSection('Health information', [
      'What you tell Mother AI about a child can include health information. '
          'It is used only to give better answers about that child. Add only '
          'what you are comfortable sharing.',
    ]),
    DocumentSection('Your choices', [
      'You can change or remove any detail or context note in Profile. '
          'Removing a child deletes their details, their context and every '
          'chat about them from your phone. Uninstalling the app deletes '
          'everything it kept.',
    ]),
    DocumentSection('Children', [
      'Mother AI is used by adults on behalf of the children they care for. '
          'It isn’t meant to be used by children themselves.',
    ]),
    DocumentSection('Changes to this policy', [
      'If the way the app handles information changes, we will update this '
          'policy and the date at the top.',
    ]),
    DocumentSection('Contact', [
      'For questions about privacy, use Contact support in Profile.',
    ]),
  ],
);

const _updated = (year: 2026, month: 9, day: 29);
