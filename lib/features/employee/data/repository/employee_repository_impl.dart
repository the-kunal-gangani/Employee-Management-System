import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/exceptions.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/state_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_local_datasource.dart';
import '../datasources/employee_remote_datasource.dart';
import '../datasources/location_remote_datasource.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  final LocationRemoteDataSource locationRemoteDataSource;
  final EmployeeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EmployeeRepositoryImpl({
    required this.remoteDataSource,
    required this.locationRemoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees({
    bool forceRemote = false,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final employees = await remoteDataSource.getEmployees();
        await localDataSource.cacheEmployees(employees);
        return Right(employees);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }

    if (forceRemote) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    try {
      final cached = await localDataSource.getCachedEmployees();
      return Right(cached);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployeeById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final employee = await remoteDataSource.getEmployeeById(id);
      return Right(employee);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> createEmployee(
    EmployeeEntity employee,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final created = await remoteDataSource.createEmployee(
        EmployeeModel.fromEntity(employee),
      );
      await _refreshCacheSilently();
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> updateEmployee(
    EmployeeEntity employee,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final updated = await remoteDataSource.updateEmployee(
        EmployeeModel.fromEntity(employee),
      );
      await _refreshCacheSilently();
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      await remoteDataSource.deleteEmployee(id);
      await _refreshCacheSilently();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final countries = await remoteDataSource.getCountries();
      return Right(countries);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StateEntity>>> getStates(String country) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final states = await locationRemoteDataSource.getStates(country);
      return Right(states);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities({
    required String country,
    required String state,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection.'));
    }
    try {
      final cities = await locationRemoteDataSource.getCities(
        country: country,
        state: state,
      );
      return Right(cities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  /// After a create/update/delete, re-fetches the full list so the cache
  /// stays consistent. Failures here are swallowed since the mutating
  /// operation itself already succeeded — a stale cache just means the
  /// next getEmployees() call will hit remote again anyway if online.
  Future<void> _refreshCacheSilently() async {
    try {
      final employees = await remoteDataSource.getEmployees();
      await localDataSource.cacheEmployees(employees);
    } catch (_) {
      // Intentionally ignored — see doc comment above.
    }
  }
}
