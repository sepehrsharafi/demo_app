import 'package:demo_app/app.dart';
import 'package:demo_app/core/ai/mother_ai.dart';
import 'package:demo_app/core/data/app_store.dart';
import 'package:demo_app/core/l10n/l10n.dart';
import 'package:demo_app/core/models/context_note.dart';
import 'package:demo_app/core/widgets/child_monogram.dart';
import 'package:demo_app/core/widgets/child_switch.dart';
import 'package:demo_app/core/widgets/sheet_depth.dart';
import 'package:demo_app/core/widgets/rolling_text.dart';
import 'package:demo_app/core/widgets/app_nav_bar.dart';
import 'package:demo_app/core/widgets/demo_toast.dart';
import 'package:demo_app/features/chat/chat_history_page.dart';
import 'package:demo_app/features/chat/chat_page.dart';
import 'package:demo_app/features/home/home_page.dart';
import 'package:demo_app/features/learn/learn_page.dart';
import 'package:demo_app/features/profile/child_form_page.dart';
import 'package:demo_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'support.dart';

void main() {
  late AppStore store;
  late FakeGroq groq;

  Future<void> launch(
    WidgetTester tester, {
    bool family = true,
    AppLanguage? language,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    store = (await tester.runAsync(() => openTestStore(family: family)))!;
    addTearDown(() => tester.runAsync(store.close));
    if (language != null) {
      await tester.runAsync(() => store.setLanguage(language));
    }
    groq = FakeGroq();
    await tester.pumpWidget(
      MotherlyApp(
        store: store,
        ai: MotherAi(client: groq.client, apiKey: 'test'),
      ),
    );
    if (language != null) {
      // shadcn loads its words for a language on demand, which takes a real
      // moment; the app appears once all of them are there.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    // By the tab's accessible name: only the open tab shows its label.
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openNewChat(
    WidgetTester tester, {
    String label = 'Chats',
    String action = 'New chat',
  }) async {
    await tapTab(tester, label);
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  /// Sends a question and lets Mother AI's answer stream in.
  Future<void> ask(
    WidgetTester tester,
    String question, {
    String send = 'Send',
  }) async {
    await tester.enterText(find.byType(EditableText).last, question);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(send).last);
    await tester.pumpAndSettle();
  }

  Finder onHome(Finder matching) =>
      find.descendant(of: find.byType(HomeTab), matching: matching);

  testWidgets('the nav bar survives Android\'s zero-width first frame', (
    tester,
  ) async {
    for (final width in [0.0, 1.0, 120.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: width,
              child: AppNavBar(selectedIndex: 1, onSelected: (_) {}),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('home asks one question about one child', (tester) async {
    await launch(tester);

    expect(
      onHome(find.bySemanticsLabel('What’s on your mind about Emma?')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('motherPromptField')), findsOneWidget);
    // The conversation to pick back up is the newest one about Emma.
    expect(onHome(find.text('Continue where you left off')), findsOneWidget);
    expect(onHome(find.text(feverQuestion)), findsOneWidget);
    expect(onHome(find.text('Add your child')), findsNothing);
  });

  testWidgets('home without a child offers to add one', (tester) async {
    await launch(tester, family: false);

    expect(onHome(find.text('Add your child')), findsOneWidget);
    expect(onHome(find.text('Continue where you left off')), findsNothing);

    await tester.tap(onHome(find.text('Add a child')));
    await tester.pumpAndSettle();

    // Nothing is saved without a name and a birthday.
    await tester.tap(find.text('Add child'));
    await tester.pumpAndSettle();
    expect(find.text('Add their name.'), findsOneWidget);
    expect(find.text('Add their date of birth.'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'Mia');
    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add child'));
    await tester.pumpAndSettle();

    expect(store.children.single.name, 'Mia');
    expect(
      onHome(find.bySemanticsLabel('What’s on your mind about Mia?')),
      findsOneWidget,
    );
    expect(onHome(find.text('Add your child')), findsNothing);
  });

  testWidgets('the child pill switches who Home asks about', (tester) async {
    await launch(tester);

    await tester.tap(find.bySemanticsLabel(RegExp('^Asking about Emma')));
    await tester.pumpAndSettle();
    expect(find.text('Who is this about?'), findsOneWidget);

    await tester.tap(find.text('Daniel').last);
    await tester.pumpAndSettle();

    expect(find.text('Starting to put two words together'), findsOneWidget);
    // Only the name in the headline changes.
    expect(
      find.bySemanticsLabel('What’s on your mind about Daniel?'),
      findsOneWidget,
    );
    expect(onHome(find.text(rashQuestion)), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Asking about Daniel')),
      findsOneWidget,
    );
  });

  testWidgets('a topic frames the question without writing it', (tester) async {
    await launch(tester);

    expect(onHome(find.text('Ask anything about Emma')), findsOneWidget);
    await tester.tap(onHome(find.text('Sleep')));
    await tester.pumpAndSettle();
    expect(onHome(find.text('Tell me about Emma’s sleep')), findsOneWidget);

    await tester.tap(onHome(find.text('Sleep')));
    await tester.pumpAndSettle();
    expect(onHome(find.text('Ask anything about Emma')), findsOneWidget);
  });

  testWidgets('a question from Home streams in with the child as context', (
    tester,
  ) async {
    await launch(tester);

    await tester.tap(onHome(find.text('Sleep')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('motherPromptField')),
      'She keeps waking up',
    );
    await tester.pump();
    await tester.tap(onHome(find.bySemanticsLabel('Send')));
    await tester.pumpAndSettle();

    expect(
      find.text('A calm, predictable routine helps most.'),
      findsOneWidget,
    );
    expect(find.text('Keep the same steps every night.'), findsOneWidget);
    expect(find.text('Fine to handle at home'), findsOneWidget);
    expect(find.bySemanticsLabel('About Emma. Sleep'), findsOneWidget);

    final request = groq.requests.single;
    expect(request['model'], 'openai/gpt-oss-120b');
    expect(request['stream'], isTrue);
    expect(groq.lastContext, contains('about Emma, 6 months old'));
    expect(groq.lastContext, contains('Notes from the parent: Breastfed.'));
    expect(groq.lastContext, contains('topic Sleep'));
    // Nothing unrecorded is sent as if it were known.
    expect(groq.lastContext, isNot(contains('Allergies')));
  });

  testWidgets('what one chat learns about a child, the next one knows', (
    tester,
  ) async {
    await launch(tester);
    groq.review =
        '{"add": ["Fell and hurt her knee on 29 Sep 2026."], '
        '"update": [], "remove": []}';

    Future<void> askFromHome(String question) async {
      await tester.enterText(
        find.byKey(const Key('motherPromptField')),
        question,
      );
      await tester.pump();
      await tester.tap(onHome(find.bySemanticsLabel('Send')));
      await tester.pumpAndSettle();
    }

    await askFromHome('Emma fell off the sofa and hurt her knee');
    expect(find.text('Emma’s context updated'), findsOneWidget);
    final emma = store.children.first;
    expect(store.contextOf(emma).map((note) => note.text), [
      'Fell and hurt her knee on 29 Sep 2026.',
    ]);
    // The review read what was said about her.
    final review = (groq.reviews.single['messages'] as List).last as Map;
    expect(review['content'], contains('hurt her knee'));

    // Tapping the note shows what Mother AI now remembers.
    await tester.tap(find.text('Emma’s context updated'));
    await tester.pumpAndSettle();
    expect(find.text('Fell and hurt her knee on 29 Sep 2026.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    groq.review = '{"add": [], "update": [], "remove": []}';
    await askFromHome('Is it normal that she is still limping?');

    expect(groq.requests, hasLength(2));
    expect(
      groq.lastContext,
      contains('What earlier chats told you about Emma'),
    );
    expect(
      groq.lastContext,
      contains('Fell and hurt her knee on 29 Sep 2026.'),
    );
    expect(
      groq.lastContext,
      contains('"Emma fell off the sofa and hurt her knee"'),
    );
    // Nothing changed this time, so nothing is said.
    expect(find.text('Emma’s context updated'), findsNothing);
  });

  testWidgets('a child’s context can be corrected in Profile', (tester) async {
    await launch(tester);
    final daniel = store.children.last;
    await tester.runAsync(
      () => store.reviseContext(
        daniel,
        const ContextUpdate(
          added: [
            'Started nursery on 22 Sep 2026.',
            'Has had a cough since 27 Sep 2026.',
          ],
        ),
      ),
    );
    await tapTab(tester, 'Profile');
    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Daniel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Context'), findsOneWidget);
    expect(find.text('Has had a cough since 27 Sep 2026.'), findsOneWidget);

    await tester.ensureVisible(find.text('Edit').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    final form = find
        .descendant(
          of: find.byType(ChildFormPage),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Started nursery on 22 Sep 2026.'),
      200,
      scrollable: form,
    );
    await tester.enterText(
      find.text('Has had a cough since 27 Sep 2026.'),
      'Cough cleared by 1 Oct 2026.',
    );
    await tester.tap(find.bySemanticsLabel('Remove this note').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.contextOf(daniel).map((note) => note.text), [
      'Cough cleared by 1 Oct 2026.',
    ]);
  });

  testWidgets('a new conversation is saved and listed in Chats', (
    tester,
  ) async {
    await launch(tester);
    await openNewChat(tester);
    await ask(tester, 'How much sleep does a baby need?');

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(ChatHistoryTab),
        matching: find.text('How much sleep does a baby need?'),
      ),
      findsOneWidget,
    );
    expect(store.conversations.first.care?.name, 'home');
    final saved = (await tester.runAsync(
      () => store.messages(store.conversations.first.id),
    ))!;
    expect(saved.map((m) => m.isMine), [true, false]);
    expect(saved.last.reply.steps, hasLength(2));
  });

  testWidgets('a past conversation opens with its answers', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Chats');
    await tester.tap(
      find.descendant(
        of: find.byType(ChatHistoryTab),
        matching: find.text(rashQuestion),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This needs a doctor straight away.'), findsOneWidget);
    expect(find.text('Get urgent help now'), findsOneWidget);
    expect(find.text('Call emergency services'), findsOneWidget);

    // The follow-up is sent with the conversation so far.
    await ask(tester, 'He seems a bit better now');
    final history = groq.requests.single['messages'] as List;
    expect(history.map((m) => (m as Map)['role']), [
      'system',
      'user',
      'assistant',
      'user',
    ]);
  });

  testWidgets('a failed answer says why and can be asked again', (
    tester,
  ) async {
    await launch(tester);
    await openNewChat(tester);
    groq.failures.add(401);
    await ask(tester, 'Is it normal to feel this tired?');

    expect(find.text(MotherAiException.refused.message), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text(MotherAiException.refused.message), findsNothing);
    expect(
      find.text('A calm, predictable routine helps most.'),
      findsOneWidget,
    );
    expect(groq.requests, hasLength(2));
  });

  // Only one language other than English is loaded per test file: shadcn loads
  // each language's words lazily, and the test binding can't finish a second
  // such load in the same run (see language_test.dart). Real devices are fine.
  testWidgets('choosing Arabic turns the whole app around', (tester) async {
    await launch(tester, language: AppLanguage.ar);

    final ar = L10n.forLanguage(AppLanguage.ar);
    final context = tester.element(find.byType(HomeTab));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Localizations.localeOf(context).languageCode, 'ar');

    // Home comes first, so it is the tab at the trailing end of the bar.
    final home = tester.getCenter(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel(ar.tr('Home')),
      ),
    );
    final profile = tester.getCenter(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel(ar.tr('Profile')),
      ),
    );
    expect(home.dx, greaterThan(profile.dx));

    // Every screen still lays out without overflowing.
    for (final tab in ['Chats', 'Learn', 'Profile', 'Home']) {
      await tapTab(tester, ar.tr(tab));
    }
    await openNewChat(tester, label: ar.tr('Chats'), action: ar.tr('New chat'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the medical disclaimer is a sheet like the other choices', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Profile');
    await tester.drag(
      find
          .descendant(
            of: find.byType(ProfileTab),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Medical disclaimer'));
    await tester.pumpAndSettle();
    // The same bottom sheet Language and Units open, not a dialog card.
    expect(find.byType(ShadSheet), findsOneWidget);
    expect(find.byType(SheetRise), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.byType(ShadSheet), findsNothing);
  });

  testWidgets('the page steps back under a sheet and keeps what was typed', (
    tester,
  ) async {
    await launch(tester);
    await tester.enterText(
      find.byKey(const Key('motherPromptField')),
      'Half-typed question',
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(RegExp('^Asking about Emma')));
    // One frame to start the sheet's clock, then halfway through its rise.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));
    final scale = tester
        .widgetList<Transform>(
          find.ancestor(
            of: find.byType(HomeTab),
            matching: find.byType(Transform),
          ),
        )
        .map((t) => t.transform.entry(0, 0))
        .reduce((a, b) => a < b ? a : b);
    expect(scale, lessThan(1));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Close').last);
    await tester.pumpAndSettle();
    expect(find.text('Half-typed question'), findsOneWidget);
  });

  testWidgets('home keyboard does not lift the persistent navigation', (
    tester,
  ) async {
    await launch(tester);

    final navBottomBefore = tester.getBottomLeft(find.byType(AppNavBar)).dy;
    await tester.tap(find.byKey(const Key('motherPromptField')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await tester.pumpAndSettle();

    expect(tester.getBottomLeft(find.byType(AppNavBar)).dy, navBottomBefore);
  });

  testWidgets('the chats tab lists history with a new-chat action', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Chats');

    Finder inChats(Finder matching) =>
        find.descendant(of: find.byType(ChatHistoryTab), matching: matching);

    expect(inChats(find.text('Chats')), findsOneWidget);
    expect(inChats(find.text('New chat')), findsOneWidget);
    expect(inChats(find.text(rashQuestion)), findsOneWidget);
    expect(inChats(find.text('Urgent')), findsOneWidget);
  });

  testWidgets('with no chats yet, Chats says where they will be', (
    tester,
  ) async {
    await launch(tester, family: false);
    await tapTab(tester, 'Chats');

    expect(find.text('No chats yet'), findsOneWidget);
  });

  testWidgets('switching tabs keeps a single persistent nav bar mounted', (
    tester,
  ) async {
    await launch(tester);

    final navBarBefore = tester.element(find.byType(AppNavBar));
    await tapTab(tester, 'Chats');

    expect(tester.element(find.byType(AppNavBar)), same(navBarBefore));
    // Home stays alive underneath, just hidden.
    expect(
      find.text('Start from a topic', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('tabs slide both ways, so you can get back to a previous tab', (
    tester,
  ) async {
    await launch(tester);

    double opacityOf(int tabIndex) => tester
        .widget<FadeTransition>(
          find
              .descendant(
                of: find.byKey(ValueKey('tab_$tabIndex')),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    expect(opacityOf(0), 1);

    await tapTab(tester, 'Chats');
    expect(opacityOf(1), 1);
    expect(opacityOf(0), 0);

    await tapTab(tester, 'Home');
    expect(opacityOf(0), 1);
    expect(opacityOf(1), 0);
  });

  testWidgets('system back returns a secondary tab to Home', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Learn');
    expect(tester.widget<AppNavBar>(find.byType(AppNavBar)).selectedIndex, 2);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(tester.widget<AppNavBar>(find.byType(AppNavBar)).selectedIndex, 0);
  });

  testWidgets('a new chat is immersive, with no tab bar', (tester) async {
    await launch(tester);
    await openNewChat(tester);

    expect(find.textContaining('Ask me anything'), findsOneWidget);
    expect(find.text('Start from a topic'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
    expect(find.byKey(const Key('chatMessageField')), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsNothing);
  });

  testWidgets('a chat can choose and keep who it is about', (tester) async {
    await launch(tester);
    await openNewChat(tester);

    final chooser = find.bySemanticsLabel(RegExp('^General question'));
    expect(chooser, findsOneWidget);
    await tester.tap(chooser);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emma').last);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('^About Emma')), findsOneWidget);
    expect(find.text('Ask about Emma'), findsWidgets);
  });

  testWidgets('changing who a chat is about moves like Home does', (
    tester,
  ) async {
    await launch(tester);
    await openNewChat(tester);

    Finder badges() => find.descendant(
      of: find.descendant(
        of: find.byType(ChatPage),
        matching: find.byType(SwitchingMonogram),
      ),
      matching: find.byType(ChildMonogram),
    );
    expect(badges(), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^General question')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emma').last);
    // The sheet leaves first; then the badge turns over into Emma's while
    // the name and the headline roll to hers.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 150));
    expect(badges(), findsNWidgets(2));
    expect(find.byType(RollingText), findsWidgets);

    await tester.pumpAndSettle();
    expect(badges(), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('What’s on your mind|Ask me anything')),
      findsWidgets,
    );
  });

  testWidgets('once a chat has started, who it is about is fixed', (
    tester,
  ) async {
    await launch(tester);
    await openNewChat(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('^General question')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Emma').last);
    await tester.pumpAndSettle();

    await ask(tester, 'How much sleep does she need?');

    expect(find.bySemanticsLabel('About Emma'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('About Emma'));
    await tester.pumpAndSettle();
    expect(find.text('Who is this about?'), findsNothing);
  });

  testWidgets('answers state their care level up front', (tester) async {
    await launch(tester);
    await openNewChat(tester);

    await ask(tester, 'How much sleep do young children need?');
    expect(find.text('Fine to handle at home'), findsOneWidget);

    await ask(tester, 'There are purple spots that don’t fade under a glass');
    expect(find.text('Get urgent help now'), findsOneWidget);
    expect(find.text('Call emergency services'), findsOneWidget);
  });

  testWidgets('an article ends by handing off to chat', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Learn');
    // Home also puts this article forward, so name the Learn copy.
    await tester.tap(
      find.descendant(
        of: find.byType(LearnTab),
        matching: find.text('Understanding growth spurts'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('When to get help'), findsOneWidget);
    await tester.tap(find.text('Ask Mother AI about this'));
    await tester.pumpAndSettle();

    expect(
      find.text('Picking up from “Understanding growth spurts”'),
      findsOneWidget,
    );
  });

  testWidgets('Learn speaks as Mother AI, not as another organisation', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Learn');

    for (final outside in ['NHS', 'UNICEF', 'Cleveland']) {
      expect(find.textContaining(outside), findsNothing);
    }
    expect(find.text('Health  ·  4 min read'), findsOneWidget);
  });

  testWidgets('a child in Profile opens their details', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Profile');
    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Daniel'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Peanuts (mild)'), findsOneWidget);
    expect(find.text('Ask about Daniel'), findsOneWidget);
  });

  testWidgets('a child can be edited, and removed after confirming', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Profile');
    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Daniel'),
      ),
    );
    await tester.pumpAndSettle();
    // The sheet's, above the account's own Edit.
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).first, 'Danny');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.children.last.name, 'Danny');
    expect(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Danny'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Danny'),
      ),
    );
    await tester.pumpAndSettle();
    // The sheet's, above the account's own Edit.
    await tester.tap(find.text('Edit').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Remove Danny'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ChildFormPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Remove Danny'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Danny?'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(store.children.map((c) => c.name), ['Emma']);
    // His conversation went with him.
    expect(store.conversations.map((c) => c.title), [feverQuestion]);
  });

  testWidgets('Learn filters by topic and marks links to other sites', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Learn');
    Finder inLearn(Finder matching) =>
        find.descendant(of: find.byType(LearnTab), matching: matching);

    final filters = inLearn(
      find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
      ),
    ).last;
    await tester.scrollUntilVisible(
      inLearn(find.text('Sleep')),
      120,
      scrollable: filters,
    );
    await tester.ensureVisible(inLearn(find.text('Sleep')));
    await tester.pumpAndSettle();
    await tester.tap(inLearn(find.text('Sleep')));
    await tester.pumpAndSettle();
    expect(inLearn(find.text('Building a bedtime routine')), findsOneWidget);
    expect(inLearn(find.text('Fever 101: when to worry')), findsNothing);

    await tester.scrollUntilVisible(
      inLearn(find.text('Safe sleep in the first year')),
      200,
      scrollable: inLearn(find.byType(Scrollable)).first,
    );
    expect(inLearn(find.text('Sleep  ·  Opens a website')), findsOneWidget);
  });

  testWidgets('a Learn search with no match offers to ask instead', (
    tester,
  ) async {
    await launch(tester);
    await tapTab(tester, 'Learn');
    await tester.enterText(
      find.descendant(
        of: find.byType(LearnTab),
        matching: find.byType(EditableText),
      ),
      'teething',
    );
    await tester.pumpAndSettle();

    expect(find.text('No guides on “teething” yet'), findsOneWidget);
    await tester.tap(find.text('Ask Mother AI'));
    await tester.pumpAndSettle();
    // The search waits in the field for the parent to finish.
    expect(find.text('teething'), findsOneWidget);
    expect(find.byKey(const Key('chatMessageField')), findsOneWidget);
    expect(groq.requests, isEmpty);
  });

  testWidgets('a toast can always be dismissed', (tester) async {
    await launch(tester);
    showDemoToast(
      tester.element(find.byType(HomeTab)),
      title: 'The phone app didn’t open',
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('The phone app didn’t open'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('The phone app didn’t open'), findsNothing);
  });

  testWidgets('the back swipe leaves exactly as the back button does', (
    tester,
  ) async {
    await launch(tester);

    Future<void> openChat() async {
      await tapTab(tester, 'Chats');
      await tester.tap(
        find.descendant(
          of: find.byType(ChatHistoryTab),
          matching: find.text(rashQuestion),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> gesture(String method, [double progress = 0]) async {
      final message = const StandardMethodCodec().encodeMethodCall(
        MethodCall(method, <String, Object?>{
          'touchOffset': <double>[5, 300],
          'progress': progress,
          'swipeEdge': 0,
        }),
      );
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/backgesture',
        message,
        (_) {},
      );
      await tester.pump();
    }

    double chatLeft() => tester.getTopLeft(find.byType(ChatPage)).dx;

    /// Where the chat is at intervals after it starts to leave.
    Future<List<double>> leaving() async {
      final places = <double>[];
      // The whole movement takes 340ms and is mostly done in the first
      // hundred.
      for (final ms in [10, 10, 20, 40, 60]) {
        await tester.pump(Duration(milliseconds: ms));
        places.add(chatLeft());
      }
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsNothing);
      return places;
    }

    await openChat();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump();
    final byButton = await leaving();

    await openChat();
    // A swipe doesn't drag the chat along with the finger: it stays put
    // until it is let go, and then it goes the way the button sends it.
    await gesture('startBackGesture');
    await gesture('updateBackGestureProgress', 0.5);
    expect(chatLeft(), 0);
    await gesture('commitBackGesture');
    final bySwipe = await leaving();

    expect(byButton.first, greaterThan(0));
    for (final (i, place) in bySwipe.indexed) {
      expect(place, moreOrLessEquals(byButton[i], epsilon: 1.5));
    }
    expect(find.text('New chat'), findsOneWidget);
  });

  testWidgets('a screen leaves as fast as it arrived', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Profile');
    await tester.drag(
      find
          .descendant(
            of: find.byType(ProfileTab),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -0.1),
    );
    await tester.tap(find.text('Add a child'));
    await tester.pump();

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    double formLeft() => tester.getTopLeft(find.byType(ChildFormPage)).dx;

    // How far across the screen it has got after a tenth of a second.
    await tester.pump(const Duration(milliseconds: 100));
    final arrived = 1 - formLeft() / width;
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final left = formLeft() / width;
    await tester.pumpAndSettle();

    expect(arrived, greaterThan(0.5));
    expect(left, moreOrLessEquals(arrived, epsilon: 0.15));
  });
}
