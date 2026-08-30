import 'package:equatable/equatable.dart';

import '../../../domain/entities/employee_entity.dart';

enum EmployeeFilterField { none, name, email, mobile, country }

abstract class EmployeeListEvent extends Equatable {
  const EmployeeListEvent();

  @override
  List<Object?> get props => [];
}

class EmployeeListStarted extends EmployeeListEvent {
  const EmployeeListStarted();
}

class EmployeeListRefreshed extends EmployeeListEvent {
  const EmployeeListRefreshed();
}

class EmployeeSearchByIdChanged extends EmployeeListEvent {
  final String query;

  const EmployeeSearchByIdChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class EmployeeFilterChanged extends EmployeeListEvent {
  final EmployeeFilterField field;
  final String query;

  const EmployeeFilterChanged({required this.field, required this.query});

  @override
  List<Object?> get props => [field, query];
}

class EmployeeDeleteRequested extends EmployeeListEvent {
  final String id;

  const EmployeeDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Optimistically hides the employee and starts the undo window. If not
/// undone within the window, an [EmployeeDeleteRequested] is dispatched
/// internally to actually delete it.
class EmployeeDeletePending extends EmployeeListEvent {
  final EmployeeEntity employee;

  const EmployeeDeletePending(this.employee);

  @override
  List<Object?> get props => [employee];
}

/// Cancels a pending delete and restores the employee to the list.
class EmployeeDeleteUndone extends EmployeeListEvent {
  const EmployeeDeleteUndone();
}