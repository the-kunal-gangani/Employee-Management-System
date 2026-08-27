import 'package:employee_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChanges {
  final AuthRepository repository;

  GetAuthStateChanges(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
