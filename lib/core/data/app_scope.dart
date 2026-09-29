import 'package:flutter/widgets.dart';

import '../ai/mother_ai.dart';
import 'app_store.dart';

/// Hands the store and Mother AI to every screen, sheet and pushed page.
/// A widget that reads the store with [of] rebuilds when it changes.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    super.key,
    required AppStore store,
    required this.ai,
    required super.child,
  }) : super(notifier: store);

  final MotherAi ai;

  /// The store. [listen] false reads it once, for use in callbacks.
  static AppStore of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppScope>()
        : context.getInheritedWidgetOfExactType<AppScope>();
    return scope!.notifier!;
  }

  static MotherAi aiOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.ai;
}
