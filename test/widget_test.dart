import 'package:demo_app/app.dart';
import 'package:demo_app/core/widgets/app_nav_bar.dart';
import 'package:demo_app/features/home/home_page.dart';
import 'package:demo_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page exposes its core content', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();

    // Children are listed on both Home and Profile (which manages them), so
    // scope the child assertions to the tab under test.
    Finder onHome(Finder matching) =>
        find.descendant(of: find.byType(HomeTab), matching: matching);

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.textContaining('Here for'), findsOneWidget);
    expect(find.text('in your journey'), findsOneWidget);
    expect(onHome(find.text('Emma')), findsOneWidget);
    expect(onHome(find.text('Daniel')), findsOneWidget);
    expect(find.byKey(const Key('motherPromptField')), findsOneWidget);
  });

  testWidgets('chat tab opens conversation history with a new-chat action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Continue where you left off.'), findsOneWidget);
    expect(find.text('Start a new chat'), findsOneWidget);
    expect(find.text('Baby fever after vaccines'), findsOneWidget);
  });

  testWidgets('switching tabs keeps a single persistent nav bar mounted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();

    final navBarBefore = tester.element(find.byType(AppNavBar));
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    final navBarAfter = tester.element(find.byType(AppNavBar));

    // Tab switches reuse the same nav bar element instead of pushing a new
    // route (which would tear down and rebuild it from scratch).
    expect(navBarAfter, same(navBarBefore));
    // Home stays alive underneath the IndexedStack (just offstage) rather
    // than being navigated away from.
    expect(find.text('Good morning', skipOffstage: false), findsOneWidget);
  });

  testWidgets('tabs fade both ways, so you can get back to a previous tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();

    // Read the *rendered* opacity, not the requested one: a frozen fade still
    // reports the right target while painting the old tab over everything.
    // `.first` = the shell's own fade for that tab; a tab's content may hold
    // fades of its own further down (Home's entrance animation, for one).
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

    Future<void> tapTab(String label) async {
      await tester.tap(
        find.descendant(of: find.byType(AppNavBar), matching: find.text(label)),
      );
      await tester.pumpAndSettle();
    }

    expect(opacityOf(0), 1);

    await tapTab('Chat');
    expect(opacityOf(1), 1);
    expect(opacityOf(0), 0);

    // Going back is the direction that regressed: the outgoing tab has to
    // actually finish fading out or it stays stacked on top of the new one.
    await tapTab('Home');
    expect(opacityOf(0), 1);
    expect(opacityOf(1), 0);
  });

  testWidgets('starting a new chat opens the immersive chat without a navbar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a new chat'));
    await tester.pumpAndSettle();

    expect(find.text('Always here for you'), findsOneWidget);
    expect(find.text('Hi there! I’m Mother AI.'), findsOneWidget);
    expect(find.text('Fever & symptoms'), findsOneWidget);
    expect(find.byKey(const Key('chatMessageField')), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    // The active conversation is immersive: no bottom navigation on screen.
    expect(find.bySemanticsLabel('Profile'), findsNothing);
  });

  testWidgets('a chat can select and visibly retain child context', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a new chat'));
    await tester.pumpAndSettle();

    expect(find.text('Who is this about?'), findsOneWidget);
    await tester.tap(find.text('Who is this about?'));
    await tester.pumpAndSettle();

    expect(find.text('Who is this chat about?'), findsOneWidget);
    expect(find.textContaining('profile details as context'), findsOneWidget);
    await tester.tap(find.text('Emma').last);
    await tester.pumpAndSettle();

    expect(find.text('About Emma  ·  6 months old'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ask about Emma...'), findsOneWidget);
  });

  testWidgets('the chat attachment button offers media and file sources', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a new chat'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add attachment'));
    await tester.pumpAndSettle();

    expect(find.text('Add to your message'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('Up to 10 MB per attachment'), findsOneWidget);
  });

  testWidgets('tapping a child on Home opens a chat about that child', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(HomeTab), matching: find.text('Daniel')),
    );
    await tester.pumpAndSettle();

    expect(find.text('About Daniel  ·  2 years old'), findsOneWidget);
    expect(find.textContaining('about Daniel’s health'), findsOneWidget);
  });

  testWidgets('deleting the account asks for confirmation first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MotherlyApp());
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.text('Profile'),
      ),
    );
    await tester.pumpAndSettle();

    // Every tab stays mounted, so the scroll target has to be named.
    final profileList = find
        .descendant(
          of: find.byType(ProfileTab),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      300,
      scrollable: profileList,
    );
    // ...and then clear of the floating nav bar, which would eat the tap.
    await tester.drag(profileList, const Offset(0, -220));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete account?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);

    // Backing out leaves the account alone.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete account?'), findsNothing);
  });
}
