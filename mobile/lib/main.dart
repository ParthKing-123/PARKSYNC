import 'package:flutter/material.dart';
import 'shared/theme/app_theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase and other services here later
  runApp(const ParkSyncApp());
}

class ParkSyncApp extends StatelessWidget {
  const ParkSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ParkSync',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
