import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status/navigation bars so screen artwork (e.g. the home
  // hero) can flow edge-to-edge instead of sitting below a flat system strip.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MotherlyApp());
}
