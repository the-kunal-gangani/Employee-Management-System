import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../repositories/employee_repository.dart';

class DeleteEmployee {
  final EmployeeRepository repository;

  DeleteEmployee(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteEmployee(id);
  }
}
