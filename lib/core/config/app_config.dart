import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableAnalytics;
  final bool enableCrashReporting;

  static late AppConfig _instance;

  factory AppConfig({
    required Environment environment,
    required String apiBaseUrl,
    bool enableAnalytics = false,
    bool enableCrashReporting = false,
  }) {
    _instance = AppConfig._internal(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
    );
    return _instance;
  }

  AppConfig._internal({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableAnalytics,
    required this.enableCrashReporting,
  });

  static AppConfig get instance => _instance;

  static bool get isProduction => _instance.environment == Environment.prod;
  static bool get isDevelopment => _instance.environment == Environment.dev;
  static bool get isStaging => _instance.environment == Environment.staging;

  static void initConfig(Environment env) {
    switch (env) {
      case Environment.dev:
        AppConfig(
          environment: Environment.dev,
          apiBaseUrl: 'https://dev-api.clearvote.example',
          enableAnalytics: false,
          enableCrashReporting: false,
        );
        break;
      case Environment.staging:
        AppConfig(
          environment: Environment.staging,
          apiBaseUrl: 'https://staging-api.clearvote.example',
          enableAnalytics: true,
          enableCrashReporting: true,
        );
        break;
      case Environment.prod:
        AppConfig(
          environment: Environment.prod,
          apiBaseUrl: 'https://api.clearvote.example',
          enableAnalytics: true,
          enableCrashReporting: true,
        );
        break;
    }
    if (kDebugMode) {
      print('App initialized with ${env.name} environment');
      print('API URL: ${_instance.apiBaseUrl}');
    }
  }
}