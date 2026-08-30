import 'package:employee_management_system/core/errors/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : UserModel.fromFirebaseUser(user),
    );
  }

  @override
  UserModel? get currentUser {
    final user = firebaseAuth.currentUser;
    return user == null ? null : UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }
      return UserModel.fromFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }
      return UserModel.fromFirebaseUser(user);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await googleSignIn.authenticate();

      final GoogleSignInAuthentication idTokenAuth = account.authentication;

      final GoogleSignInClientAuthorization authorization =
          await account.authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]) ??
          await account.authorizationClient.authorizeScopes([
            'email',
            'profile',
          ]);

      final credential = fb.GoogleAuthProvider.credential(
        idToken: idTokenAuth.idToken,
        accessToken: authorization?.accessToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Google sign in failed. Please try again.');
      }
      return UserModel.fromFirebaseUser(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign in was cancelled.');
      }
      throw AuthException('Google sign in failed: ${e.description ?? e.code}');
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
