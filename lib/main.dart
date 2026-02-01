import 'package:flutter/material.dart';

import 'app.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  initRouter();
  runApp(const App());
}
