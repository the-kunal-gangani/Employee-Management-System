import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/exceptions.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/employee/data/repository/employee_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:employee_management_system/core/network/network_info.dart';
import 'package:employee_management_system/features/employee/data/datasources/employee_local_datasource.dart';
import 'package:employee_management_system/features/employee/data/datasources/employee_remote_datasource.dart';
import 'package:employee_management_system/features/employee/data/datasources/location_remote_datasource.dart';
import 'package:employee_management_system/features/employee/data/models/city_model.dart';
import 'package:employee_management_system/features/employee/data/models/country_model.dart';
import 'package:employee_management_system/features/employee/data/models/employee_model.dart';
import 'package:employee_management_system/features/employee/data/models/state_model.dart';
import 'package:employee_management_system/features/employee/domain/entities/employee_entity.dart';

class MockEmployeeRemoteDataSource extends Mock
    implements EmployeeRemoteDataSource {}

class MockLocationRemoteDataSource extends Mock
    implements LocationRemoteDataSource {}

class MockEmployeeLocalDataSource extends Mock
    implements EmployeeLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late EmployeeRepositoryImpl repository;
  late MockEmployeeRemoteDataSource remoteDataSource;
  late MockLocationRemoteDataSource locationRemoteDataSource;
  late MockEmployeeLocalDataSource localDataSource;
  late MockNetworkInfo networkInfo;

  const tEmployeeModel = EmployeeModel(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Gujarat',
    district: 'Ahmedabad',
  );

  setUpAll(() {
    registerFallbackValue(<EmployeeModel>[]);
    registerFallbackValue(tEmployeeModel);
  });

  setUp(() {
    remoteDataSource = MockEmployeeRemoteDataSource();
    locationRemoteDataSource = MockLocationRemoteDataSource();
    localDataSource = MockEmployeeLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = EmployeeRepositoryImpl(
      remoteDataSource: remoteDataSource,
      locationRemoteDataSource: locationRemoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  });

  group('getEmployees', () {
    test('when online: fetches remote and caches the result', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getEmployees(),
      ).thenAnswer((_) async => [tEmployeeModel]);
      when(
        () => localDataSource.cacheEmployees(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getEmployees();

      result.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (employees) => expect(employees, [tEmployeeModel]),
      );
      verify(() => localDataSource.cacheEmployees(any())).called(1);
    });

    test('when offline and not forceRemote: falls back to cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => localDataSource.getCachedEmployees(),
      ).thenAnswer((_) async => [tEmployeeModel]);

      final result = await repository.getEmployees();

      result.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (employees) => expect(employees, [tEmployeeModel]),
      );
      verifyNever(() => remoteDataSource.getEmployees());
    });

    test(
      'when offline and forceRemote: returns NetworkFailure without touching cache',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);

        final result = await repository.getEmployees(forceRemote: true);

        expect(
          result,
          const Left<Failure, List<EmployeeEntity>>(
            NetworkFailure('No internet connection.'),
          ),
        );
        verifyNever(() => localDataSource.getCachedEmployees());
      },
    );

    test(
      'when offline and cache is empty/corrupted: returns CacheFailure',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(
          () => localDataSource.getCachedEmployees(),
        ).thenThrow(const CacheException('No cached employee data found.'));

        final result = await repository.getEmployees();

        expect(
          result,
          const Left<Failure, List<EmployeeEntity>>(
            CacheFailure('No cached employee data found.'),
          ),
        );
      },
    );

    test('when online but remote call throws: returns ServerFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getEmployees(),
      ).thenThrow(const ServerException('Could not connect to the server.'));

      final result = await repository.getEmployees();

      expect(
        result,
        const Left<Failure, List<EmployeeEntity>>(
          ServerFailure('Could not connect to the server.'),
        ),
      );
    });
  });

  group('getEmployeeById', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getEmployeeById('1');

      expect(
        result,
        const Left<Failure, EmployeeEntity>(
          NetworkFailure('No internet connection.'),
        ),
      );
    });

    test('returns Right(EmployeeEntity) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getEmployeeById('1'),
      ).thenAnswer((_) async => tEmployeeModel);

      final result = await repository.getEmployeeById('1');

      expect(result, const Right<Failure, EmployeeEntity>(tEmployeeModel));
    });
  });

  group('createEmployee', () {
    test('creates remotely then silently refreshes the cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.createEmployee(any()),
      ).thenAnswer((_) async => tEmployeeModel);
      when(
        () => remoteDataSource.getEmployees(),
      ).thenAnswer((_) async => [tEmployeeModel]);
      when(
        () => localDataSource.cacheEmployees(any()),
      ).thenAnswer((_) async {});

      final result = await repository.createEmployee(tEmployeeModel);

      expect(result, const Right<Failure, EmployeeEntity>(tEmployeeModel));
      verify(() => localDataSource.cacheEmployees([tEmployeeModel])).called(1);
    });

    test('does not throw if the silent cache refresh fails', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.createEmployee(any()),
      ).thenAnswer((_) async => tEmployeeModel);
      when(
        () => remoteDataSource.getEmployees(),
      ).thenThrow(const ServerException('Could not connect to the server.'));

      final result = await repository.createEmployee(tEmployeeModel);

      expect(result, const Right<Failure, EmployeeEntity>(tEmployeeModel));
    });
  });

  group('updateEmployee', () {
    test('returns Right(EmployeeEntity) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.updateEmployee(any()),
      ).thenAnswer((_) async => tEmployeeModel);
      when(
        () => remoteDataSource.getEmployees(),
      ).thenAnswer((_) async => [tEmployeeModel]);
      when(
        () => localDataSource.cacheEmployees(any()),
      ).thenAnswer((_) async {});

      final result = await repository.updateEmployee(tEmployeeModel);

      expect(result, const Right<Failure, EmployeeEntity>(tEmployeeModel));
    });
  });

  group('deleteEmployee', () {
    test('returns Right(null) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteEmployee('1')).thenAnswer((_) async {});
      when(() => remoteDataSource.getEmployees()).thenAnswer((_) async => []);
      when(
        () => localDataSource.cacheEmployees(any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteEmployee('1');

      expect(result, const Right<Failure, void>(null));
    });

    test('maps ServerException to ServerFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remoteDataSource.deleteEmployee('1')).thenThrow(
        const ServerException('The requested employee was not found.'),
      );

      final result = await repository.deleteEmployee('1');

      expect(
        result,
        const Left<Failure, void>(
          ServerFailure('The requested employee was not found.'),
        ),
      );
    });
  });

  group('getCountries', () {
    test('returns Right(List<CountryEntity>) on success', () async {
      const tCountry = CountryModel(id: '1', name: 'India');
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.getCountries(),
      ).thenAnswer((_) async => [tCountry]);

      final result = await repository.getCountries();

      result.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (countries) => expect(countries, [tCountry]),
      );
    });
  });

  group('getStates', () {
    test('delegates to locationRemoteDataSource.getStates', () async {
      const tState = StateModel(name: 'Gujarat');
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => locationRemoteDataSource.getStates('India'),
      ).thenAnswer((_) async => [tState]);

      final result = await repository.getStates('India');

      result.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (states) => expect(states, [tState]),
      );
    });
  });

  group('getCities', () {
    test('delegates to locationRemoteDataSource.getCities', () async {
      const tCity = CityModel(name: 'Ahmedabad');
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => locationRemoteDataSource.getCities(
          country: 'India',
          state: 'Gujarat',
        ),
      ).thenAnswer((_) async => [tCity]);

      final result = await repository.getCities(
        country: 'India',
        state: 'Gujarat',
      );

      result.fold(
        (failure) => fail('Expected Right, got Left($failure)'),
        (cities) => expect(cities, [tCity]),
      );
    });
  });
}
