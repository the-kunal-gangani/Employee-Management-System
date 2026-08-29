import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../entities/city_entity.dart';
import '../entities/country_entity.dart';
import '../entities/employee_entity.dart';
import '../entities/state_entity.dart';

abstract class EmployeeRepository {
  /// Fetches employees from the remote API. On success, also refreshes
  /// the local cache. Falls back to cache if [forceRemote] is false and
  /// there is no connectivity.
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees({
    bool forceRemote = false,
  });

  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id);

  Future<Either<Failure, EmployeeEntity>> createEmployee(
    EmployeeEntity employee,
  );

  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    EmployeeEntity employee,
  );

  Future<Either<Failure, void>> deleteEmployee(String id);

  Future<Either<Failure, List<CountryEntity>>> getCountries();

  Future<Either<Failure, List<StateEntity>>> getStates(String country);

  Future<Either<Failure, List<CityEntity>>> getCities({
    required String country,
    required String state,
  });
}
