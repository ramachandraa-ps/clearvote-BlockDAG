import 'package:flutter/material.dart';
import 'package:clearvote/core/theme/app_theme.dart';
import 'package:clearvote/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clearvote/features/home/screens/dao_submission_screen.dart';
import 'package:clearvote/features/history/screens/history_screen.dart';
import 'package:clearvote/features/about/screens/about_screen.dart';
import 'package:clearvote/features/comparison/screens/comparison_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clearvote/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to load environment variables, but continue if file is missing
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Continue without .env file
    debugPrint('No .env file found. Some features may be limited.');
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Sign in anonymously to enable Firestore access without requiring user login
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Signed in anonymously');
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
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