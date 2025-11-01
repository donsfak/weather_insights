import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Insights App',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: HomeScreen(
  onToggleTheme: _toggleTheme,
  isDarkMode: _themeMode == ThemeMode.dark,
),

    );
  }
}
