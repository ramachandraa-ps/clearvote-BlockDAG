enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  static late Environment _environment;
  static late String _baseUrl;

  static void initConfig(Environment env) {
    _environment = env;
    
    switch (env) {
      case Environment.dev:
        _baseUrl = 'https://dev-api.clearvote.com';
        break;
      case Environment.staging:
        _baseUrl = 'https://staging-api.clearvote.com';
        break;
      case Environment.prod:
        _baseUrl = 'https://api.clearvote.com';
        break;
    }
  }

  static Environment get environment => _environment;
  static String get baseUrl => _baseUrl;
  static bool get isDev => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProd => _environment == Environment.prod;
}