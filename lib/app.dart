import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_theme.dart';
import 'package:myapp/routes/app_routes.dart';

/// Main application widget with theme support
class StudyApp extends StatefulWidget {
  const StudyApp({super.key});

  @override
  State<StudyApp> createState() => _StudyAppState();
}

class _StudyAppState extends State<StudyApp> {
  // ThemeMode _themeMode = ThemeMode.system
  final ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study App',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      initialRoute: AppRoutes.splash,
      // Routes are still needed for navigation from the dashboard
      onGenerateRoute: AppRoutes.generateRoute,

      // Builder for global theme access
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}

/// Inherited widget for theme management
class ThemeInheritedWidget extends InheritedWidget {
  const ThemeInheritedWidget({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
    required this.toggleTheme,
    required super.child,
  });

  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;
  final VoidCallback toggleTheme;

  static ThemeInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeInheritedWidget>();
  }

  @override
  bool updateShouldNotify(ThemeInheritedWidget oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}
