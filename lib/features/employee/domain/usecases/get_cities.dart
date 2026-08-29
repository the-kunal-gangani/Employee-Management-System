import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/city_entity.dart';
import '../repositories/employee_repository.dart';

class GetCities {
  final EmployeeRepository repository;

  GetCities(this.repository);

  Future<Either<Failure, List<CityEntity>>> call({
    required String country,
    required String state,
  }) {
    return repository.getCities(country: country, state: state);
  }
}
