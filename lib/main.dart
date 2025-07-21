import 'package:flutter/material.dart';
import 'package:clearvote/core/theme/app_theme.dart';
import 'package:clearvote/core/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:clearvote/features/home/screens/dao_submission_screen.dart';
import 'package:clearvote/features/history/screens/history_screen.dart';
import 'package:clearvote/features/about/screens/about_screen.dart';
import 'package:clearvote/features/comparison/screens/comparison_screen.dart';
import 'package:clearvote/features/auth/screens/login_screen.dart';
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
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  // Initialize app configuration
  AppConfig.initConfig(Environment.dev);
  
  // Run the app
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
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const DAOSubmissionScreen(),
        '/history': (context) => const HistoryScreen(),
        '/about': (context) => const AboutScreen(),
        '/comparison': (context) => const ComparisonScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data and the user is properly authenticated
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.uid.isNotEmpty) {
          // Double-check if the user is actually authenticated
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.uid.isNotEmpty) {
            return const DAOSubmissionScreen();
          }
        }
        
        // Otherwise, user is not signed in
        return const LoginScreen();
      },
    );
  }
}