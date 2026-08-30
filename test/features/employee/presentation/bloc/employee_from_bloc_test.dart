import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/employee/domain/usecases/create_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/update_employees.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_system/features/employee/domain/entities/city_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/country_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/employee_entity.dart';
import 'package:employee_management_system/features/employee/domain/entities/state_entity.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_cities.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_countries.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_states.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_form/employee_form_bloc.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_form/employee_form_event.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_form/employee_form_state.dart';

class MockGetCountries extends Mock implements GetCountries {}

class MockGetStates extends Mock implements GetStates {}

class MockGetCities extends Mock implements GetCities {}

class MockCreateEmployee extends Mock implements CreateEmployee {}

class MockUpdateEmployee extends Mock implements UpdateEmployee {}

void main() {
  late MockGetCountries getCountries;
  late MockGetStates getStates;
  late MockGetCities getCities;
  late MockCreateEmployee createEmployee;
  late MockUpdateEmployee updateEmployee;

  const tCountries = [CountryEntity(id: '1', name: 'India')];
  const tStates = [StateEntity(name: 'Gujarat')];
  const tCities = [CityEntity(name: 'Ahmedabad')];

  const tExistingEmployee = EmployeeEntity(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Gujarat',
    district: 'Ahmedabad',
  );

  setUp(() {
    getCountries = MockGetCountries();
    getStates = MockGetStates();
    getCities = MockGetCities();
    createEmployee = MockCreateEmployee();
    updateEmployee = MockUpdateEmployee();
  });

  EmployeeFormBloc buildBloc() => EmployeeFormBloc(
    getCountries: getCountries,
    getStates: getStates,
    getCities: getCities,
    createEmployee: createEmployee,
    updateEmployee: updateEmployee,
  );

  group('EmployeeFormStarted', () {
    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'add mode: loads countries and leaves selections empty',
      setUp: () {
        when(
          () => getCountries(),
        ).thenAnswer((_) async => const Right(tCountries));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const EmployeeFormStarted()),
      expect: () => [
        isA<EmployeeFormState>().having(
          (s) => s.countriesStatus,
          'countriesStatus',
          LocationLoadStatus.loading,
        ),
        isA<EmployeeFormState>()
            .having((s) => s.mode, 'mode', EmployeeFormMode.add)
            .having((s) => s.countries, 'countries', tCountries)
            .having(
              (s) => s.countriesStatus,
              'countriesStatus',
              LocationLoadStatus.loaded,
            )
            .having((s) => s.selectedCountry, 'selectedCountry', isNull),
      ],
    );

    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'edit mode: pre-populates selections and cascades states/cities for the existing employee',
      setUp: () {
        when(
          () => getCountries(),
        ).thenAnswer((_) async => const Right(tCountries));
        when(
          () => getStates('India'),
        ).thenAnswer((_) async => const Right(tStates));
        when(
          () => getCities(country: 'India', state: 'Gujarat'),
        ).thenAnswer((_) async => const Right(tCities));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFormStarted(existingEmployee: tExistingEmployee),
      ),
      expect: () => [
        isA<EmployeeFormState>().having(
          (s) => s.countriesStatus,
          'countriesStatus',
          LocationLoadStatus.loading,
        ),
        isA<EmployeeFormState>()
            .having((s) => s.mode, 'mode', EmployeeFormMode.edit)
            .having((s) => s.countries, 'countries', tCountries)
            .having(
              (s) => s.countriesStatus,
              'countriesStatus',
              LocationLoadStatus.loaded,
            ),
        isA<EmployeeFormState>().having(
          (s) => s.statesStatus,
          'statesStatus',
          LocationLoadStatus.loading,
        ),
        isA<EmployeeFormState>()
            .having((s) => s.states, 'states', tStates)
            .having(
              (s) => s.statesStatus,
              'statesStatus',
              LocationLoadStatus.loaded,
            ),
        isA<EmployeeFormState>().having(
          (s) => s.citiesStatus,
          'citiesStatus',
          LocationLoadStatus.loading,
        ),
        isA<EmployeeFormState>()
            .having((s) => s.cities, 'cities', tCities)
            .having(
              (s) => s.citiesStatus,
              'citiesStatus',
              LocationLoadStatus.loaded,
            ),
      ],
    );
  });

  group('EmployeeFormCountrySelected', () {
    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'clears state/district and loads states for the new country',
      setUp: () {
        when(
          () => getStates('India'),
        ).thenAnswer((_) async => const Right(tStates));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const EmployeeFormCountrySelected('India')),
      expect: () => [
        isA<EmployeeFormState>()
            .having((s) => s.selectedCountry, 'selectedCountry', 'India')
            .having((s) => s.selectedState, 'selectedState', isNull)
            .having((s) => s.selectedDistrict, 'selectedDistrict', isNull),
        isA<EmployeeFormState>().having(
          (s) => s.statesStatus,
          'statesStatus',
          LocationLoadStatus.loading,
        ),
        isA<EmployeeFormState>()
            .having((s) => s.states, 'states', tStates)
            .having(
              (s) => s.statesStatus,
              'statesStatus',
              LocationLoadStatus.loaded,
            ),
      ],
    );
  });

  group('EmployeeFormSubmitted', () {
    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'fails validation when country/state/district are not all selected',
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFormSubmitted(
          name: 'Jane Doe',
          email: 'jane@example.com',
          mobile: '9876543210',
        ),
      ),
      expect: () => [
        isA<EmployeeFormState>()
            .having(
              (s) => s.submitStatus,
              'submitStatus',
              EmployeeFormSubmitStatus.failure,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Please select country, state, and district.',
            ),
      ],
      verify: (_) {
        verifyNever(() => createEmployee(any()));
      },
    );

    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'add mode: calls createEmployee when location is fully selected',
      seed: () => const EmployeeFormState(
        mode: EmployeeFormMode.add,
        selectedCountry: 'India',
        selectedState: 'Gujarat',
        selectedDistrict: 'Ahmedabad',
      ),
      setUp: () {
        when(
          () => createEmployee(any()),
        ).thenAnswer((_) async => const Right(tExistingEmployee));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFormSubmitted(
          name: 'Jane Doe',
          email: 'jane@example.com',
          mobile: '9876543210',
        ),
      ),
      expect: () => [
        isA<EmployeeFormState>().having(
          (s) => s.submitStatus,
          'submitStatus',
          EmployeeFormSubmitStatus.submitting,
        ),
        isA<EmployeeFormState>().having(
          (s) => s.submitStatus,
          'submitStatus',
          EmployeeFormSubmitStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => createEmployee(any())).called(1);
        verifyNever(() => updateEmployee(any()));
      },
    );

    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'edit mode: calls updateEmployee instead of createEmployee',
      seed: () => const EmployeeFormState(
        mode: EmployeeFormMode.edit,
        editingEmployee: tExistingEmployee,
        selectedCountry: 'India',
        selectedState: 'Gujarat',
        selectedDistrict: 'Ahmedabad',
      ),
      setUp: () {
        when(
          () => updateEmployee(any()),
        ).thenAnswer((_) async => const Right(tExistingEmployee));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFormSubmitted(
          name: 'Jane Doe',
          email: 'jane@example.com',
          mobile: '9876543210',
        ),
      ),
      expect: () => [
        isA<EmployeeFormState>().having(
          (s) => s.submitStatus,
          'submitStatus',
          EmployeeFormSubmitStatus.submitting,
        ),
        isA<EmployeeFormState>().having(
          (s) => s.submitStatus,
          'submitStatus',
          EmployeeFormSubmitStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => updateEmployee(any())).called(1);
        verifyNever(() => createEmployee(any()));
      },
    );

    blocTest<EmployeeFormBloc, EmployeeFormState>(
      'emits failure when the repository call fails',
      seed: () => const EmployeeFormState(
        mode: EmployeeFormMode.add,
        selectedCountry: 'India',
        selectedState: 'Gujarat',
        selectedDistrict: 'Ahmedabad',
      ),
      setUp: () {
        when(() => createEmployee(any())).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection.')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const EmployeeFormSubmitted(
          name: 'Jane Doe',
          email: 'jane@example.com',
          mobile: '9876543210',
        ),
      ),
      expect: () => [
        isA<EmployeeFormState>().having(
          (s) => s.submitStatus,
          'submitStatus',
          EmployeeFormSubmitStatus.submitting,
        ),
        isA<EmployeeFormState>()
            .having(
              (s) => s.submitStatus,
              'submitStatus',
              EmployeeFormSubmitStatus.failure,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'No internet connection.',
            ),
      ],
    );
  });
}
