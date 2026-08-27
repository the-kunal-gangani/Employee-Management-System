import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
