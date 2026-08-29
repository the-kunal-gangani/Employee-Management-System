import 'package:employee_management_system/features/employee/domain/usecases/delete_employees.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/employee_entity.dart';
import '../../../domain/usecases/get_employees.dart';
import 'employee_list_event.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  final GetEmployees getEmployees;
  final DeleteEmployee deleteEmployee;

  EmployeeListBloc({required this.getEmployees, required this.deleteEmployee})
    : super(const EmployeeListState()) {
    on<EmployeeListStarted>(_onStarted);
    on<EmployeeListRefreshed>(_onRefreshed);
    on<EmployeeSearchByIdChanged>(_onSearchByIdChanged);
    on<EmployeeFilterChanged>(_onFilterChanged);
    on<EmployeeDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onStarted(
    EmployeeListStarted event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeListStatus.loading, clearError: true));
    final result = await getEmployees();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EmployeeListStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (employees) => emit(
        state.copyWith(
          status: EmployeeListStatus.loaded,
          employees: employees,
          filteredEmployees: _applyFilters(
            employees,
            state.searchId,
            state.filterField,
            state.filterQuery,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefreshed(
    EmployeeListRefreshed event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));
    final result = await getEmployees(forceRemote: true);
    result.fold(
      (failure) => emit(
        state.copyWith(isRefreshing: false, errorMessage: failure.message),
      ),
      (employees) => emit(
        state.copyWith(
          status: EmployeeListStatus.loaded,
          isRefreshing: false,
          employees: employees,
          filteredEmployees: _applyFilters(
            employees,
            state.searchId,
            state.filterField,
            state.filterQuery,
          ),
        ),
      ),
    );
  }

  void _onSearchByIdChanged(
    EmployeeSearchByIdChanged event,
    Emitter<EmployeeListState> emit,
  ) {
    emit(
      state.copyWith(
        searchId: event.query,
        filteredEmployees: _applyFilters(
          state.employees,
          event.query,
          state.filterField,
          state.filterQuery,
        ),
      ),
    );
  }

  void _onFilterChanged(
    EmployeeFilterChanged event,
    Emitter<EmployeeListState> emit,
  ) {
    emit(
      state.copyWith(
        filterField: event.field,
        filterQuery: event.query,
        filteredEmployees: _applyFilters(
          state.employees,
          state.searchId,
          event.field,
          event.query,
        ),
      ),
    );
  }

  Future<void> _onDeleteRequested(
    EmployeeDeleteRequested event,
    Emitter<EmployeeListState> emit,
  ) async {
    emit(
      state.copyWith(
        deleteStatus: EmployeeDeleteStatus.deleting,
        clearDeleteError: true,
      ),
    );
    final result = await deleteEmployee(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          deleteStatus: EmployeeDeleteStatus.failure,
          deleteErrorMessage: failure.message,
        ),
      ),
      (_) {
        final updated = state.employees.where((e) => e.id != event.id).toList();
        emit(
          state.copyWith(
            deleteStatus: EmployeeDeleteStatus.success,
            employees: updated,
            filteredEmployees: _applyFilters(
              updated,
              state.searchId,
              state.filterField,
              state.filterQuery,
            ),
          ),
        );
      },
    );
  }

  List<EmployeeEntity> _applyFilters(
    List<EmployeeEntity> source,
    String searchId,
    EmployeeFilterField field,
    String query,
  ) {
    var result = source;

    if (searchId.trim().isNotEmpty) {
      final needle = searchId.trim().toLowerCase();
      result = result
          .where((e) => e.id.toLowerCase().contains(needle))
          .toList();
    }

    if (field != EmployeeFilterField.none && query.trim().isNotEmpty) {
      final needle = query.trim().toLowerCase();
      result = result.where((e) {
        switch (field) {
          case EmployeeFilterField.name:
            return e.name.toLowerCase().contains(needle);
          case EmployeeFilterField.email:
            return e.email.toLowerCase().contains(needle);
          case EmployeeFilterField.mobile:
            return e.mobile.toLowerCase().contains(needle);
          case EmployeeFilterField.country:
            return e.country.toLowerCase().contains(needle);
          case EmployeeFilterField.none:
            return true;
        }
      }).toList();
    }

    return result;
  }
}
