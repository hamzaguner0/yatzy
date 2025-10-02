import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatzy_tr/app/router.dart';
import 'package:yatzy_tr/app/theme.dart';
import 'package:yatzy_tr/features/game/data/persistence.dart';
import 'package:yatzy_tr/features/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistence
  final prefs = await SharedPreferences.getInstance();
  initPersistence(prefs);

  runApp(
    const ProviderScope(
      child: YatzyApp(),
    ),
  );
}

/// Main app widget
class YatzyApp extends ConsumerWidget {
  const YatzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = createRouter();

    return MaterialApp.router(
      title: 'Yatzy TR',
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: router,

      // Theme
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: settings.themePreference.themeMode,

      // Localization
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('tr', ''),
      ],

      // Accessibility
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.5),
          ),
          child: child!,
        );
      },
    );
  }
}
