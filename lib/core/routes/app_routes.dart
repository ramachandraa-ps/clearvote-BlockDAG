import 'package:flutter/material.dart';
import 'package:clearvote/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingScreen(),
    // Add other routes as they become available
    // login: (context) => const LoginScreen(),
    // home: (context) => const HomeScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // For routes that need special handling or parameters
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }

  // Helper method to determine initial route based on first launch
  static Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    
    if (!hasSeenOnboarding) {
      return onboarding;
    } else {
      return login;
    }
  }
}