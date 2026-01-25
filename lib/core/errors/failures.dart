/// 공통 실패 타입 (Either 패턴 또는 예외 처리용)
///
/// Repository 레이어에서 발생하는 모든 에러는 이 타입으로 추상화됩니다.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// 서버/네트워크 관련 실패
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 로컬 캐시/스토리지 관련 실패
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 인증 관련 실패
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 유효성 검증 실패
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 권한 관련 실패
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 데이터를 찾을 수 없음
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 예상치 못한 에러
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.originalError,
  });
}
