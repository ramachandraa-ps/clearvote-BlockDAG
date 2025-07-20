import 'package:flutter/material.dart';
import 'package:clearvote/core/routes/app_routes.dart';
import 'package:clearvote/core/theme/app_theme.dart';
import 'package:clearvote/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clearvote/features/splash/screens/splash_screen.dart';
import 'package:clearvote/features/home/screens/home_screen.dart';
import 'package:clearvote/features/summary/screens/summary_screen.dart';
import 'package:clearvote/features/history/screens/history_screen.dart';
import 'package:clearvote/features/about/screens/about_screen.dart';
import 'package:clearvote/features/comparison/screens/comparison_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  AppConfig.initConfig(Environment.dev);
  
  // Determine initial route based on whether onboarding has been seen
  final initialRoute = await AppRoutes.getInitialRoute();
  
  runApp(ClearVoteApp(initialRoute: initialRoute));
}

class ClearVoteApp extends StatelessWidget {
  final String initialRoute;
  
  const ClearVoteApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        ...AppRoutes.routes,
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/history': (context) => const HistoryScreen(),
        '/about': (context) => const AboutScreen(),
        '/comparison': (context) => const ComparisonScreen(),
      },
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}