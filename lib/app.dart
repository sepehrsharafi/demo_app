import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/ai/mother_ai.dart';
import 'core/data/app_scope.dart';
import 'core/data/app_store.dart';
import 'core/l10n/l10n.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/sheet_depth.dart';

class MotherlyApp extends StatelessWidget {
  const MotherlyApp({super.key, required this.store, required this.ai});

  final AppStore store;
  final MotherAi ai;

  @override
  Widget build(BuildContext context) {
    // shadcn_ui components on top of a Material app, so Scaffold, text
    // fields and page routes keep working underneath them. The scope sits
    // above both, so sheets and pushed pages see the same family.
    //
    // The language sits above the app too: choosing another one gives the
    // whole app its words, its direction and its type settings in one pass.
    return AppScope(
      store: store,
      ai: ai,
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: store.languageNotifier,
        builder: (context, language, _) {
          AppText.useLanguage(language);
          return ShadApp.custom(
            themeMode: ThemeMode.light,
            theme: AppTheme.shad(language),
            appBuilder: (context) => MaterialApp(
              title: 'Mother AI',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.material(Theme.of(context), language),
              locale: language.locale,
              supportedLocales: [
                for (final language in AppLanguage.values) language.locale,
              ],
              localizationsDelegates: const [
                L10n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalShadLocalizations.delegate,
              ],
              home: const AppShell(),
              navigatorObservers: [SheetDepth.observer],
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark.copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: AppColors.ground,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                  child: MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler: mediaQuery.textScaler.clamp(
                        minScaleFactor: 0.9,
                        maxScaleFactor: 1.3,
                      ),
                    ),
                    child: ShadAppBuilder(child: child),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
