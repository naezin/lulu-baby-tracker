import '../entities/user_entity.dart';

/// 인증 결과 타입
class AuthResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;
  final String? errorCode;
  final bool isNewUser;

  AuthResult.success({
    required this.user,
    this.isNewUser = false,
  })  : isSuccess = true,
        errorMessage = null,
        errorCode = null;

  AuthResult.failure({
    required this.errorMessage,
    this.errorCode,
  })  : isSuccess = false,
        user = null,
        isNewUser = false;

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: ${user?.email}, isNewUser: $isNewUser)';
    } else {
      return 'AuthResult.failure(error: $errorMessage, code: $errorCode)';
    }
  }
}

/// 인증 Repository 인터페이스
abstract class IAuthRepository {
  /// 현재 사용자
  UserEntity? get currentUser;

  /// 로그인 상태 스트림
  Stream<UserEntity?> get authStateChanges;

  /// 이메일 로그인
  ///
  /// [email]: 이메일 주소
  /// [password]: 비밀번호
  /// Returns: 인증 결과
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  });

  /// 이메일 회원가입
  ///
  /// [email]: 이메일 주소
  /// [password]: 비밀번호
  /// [displayName]: 표시 이름 (선택)
  /// Returns: 인증 결과
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Google 로그인
  ///
  /// Returns: 인증 결과
  Future<AuthResult> signInWithGoogle();

  /// Apple 로그인
  ///
  /// Returns: 인증 결과
  Future<AuthResult> signInWithApple();

  /// 익명 로그인
  ///
  /// Returns: 인증 결과
  Future<AuthResult> signInAnonymously();

  /// 비밀번호 재설정 이메일 전송
  ///
  /// [email]: 이메일 주소
  Future<void> resetPassword({required String email});

  /// 로그아웃
  Future<void> signOut();

  /// 계정 삭제
  ///
  /// 주의: 이 작업은 되돌릴 수 없습니다.
  Future<void> deleteAccount();

  /// 이메일 인증 메일 재전송
  Future<void> sendEmailVerification();

  /// 이메일 인증 여부 확인
  Future<bool> isEmailVerified();

  /// 사용자 프로필 업데이트
  ///
  /// [displayName]: 표시 이름
  /// [photoUrl]: 프로필 사진 URL
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// 비밀번호 변경
  ///
  /// [currentPassword]: 현재 비밀번호
  /// [newPassword]: 새 비밀번호
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
