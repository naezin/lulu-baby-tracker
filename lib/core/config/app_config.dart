import 'package:flutter/foundation.dart';

/// 앱 환경 설정
class AppConfig {
  static const String _env = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// 현재 환경
  static AppEnvironment get environment {
    switch (_env) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }

  /// API Base URL
  static String get apiBaseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return 'https://api.lulu-app.com';
      case AppEnvironment.staging:
        return 'https://staging-api.lulu-app.com';
      case AppEnvironment.development:
        return 'http://localhost:3000';
    }
  }

  /// 디버그 모드 여부
  static bool get isDebugMode =>
      environment == AppEnvironment.development || kDebugMode;

  /// 로깅 활성화 여부
  static bool get enableLogging =>
      environment != AppEnvironment.production;
}

enum AppEnvironment {
  development,
  staging,
  production,
}
