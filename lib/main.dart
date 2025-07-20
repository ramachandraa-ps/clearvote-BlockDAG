import 'package:flutter/material.dart';
import 'package:clearvote/core/theme/app_theme.dart';
import 'package:clearvote/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clearvote/features/home/screens/dao_submission_screen.dart';
import 'package:clearvote/features/history/screens/history_screen.dart';
import 'package:clearvote/features/about/screens/about_screen.dart';
import 'package:clearvote/features/comparison/screens/comparison_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize app configuration
  AppConfig.initConfig(Environment.dev);
  
  // Run the app with DAOSubmissionScreen as the home screen
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
      home: const DAOSubmissionScreen(), // Directly use DAOSubmissionScreen as the home widget
      routes: {
        '/history': (context) => const HistoryScreen(),
        '/about': (context) => const AboutScreen(),
        '/comparison': (context) => const ComparisonScreen(),
      },
    );
  }
}