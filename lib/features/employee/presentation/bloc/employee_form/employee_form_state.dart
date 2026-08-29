import 'package:equatable/equatable.dart';

import '../../../domain/entities/city_entity.dart';
import '../../../domain/entities/country_entity.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../../domain/entities/state_entity.dart';

enum EmployeeFormMode { add, edit }

enum LocationLoadStatus { idle, loading, loaded, error }

enum EmployeeFormSubmitStatus { idle, submitting, success, failure }

class EmployeeFormState extends Equatable {
  final EmployeeFormMode mode;
  final EmployeeEntity? editingEmployee;

  final List<CountryEntity> countries;
  final LocationLoadStatus countriesStatus;

  final List<StateEntity> states;
  final LocationLoadStatus statesStatus;

  final List<CityEntity> cities;
  final LocationLoadStatus citiesStatus;

  final String? selectedCountry;
  final String? selectedState;
  final String? selectedDistrict;

  final EmployeeFormSubmitStatus submitStatus;
  final String? errorMessage;

  const EmployeeFormState({
    this.mode = EmployeeFormMode.add,
    this.editingEmployee,
    this.countries = const [],
    this.countriesStatus = LocationLoadStatus.idle,
    this.states = const [],
    this.statesStatus = LocationLoadStatus.idle,
    this.cities = const [],
    this.citiesStatus = LocationLoadStatus.idle,
    this.selectedCountry,
    this.selectedState,
    this.selectedDistrict,
    this.submitStatus = EmployeeFormSubmitStatus.idle,
    this.errorMessage,
  });

  EmployeeFormState copyWith({
    EmployeeFormMode? mode,
    EmployeeEntity? editingEmployee,
    List<CountryEntity>? countries,
    LocationLoadStatus? countriesStatus,
    List<StateEntity>? states,
    LocationLoadStatus? statesStatus,
    List<CityEntity>? cities,
    LocationLoadStatus? citiesStatus,
    String? selectedCountry,
    String? selectedState,
    String? selectedDistrict,
    bool clearState = false,
    bool clearDistrict = false,
    EmployeeFormSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmployeeFormState(
      mode: mode ?? this.mode,
      editingEmployee: editingEmployee ?? this.editingEmployee,
      countries: countries ?? this.countries,
      countriesStatus: countriesStatus ?? this.countriesStatus,
      states: states ?? this.states,
      statesStatus: statesStatus ?? this.statesStatus,
      cities: cities ?? this.cities,
      citiesStatus: citiesStatus ?? this.citiesStatus,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedState: clearState ? null : (selectedState ?? this.selectedState),
      selectedDistrict: clearDistrict
          ? null
          : (selectedDistrict ?? this.selectedDistrict),
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    mode,
    editingEmployee,
    countries,
    countriesStatus,
    states,
    statesStatus,
    cities,
    citiesStatus,
    selectedCountry,
    selectedState,
    selectedDistrict,
    submitStatus,
    errorMessage,
  ];
}
