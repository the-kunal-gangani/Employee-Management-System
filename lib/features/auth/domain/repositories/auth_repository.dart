import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Emits the current user whenever auth state changes, null when signed out.
  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;

  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle();

  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  Future<Either<Failure, void>> signOut();
}
