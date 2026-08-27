import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.registerWithEmail(email: email, password: password);
  }
}
