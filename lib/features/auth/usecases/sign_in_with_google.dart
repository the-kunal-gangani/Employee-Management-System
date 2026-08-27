import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}
