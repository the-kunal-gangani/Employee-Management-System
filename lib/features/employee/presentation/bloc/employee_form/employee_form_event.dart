import 'package:equatable/equatable.dart';

import '../../../domain/entities/employee_entity.dart';

abstract class EmployeeFormEvent extends Equatable {
  const EmployeeFormEvent();

  @override
  List<Object?> get props => [];
}

/// Starts the form. Pass an existing employee to pre-populate for editing,
/// or null for a fresh add-employee form.
class EmployeeFormStarted extends EmployeeFormEvent {
  final EmployeeEntity? existingEmployee;

  const EmployeeFormStarted({this.existingEmployee});

  @override
  List<Object?> get props => [existingEmployee];
}

class EmployeeFormCountrySelected extends EmployeeFormEvent {
  final String country;

  const EmployeeFormCountrySelected(this.country);

  @override
  List<Object?> get props => [country];
}

class EmployeeFormStateSelected extends EmployeeFormEvent {
  final String state;

  const EmployeeFormStateSelected(this.state);

  @override
  List<Object?> get props => [state];
}

class EmployeeFormDistrictSelected extends EmployeeFormEvent {
  final String district;

  const EmployeeFormDistrictSelected(this.district);

  @override
  List<Object?> get props => [district];
}

class EmployeeFormSubmitted extends EmployeeFormEvent {
  final String name;
  final String email;
  final String mobile;

  const EmployeeFormSubmitted({
    required this.name,
    required this.email,
    required this.mobile,
  });

  @override
  List<Object?> get props => [name, email, mobile];
}
