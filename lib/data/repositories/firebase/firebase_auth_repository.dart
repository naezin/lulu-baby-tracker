import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/entities/user_entity.dart';

/// Firebase Auth 기반 인증 Repository 구현
class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ============================================================
  // Current User & Auth State
  // ============================================================

  @override
  UserEntity? get currentUser {
    final user = _auth.currentUser;
    return user != null ? _mapFirebaseUser(user) : null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? _mapFirebaseUser(user) : null;
    });
  }

  // ============================================================
  // Sign In Methods
  // ============================================================

  @override
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(
        user: _mapFirebaseUser(credential.user!),
        isNewUser: false,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      return AuthResult.success(
        user: _mapFirebaseUser(_auth.currentUser!),
        isNewUser: true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure(
          errorMessage: 'Google sign-in was cancelled',
          errorCode: 'sign_in_cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return AuthResult.success(
        user: _mapFirebaseUser(userCredential.user!),
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Google sign-in failed: $e',
        errorCode: 'google_sign_in_failed',
      );
    }
  }

  @override
  Future<AuthResult> signInWithApple() async {
    // TODO: Implement Apple Sign In
    return AuthResult.failure(
      errorMessage: 'Apple sign-in not implemented yet',
      errorCode: 'not_implemented',
    );
  }

  @override
  Future<AuthResult> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return AuthResult.success(
        user: _mapFirebaseUser(credential.user!),
        isNewUser: credential.additionalUserInfo?.isNewUser ?? true,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Anonymous sign-in failed: $e',
      );
    }
  }

  // ============================================================
  // Password Management
  // ============================================================

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // ============================================================
  // Profile Management
  // ============================================================

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ============================================================
  // Email Verification
  // ============================================================

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      throw Exception('Failed to check email verification: $e');
    }
  }

  // ============================================================
  // Sign Out & Delete
  // ============================================================

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'This operation requires recent authentication. Please sign in again and try again.');
      }
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // ============================================================
  // Private Helpers
  // ============================================================

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action';
      default:
        return 'Authentication failed: $code';
    }
  }
}
