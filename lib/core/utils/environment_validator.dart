import 'package:flutter/foundation.dart';

/// 환경 변수 검증 유틸리티
class EnvironmentValidator {
  /// 필수 환경 변수 목록
  static const _requiredVars = {
    'OPENAI_API_KEY': 'AI 채팅 기능에 필요합니다',
  };

  /// Supabase 환경 변수 (Optional - 없으면 로컬 모드)
  static const _supabaseVars = {
    'SUPABASE_URL': 'Supabase 프로젝트 URL',
    'SUPABASE_ANON_KEY': 'Supabase 익명 키 (공개 키)',
  };

  /// 환경 변수 검증 실행
  static ValidationResult validate() {
    final missing = <String, String>{};
    final warnings = <String>[];

    // 필수 변수 체크 - 각 변수를 직접 검사 (const는 컴파일 타임 상수만 허용)
    const openAIKey = String.fromEnvironment('OPENAI_API_KEY');
    if (openAIKey.isEmpty) {
      missing['OPENAI_API_KEY'] = _requiredVars['OPENAI_API_KEY']!;
    }

    // 환경 모드 체크
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    if (env == 'development' && kReleaseMode) {
      warnings.add('Release 빌드에서 development 환경이 감지되었습니다');
    }

    return ValidationResult(
      isValid: missing.isEmpty,
      missingVariables: missing,
      warnings: warnings,
    );
  }

  /// OpenAI API Key 안전하게 가져오기
  static String? get openAIApiKey {
    const key = String.fromEnvironment('OPENAI_API_KEY');
    return key.isNotEmpty ? key : null;
  }

  /// Supabase 환경 변수들
  static String? get supabaseUrl {
    const url = String.fromEnvironment('SUPABASE_URL');
    return url.isNotEmpty ? url : null;
  }

  static String? get supabaseAnonKey {
    const key = String.fromEnvironment('SUPABASE_ANON_KEY');
    return key.isNotEmpty ? key : null;
  }

  /// Supabase가 설정되어 있는지 확인
  static bool get hasSupabaseConfig {
    return supabaseUrl != null && supabaseAnonKey != null;
  }

  /// 현재 환경 모드
  static String get environment {
    return const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  }

  /// Production 환경 여부
  static bool get isProduction => environment == 'production';
}

/// 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final Map<String, String> missingVariables;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.missingVariables,
    required this.warnings,
  });

  String get errorMessage {
    if (isValid) return '';

    final buffer = StringBuffer('⚠️ 환경 설정이 필요합니다:\n\n');

    for (final entry in missingVariables.entries) {
      buffer.writeln('• ${entry.key}: ${entry.value}');
    }

    buffer.writeln('\n실행 방법:');
    buffer.writeln('flutter run --dart-define=OPENAI_API_KEY=sk-xxx');

    return buffer.toString();
  }
}
