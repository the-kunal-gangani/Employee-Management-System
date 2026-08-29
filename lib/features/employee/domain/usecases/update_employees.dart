import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployee {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  Future<Either<Failure, EmployeeEntity>> call(EmployeeEntity employee) {
    return repository.updateEmployee(employee);
  }
}
