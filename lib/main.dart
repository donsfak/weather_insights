// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/cache_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'managers/settings_manager.dart';
import 'services/widget_service.dart';
import 'services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize widget service
  await WidgetService.initialize();

  // Initialize notification service
  await NotificationService.initialize();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(CachedWeatherAdapter());
  Hive.registerAdapter(CachedAirQualityAdapter());

  await SettingsManager().init();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'system';
  final initialThemeMode = savedTheme == 'dark'
      ? ThemeMode.dark
      : savedTheme == 'light'
      ? ThemeMode.light
      : ThemeMode.system;

  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setString('themeMode', 'dark');
      } else {
        _themeMode = ThemeMode.light;
        prefs.setString('themeMode', 'light');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: SettingsManager().locale,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather Insights App',
          themeMode: _themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF667eea),
            cardColor: Colors.white.withOpacity(0.2),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme)
                .apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                  fontFamilyFallback: [
                    'Noto Sans',
                    'Noto Sans Symbols',
                    'Noto Color Emoji',
                  ],
                ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E3C72),
            cardColor: Colors.black.withOpacity(0.2),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
                .apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                  fontFamilyFallback: [
                    'Noto Sans',
                    'Noto Sans Symbols',
                    'Noto Color Emoji',
                  ],
                ),
          ),
          home: HomeScreen(
            onToggleTheme: _toggleTheme,
            isDarkMode: _themeMode == ThemeMode.dark,
          ),
        );
      },
    );
  }
}
