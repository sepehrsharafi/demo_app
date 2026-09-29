import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/ai/mother_ai.dart';
import 'core/data/app_store.dart';
import 'core/theme/motion_warm_up.dart';

Future<void> main() async {
  // Draw what the transitions draw once, off screen, before the first frame
  // (see MotionWarmUp), so the first sheet or toast of a session is as
  // smooth as the tenth. Must be set before the binding starts.
  PaintingBinding.shaderWarmUp = const MotionWarmUp();
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status/navigation bars so screen artwork (e.g. the home
  // hero) can flow edge-to-edge instead of sitting below a flat system strip.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Opened behind the splash, so the first frame already knows the family.
  final store = await AppStore.open();
  runApp(MotherlyApp(store: store, ai: MotherAi()));
}
