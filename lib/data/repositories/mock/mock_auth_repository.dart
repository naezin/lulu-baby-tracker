import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/entities/user.dart';

/// Mock Auth Repository (In-Memory)
class MockAuthRepository implements IAuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<User?> get authStateChanges {
    return Stream.value(_currentUser);
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Mock: 자동 로그인
    _currentUser = User(
      uid: 'mock-user-id',
      email: email,
      displayName: 'Mock User',
    );
    return _currentUser!;
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = User(
      uid: 'mock-user-id',
      email: email,
      displayName: displayName ?? 'Mock User',
    );
    return _currentUser!;
  }

  @override
  Future<User> signInWithGoogle() async {
    _currentUser = User(
      uid: 'mock-google-user',
      email: 'mock@google.com',
      displayName: 'Mock Google User',
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Mock: 아무것도 하지 않음
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser != null) {
      _currentUser = User(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: displayName,
        photoURL: _currentUser!.photoURL,
      );
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    if (_currentUser != null) {
      _currentUser = User(
        uid: _currentUser!.uid,
        email: newEmail,
        displayName: _currentUser!.displayName,
        photoURL: _currentUser!.photoURL,
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    // Mock: 아무것도 하지 않음
  }

  @override
  Future<void> deleteAccount() async {
    _currentUser = null;
  }
}
