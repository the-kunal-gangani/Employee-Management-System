import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';

import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class CreateEmployee {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  Future<Either<Failure, EmployeeEntity>> call(EmployeeEntity employee) {
    return repository.createEmployee(employee);
  }
}
