import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/country_entity.dart';
import '../repositories/employee_repository.dart';

class GetCountries {
  final EmployeeRepository repository;

  GetCountries(this.repository);

  Future<Either<Failure, List<CountryEntity>>> call() {
    return repository.getCountries();
  }
}
