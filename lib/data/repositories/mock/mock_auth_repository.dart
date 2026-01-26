import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/entities/user_entity.dart';

/// Mock Auth Repository (In-Memory)
class MockAuthRepository implements IAuthRepository {
  UserEntity? _currentUser;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges {
    return Stream.value(_currentUser);
  }

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Mock: 자동 로그인
    _currentUser = UserEntity(
      id: 'mock-user-id',
      email: email,
      displayName: 'Mock User',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return AuthResult.success(user: _currentUser);
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = UserEntity(
      id: 'mock-user-id',
      email: email,
      displayName: displayName ?? 'Mock User',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return AuthResult.success(user: _currentUser, isNewUser: true);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    _currentUser = UserEntity(
      id: 'mock-google-user',
      email: 'mock@google.com',
      displayName: 'Mock Google User',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return AuthResult.success(user: _currentUser);
  }

  @override
  Future<AuthResult> signInWithApple() async {
    _currentUser = UserEntity(
      id: 'mock-apple-user',
      email: 'mock@apple.com',
      displayName: 'Mock Apple User',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return AuthResult.success(user: _currentUser);
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    _currentUser = UserEntity(
      id: 'mock-anonymous-user',
      email: 'anonymous@mock.com',
      displayName: 'Anonymous',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return AuthResult.success(user: _currentUser);
  }

  @override
  Future<void> resetPassword({required String email}) async {
    // Mock: 아무것도 하지 않음
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    // Mock: 아무것도 하지 않음
  }

  @override
  Future<bool> isEmailVerified() async {
    return true; // Mock: 항상 인증됨
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Mock: 아무것도 하지 않음
  }
}
