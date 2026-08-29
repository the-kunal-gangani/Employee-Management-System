import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/state_entity.dart';
import '../repositories/employee_repository.dart';

class GetStates {
  final EmployeeRepository repository;

  GetStates(this.repository);

  Future<Either<Failure, List<StateEntity>>> call(String country) {
    return repository.getStates(country);
  }
}
