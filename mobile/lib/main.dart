import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parksync/l10n/app_localizations.dart';
import 'core/locale_provider.dart';
import 'core/theme_provider.dart';
import 'core/user_state_service.dart';
import 'shared/theme/app_theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initThemeMode();
  await UserStateService.instance.init();
  runApp(const ParkSyncApp());
}

class ParkSyncApp extends StatelessWidget {
  const ParkSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: appLocale,
          builder: (context, locale, _) {
            return MaterialApp.router(
              title: 'ParkSync',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('mr'),
                Locale('hi'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
