import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/food_provider.dart';
import 'providers/water_provider.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_preferences.dart';

/// Controller untuk ganti tema
class ThemeController extends InheritedWidget {
  final Function(bool isDark) changeTheme;

  const ThemeController({
    super.key,
    required this.changeTheme,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<ThemeController>();
    assert(controller != null, 'No ThemeController found in context');
    return controller!;
  }

  @override
  bool updateShouldNotify(ThemeController oldWidget) => false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔑 Load dark mode dari SharedPreferences
  final isDarkMode = await ThemePreferences.loadTheme();

  runApp(DietTrackerApp(isDarkMode: isDarkMode));
}

class DietTrackerApp extends StatefulWidget {
  final bool isDarkMode;

  const DietTrackerApp({super.key, required this.isDarkMode});

  @override
  State<DietTrackerApp> createState() => _DietTrackerAppState();
}

class _DietTrackerAppState extends State<DietTrackerApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void _changeTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    // 💾 Simpan ke SharedPreferences
    ThemePreferences.saveTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
      changeTheme: _changeTheme,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FoodProvider()),
          ChangeNotifierProvider(create: (_) => WaterProvider()),
        ],
        child: MaterialApp(
          title: 'Diet Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
