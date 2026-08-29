import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeById {
  final EmployeeRepository repository;

  GetEmployeeById(this.repository);

  Future<Either<Failure, EmployeeEntity>> call(String id) {
    return repository.getEmployeeById(id);
  }
}
