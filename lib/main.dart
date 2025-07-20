import 'package:flutter/material.dart';
import 'package:clearvote/core/routes/app_routes.dart';
import 'package:clearvote/core/theme/app_theme.dart';
import 'package:clearvote/core/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  AppConfig.initConfig(Environment.dev);
  
  runApp(const ClearVoteApp());
}

class ClearVoteApp extends StatelessWidget {
  const ClearVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login, // Changed from onboarding to login
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}