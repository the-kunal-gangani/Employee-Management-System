import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/employee/domain/usecases/create_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/delete_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_employees_by_id.dart';
import 'package:employee_management_system/features/employee/domain/usecases/update_employees.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:employee_management_system/features/employee/domain/entities/city_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/country_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/employee_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/state_entity.dart';
import 'package:employee_management_system/features/employee/domain/repositories/employee_repository.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_cities.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_countries.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_states.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late MockEmployeeRepository repository;

  const tEmployee = EmployeeEntity(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Gujarat',
    district: 'Ahmedabad',
  );

  setUp(() {
    repository = MockEmployeeRepository();
  });

  group('GetEmployees', () {
    test(
      'delegates to repository.getEmployees with forceRemote flag',
      () async {
        when(
          () => repository.getEmployees(forceRemote: true),
        ).thenAnswer((_) async => const Right([tEmployee]));

        final usecase = GetEmployees(repository);
        final result = await usecase(forceRemote: true);

        expect(result, const Right<Failure, List<EmployeeEntity>>([tEmployee]));
        verify(() => repository.getEmployees(forceRemote: true)).called(1);
      },
    );

    test('propagates failure from repository', () async {
      when(() => repository.getEmployees(forceRemote: false)).thenAnswer(
        (_) async => const Left(NetworkFailure('No internet connection.')),
      );

      final usecase = GetEmployees(repository);
      final result = await usecase();

      expect(
        result,
        const Left<Failure, List<EmployeeEntity>>(
          NetworkFailure('No internet connection.'),
        ),
      );
    });
  });

  group('GetEmployeeById', () {
    test('delegates to repository.getEmployeeById', () async {
      when(
        () => repository.getEmployeeById('1'),
      ).thenAnswer((_) async => const Right(tEmployee));

      final usecase = GetEmployeeById(repository);
      final result = await usecase('1');

      expect(result, const Right<Failure, EmployeeEntity>(tEmployee));
      verify(() => repository.getEmployeeById('1')).called(1);
    });
  });

  group('CreateEmployee', () {
    test('delegates to repository.createEmployee', () async {
      when(
        () => repository.createEmployee(tEmployee),
      ).thenAnswer((_) async => const Right(tEmployee));

      final usecase = CreateEmployee(repository);
      final result = await usecase(tEmployee);

      expect(result, const Right<Failure, EmployeeEntity>(tEmployee));
      verify(() => repository.createEmployee(tEmployee)).called(1);
    });
  });

  group('UpdateEmployee', () {
    test('delegates to repository.updateEmployee', () async {
      when(
        () => repository.updateEmployee(tEmployee),
      ).thenAnswer((_) async => const Right(tEmployee));

      final usecase = UpdateEmployee(repository);
      final result = await usecase(tEmployee);

      expect(result, const Right<Failure, EmployeeEntity>(tEmployee));
      verify(() => repository.updateEmployee(tEmployee)).called(1);
    });
  });

  group('DeleteEmployee', () {
    test('delegates to repository.deleteEmployee', () async {
      when(
        () => repository.deleteEmployee('1'),
      ).thenAnswer((_) async => const Right(null));

      final usecase = DeleteEmployee(repository);
      final result = await usecase('1');

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.deleteEmployee('1')).called(1);
    });

    test('propagates failure from repository', () async {
      when(() => repository.deleteEmployee('1')).thenAnswer(
        (_) async =>
            const Left(ServerFailure('The requested employee was not found.')),
      );

      final usecase = DeleteEmployee(repository);
      final result = await usecase('1');

      expect(
        result,
        const Left<Failure, void>(
          ServerFailure('The requested employee was not found.'),
        ),
      );
    });
  });

  group('GetCountries', () {
    test('delegates to repository.getCountries', () async {
      const tCountries = [CountryEntity(id: '1', name: 'India')];
      when(
        () => repository.getCountries(),
      ).thenAnswer((_) async => const Right(tCountries));

      final usecase = GetCountries(repository);
      final result = await usecase();

      expect(result, const Right<Failure, List<CountryEntity>>(tCountries));
    });
  });

  group('GetStates', () {
    test('delegates to repository.getStates with the given country', () async {
      const tStates = [StateEntity(name: 'Gujarat')];
      when(
        () => repository.getStates('India'),
      ).thenAnswer((_) async => const Right(tStates));

      final usecase = GetStates(repository);
      final result = await usecase('India');

      expect(result, const Right<Failure, List<StateEntity>>(tStates));
      verify(() => repository.getStates('India')).called(1);
    });
  });

  group('GetCities', () {
    test('delegates to repository.getCities with country and state', () async {
      const tCities = [CityEntity(name: 'Ahmedabad')];
      when(
        () => repository.getCities(country: 'India', state: 'Gujarat'),
      ).thenAnswer((_) async => const Right(tCities));

      final usecase = GetCities(repository);
      final result = await usecase(country: 'India', state: 'Gujarat');

      expect(result, const Right<Failure, List<CityEntity>>(tCities));
      verify(
        () => repository.getCities(country: 'India', state: 'Gujarat'),
      ).called(1);
    });
  });
}
