import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';

import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployees {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> call({
    bool forceRemote = false,
  }) {
    return repository.getEmployees(forceRemote: forceRemote);
  }
}
