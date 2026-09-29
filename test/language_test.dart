import 'package:demo_app/app.dart';
import 'package:demo_app/core/ai/mother_ai.dart';
import 'package:demo_app/core/data/app_store.dart';
import 'package:demo_app/core/l10n/l10n.dart';
import 'package:demo_app/core/models/preferences.dart';
import 'package:demo_app/core/widgets/app_nav_bar.dart';
import 'package:demo_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// Choosing a language in Profile changes the whole app and reaches Mother
/// AI. Kept in a file of its own: the test binding can't finish loading
/// shadcn's words for a second language in one run (real devices can).
void main() {
  late AppStore store;
  late FakeGroq groq;

  Future<void> launch(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    store = (await tester.runAsync(openTestStore))!;
    addTearDown(() => tester.runAsync(store.close));
    groq = FakeGroq();
    await tester.pumpWidget(
      MotherlyApp(
        store: store,
        ai: MotherAi(client: groq.client, apiKey: 'test'),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ask(WidgetTester tester, String question, String send) async {
    await tester.enterText(find.byType(EditableText).last, question);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(send).last);
    await tester.pumpAndSettle();
  }

  testWidgets('the language and units reach Mother AI', (tester) async {
    await launch(tester);
    await tapTab(tester, 'Profile');
    // Clear of the floating tab bar, which would take the tap.
    await tester.drag(
      find
          .descendant(
            of: find.byType(ProfileTab),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Units'));
    await tester.pumpAndSettle();
    // The phone here is set to the US, so imperial is where it starts.
    expect(store.units, Units.imperial);
    await tester.tap(find.textContaining('Metric  ·'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(store.language, AppLanguage.es);
    expect(
      find.descendant(
        of: find.byType(ProfileTab),
        matching: find.text('Español'),
      ),
      findsOneWidget,
    );

    // The whole app is now in Spanish, tab bar included.
    final es = L10n.forLanguage(AppLanguage.es);
    await tapTab(tester, es.tr('Chats'));
    await tester.tap(find.text(es.tr('New chat')));
    await tester.pumpAndSettle();
    await ask(tester, '¿Cuánto debería beber?', es.tr('Send'));
    expect(groq.lastContext, contains('Reply in Español.'));
    expect(groq.lastContext, contains('Use metric units'));
  });
}
