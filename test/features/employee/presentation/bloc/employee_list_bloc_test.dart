import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/employee/domain/usecases/delete_employees.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_system/features/employee/domain/entities/employee_entity.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_employees.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_list/employee_list_bloc.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_list/employee_list_event.dart';
import 'package:employee_management_system/features/employee/presentation/bloc/employee_list/employee_list_state.dart';

class MockGetEmployees extends Mock implements GetEmployees {}

class MockDeleteEmployee extends Mock implements DeleteEmployee {}

void main() {
  late MockGetEmployees getEmployees;
  late MockDeleteEmployee deleteEmployee;

  const tEmployee1 = EmployeeEntity(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
    mobile: '9876543210',
    country: 'India',
    state: 'Gujarat',
    district: 'Ahmedabad',
  );
  const tEmployee2 = EmployeeEntity(
    id: '2',
    name: 'John Smith',
    email: 'john@example.com',
    mobile: '5551234567',
    country: 'USA',
    state: 'California',
    district: 'Los Angeles',
  );
  const tEmployees = [tEmployee1, tEmployee2];

  setUp(() {
    getEmployees = MockGetEmployees();
    deleteEmployee = MockDeleteEmployee();
  });

  EmployeeListBloc buildBloc() => EmployeeListBloc(
    getEmployees: getEmployees,
    deleteEmployee: deleteEmployee,
  );

  group('EmployeeListStarted', () {
    blocTest<EmployeeListBloc, EmployeeListState>(
      'emits loading then loaded with all employees on success',
      setUp: () {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const EmployeeListStarted()),
      expect: () => [
        isA<EmployeeListState>().having(
          (s) => s.status,
          'status',
          EmployeeListStatus.loading,
        ),
        isA<EmployeeListState>()
            .having((s) => s.status, 'status', EmployeeListStatus.loaded)
            .having((s) => s.employees, 'employees', tEmployees)
            .having(
              (s) => s.filteredEmployees,
              'filteredEmployees',
              tEmployees,
            ),
      ],
    );

    blocTest<EmployeeListBloc, EmployeeListState>(
      'emits loading then error on failure',
      setUp: () {
        when(() => getEmployees(forceRemote: false)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection.')),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const EmployeeListStarted()),
      expect: () => [
        isA<EmployeeListState>().having(
          (s) => s.status,
          'status',
          EmployeeListStatus.loading,
        ),
        isA<EmployeeListState>()
            .having((s) => s.status, 'status', EmployeeListStatus.error)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'No internet connection.',
            ),
      ],
    );
  });

  group('EmployeeSearchByIdChanged', () {
    blocTest<EmployeeListBloc, EmployeeListState>(
      'filters the list down to employees whose id contains the query',
      setUp: () {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const EmployeeListStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const EmployeeSearchByIdChanged('2'));
      },
      skip: 2,
      expect: () => [
        isA<EmployeeListState>()
            .having((s) => s.searchId, 'searchId', '2')
            .having((s) => s.filteredEmployees, 'filteredEmployees', const [
              tEmployee2,
            ]),
      ],
    );
  });

  group('EmployeeFilterChanged', () {
    blocTest<EmployeeListBloc, EmployeeListState>(
      'filters the list by the selected field and query',
      setUp: () {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const EmployeeListStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const EmployeeFilterChanged(
            field: EmployeeFilterField.country,
            query: 'USA',
          ),
        );
      },
      skip: 2,
      expect: () => [
        isA<EmployeeListState>()
            .having(
              (s) => s.filterField,
              'filterField',
              EmployeeFilterField.country,
            )
            .having((s) => s.filteredEmployees, 'filteredEmployees', const [
              tEmployee2,
            ]),
      ],
    );
  });

  group('EmployeeListRefreshed', () {
    blocTest<EmployeeListBloc, EmployeeListState>(
      'forces a remote fetch and updates the list',
      setUp: () {
        when(
          () => getEmployees(forceRemote: true),
        ).thenAnswer((_) async => const Right(tEmployees));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const EmployeeListRefreshed()),
      expect: () => [
        isA<EmployeeListState>().having(
          (s) => s.isRefreshing,
          'isRefreshing',
          true,
        ),
        isA<EmployeeListState>()
            .having((s) => s.isRefreshing, 'isRefreshing', false)
            .having((s) => s.employees, 'employees', tEmployees),
      ],
    );
  });

  group('EmployeeDeleteRequested', () {
    blocTest<EmployeeListBloc, EmployeeListState>(
      'removes the employee from state on success',
      setUp: () {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
        when(
          () => deleteEmployee('1'),
        ).thenAnswer((_) async => const Right(null));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const EmployeeListStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const EmployeeDeleteRequested('1'));
      },
      skip: 2,
      expect: () => [
        isA<EmployeeListState>().having(
          (s) => s.deleteStatus,
          'deleteStatus',
          EmployeeDeleteStatus.deleting,
        ),
        isA<EmployeeListState>()
            .having(
              (s) => s.deleteStatus,
              'deleteStatus',
              EmployeeDeleteStatus.success,
            )
            .having((s) => s.employees, 'employees', const [tEmployee2])
            .having((s) => s.filteredEmployees, 'filteredEmployees', const [
              tEmployee2,
            ]),
      ],
    );

    blocTest<EmployeeListBloc, EmployeeListState>(
      'emits failure and keeps the employee in state when delete fails',
      setUp: () {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
        when(() => deleteEmployee('1')).thenAnswer(
          (_) async => const Left(
            ServerFailure('The requested employee was not found.'),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const EmployeeListStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const EmployeeDeleteRequested('1'));
      },
      skip: 2,
      expect: () => [
        isA<EmployeeListState>().having(
          (s) => s.deleteStatus,
          'deleteStatus',
          EmployeeDeleteStatus.deleting,
        ),
        isA<EmployeeListState>()
            .having(
              (s) => s.deleteStatus,
              'deleteStatus',
              EmployeeDeleteStatus.failure,
            )
            .having(
              (s) => s.deleteErrorMessage,
              'deleteErrorMessage',
              'The requested employee was not found.',
            )
            .having((s) => s.employees, 'employees', tEmployees),
      ],
    );
  });

  group('EmployeeDeletePending / EmployeeDeleteUndone', () {
    test(
      'EmployeeDeletePending optimistically hides the employee, then commits '
      'the delete once the undo window elapses without an undo',
      () async {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));
        when(
          () => deleteEmployee('1'),
        ).thenAnswer((_) async => const Right(null));

        final bloc = EmployeeListBloc(
          getEmployees: getEmployees,
          deleteEmployee: deleteEmployee,
          undoWindow: const Duration(milliseconds: 20),
        );

        bloc.add(const EmployeeListStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == EmployeeListStatus.loaded,
        );

        bloc.add(const EmployeeDeletePending(tEmployee1));
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(bloc.state.employees, const [tEmployee2]);
        expect(bloc.state.pendingDelete, tEmployee1);
        verifyNever(() => deleteEmployee('1'));

        // Wait past the undo window for the commit to fire.
        await Future<void>.delayed(const Duration(milliseconds: 40));

        expect(bloc.state.pendingDelete, isNull);
        verify(() => deleteEmployee('1')).called(1);

        await bloc.close();
      },
    );

    test(
      'EmployeeDeleteUndone restores the employee and the delete is never committed',
      () async {
        when(
          () => getEmployees(forceRemote: false),
        ).thenAnswer((_) async => const Right(tEmployees));

        final bloc = EmployeeListBloc(
          getEmployees: getEmployees,
          deleteEmployee: deleteEmployee,
          undoWindow: const Duration(milliseconds: 50),
        );

        bloc.add(const EmployeeListStarted());
        await bloc.stream.firstWhere(
          (s) => s.status == EmployeeListStatus.loaded,
        );

        bloc.add(const EmployeeDeletePending(tEmployee1));
        await Future<void>.delayed(const Duration(milliseconds: 5));
        expect(bloc.state.employees, const [tEmployee2]);

        bloc.add(const EmployeeDeleteUndone());
        await Future<void>.delayed(const Duration(milliseconds: 5));

        expect(bloc.state.pendingDelete, isNull);
        expect(bloc.state.employees.length, 2);
        expect(
          bloc.state.employees,
          containsAll(const [tEmployee1, tEmployee2]),
        );

        // Confirm the delete never fires even after the original window would have passed.
        await Future<void>.delayed(const Duration(milliseconds: 80));
        verifyNever(() => deleteEmployee(any()));

        await bloc.close();
      },
    );
  });
}
