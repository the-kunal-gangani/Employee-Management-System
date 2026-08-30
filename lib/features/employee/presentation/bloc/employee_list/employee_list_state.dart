import 'package:equatable/equatable.dart';

import '../../../domain/entities/employee_entity.dart';
import 'employee_list_event.dart';

enum EmployeeListStatus { initial, loading, loaded, error }

enum EmployeeDeleteStatus { idle, deleting, success, failure }

class EmployeeListState extends Equatable {
  final EmployeeListStatus status;
  final List<EmployeeEntity> employees;
  final List<EmployeeEntity> filteredEmployees;
  final String searchId;
  final EmployeeFilterField filterField;
  final String filterQuery;
  final String? errorMessage;
  final EmployeeDeleteStatus deleteStatus;
  final String? deleteErrorMessage;
  final bool isRefreshing;
  final EmployeeEntity? pendingDelete;

  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.filteredEmployees = const [],
    this.searchId = '',
    this.filterField = EmployeeFilterField.none,
    this.filterQuery = '',
    this.errorMessage,
    this.deleteStatus = EmployeeDeleteStatus.idle,
    this.deleteErrorMessage,
    this.isRefreshing = false,
    this.pendingDelete,
  });

  bool get isEmpty =>
      status == EmployeeListStatus.loaded && filteredEmployees.isEmpty;

  EmployeeListState copyWith({
    EmployeeListStatus? status,
    List<EmployeeEntity>? employees,
    List<EmployeeEntity>? filteredEmployees,
    String? searchId,
    EmployeeFilterField? filterField,
    String? filterQuery,
    String? errorMessage,
    bool clearError = false,
    EmployeeDeleteStatus? deleteStatus,
    String? deleteErrorMessage,
    bool clearDeleteError = false,
    bool? isRefreshing,
    EmployeeEntity? pendingDelete,
    bool clearPendingDelete = false,
  }) {
    return EmployeeListState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      searchId: searchId ?? this.searchId,
      filterField: filterField ?? this.filterField,
      filterQuery: filterQuery ?? this.filterQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorMessage: clearDeleteError
          ? null
          : (deleteErrorMessage ?? this.deleteErrorMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      pendingDelete:
          clearPendingDelete ? null : (pendingDelete ?? this.pendingDelete),
    );
  }

  @override
  List<Object?> get props => [
        status,
        employees,
        filteredEmployees,
        searchId,
        filterField,
        filterQuery,
        errorMessage,
        deleteStatus,
        deleteErrorMessage,
        isRefreshing,
        pendingDelete,
      ];
}