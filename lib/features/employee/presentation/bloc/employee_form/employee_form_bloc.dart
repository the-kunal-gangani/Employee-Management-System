import 'package:employee_management_system/features/employee/domain/usecases/create_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/update_employees.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/employee_entity.dart';
import '../../../domain/usecases/get_cities.dart';
import '../../../domain/usecases/get_countries.dart';
import '../../../domain/usecases/get_states.dart';
import 'employee_form_event.dart';
import 'employee_form_state.dart';

class EmployeeFormBloc extends Bloc<EmployeeFormEvent, EmployeeFormState> {
  final GetCountries getCountries;
  final GetStates getStates;
  final GetCities getCities;
  final CreateEmployee createEmployee;
  final UpdateEmployee updateEmployee;

  EmployeeFormBloc({
    required this.getCountries,
    required this.getStates,
    required this.getCities,
    required this.createEmployee,
    required this.updateEmployee,
  }) : super(const EmployeeFormState()) {
    on<EmployeeFormStarted>(_onStarted);
    on<EmployeeFormCountrySelected>(_onCountrySelected);
    on<EmployeeFormStateSelected>(_onStateSelected);
    on<EmployeeFormDistrictSelected>(_onDistrictSelected);
    on<EmployeeFormSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(
    EmployeeFormStarted event,
    Emitter<EmployeeFormState> emit,
  ) async {
    final employee = event.existingEmployee;
    emit(
      state.copyWith(
        mode: employee != null ? EmployeeFormMode.edit : EmployeeFormMode.add,
        editingEmployee: employee,
        selectedCountry: employee?.country,
        selectedState: employee?.state,
        selectedDistrict: employee?.district,
        countriesStatus: LocationLoadStatus.loading,
      ),
    );

    final countriesResult = await getCountries();
    await countriesResult.fold(
      (failure) async => emit(
        state.copyWith(
          countriesStatus: LocationLoadStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (countries) async {
        emit(
          state.copyWith(
            countries: countries,
            countriesStatus: LocationLoadStatus.loaded,
          ),
        );
        if (employee != null && employee.country.isNotEmpty) {
          await _loadStates(employee.country, emit);
          if (employee.state.isNotEmpty) {
            await _loadCities(employee.country, employee.state, emit);
          }
        }
      },
    );
  }

  Future<void> _onCountrySelected(
    EmployeeFormCountrySelected event,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCountry: event.country,
        clearState: true,
        clearDistrict: true,
        states: [],
        cities: [],
      ),
    );
    await _loadStates(event.country, emit);
  }

  Future<void> _onStateSelected(
    EmployeeFormStateSelected event,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedState: event.state,
        clearDistrict: true,
        cities: [],
      ),
    );
    if (state.selectedCountry != null) {
      await _loadCities(state.selectedCountry!, event.state, emit);
    }
  }

  void _onDistrictSelected(
    EmployeeFormDistrictSelected event,
    Emitter<EmployeeFormState> emit,
  ) {
    emit(state.copyWith(selectedDistrict: event.district));
  }

  Future<void> _onSubmitted(
    EmployeeFormSubmitted event,
    Emitter<EmployeeFormState> emit,
  ) async {
    if (state.selectedCountry == null ||
        state.selectedState == null ||
        state.selectedDistrict == null) {
      emit(
        state.copyWith(
          submitStatus: EmployeeFormSubmitStatus.failure,
          errorMessage: 'Please select country, state, and district.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: EmployeeFormSubmitStatus.submitting,
        clearError: true,
      ),
    );

    final entity = EmployeeEntity(
      id: state.editingEmployee?.id ?? '',
      name: event.name,
      email: event.email,
      mobile: event.mobile,
      country: state.selectedCountry!,
      state: state.selectedState!,
      district: state.selectedDistrict!,
    );

    final result = state.mode == EmployeeFormMode.edit
        ? await updateEmployee(entity)
        : await createEmployee(entity);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: EmployeeFormSubmitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) =>
          emit(state.copyWith(submitStatus: EmployeeFormSubmitStatus.success)),
    );
  }

  Future<void> _loadStates(
    String country,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(state.copyWith(statesStatus: LocationLoadStatus.loading));
    final result = await getStates(country);
    result.fold(
      (failure) => emit(
        state.copyWith(
          statesStatus: LocationLoadStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (states) => emit(
        state.copyWith(states: states, statesStatus: LocationLoadStatus.loaded),
      ),
    );
  }

  Future<void> _loadCities(
    String country,
    String stateName,
    Emitter<EmployeeFormState> emit,
  ) async {
    emit(state.copyWith(citiesStatus: LocationLoadStatus.loading));
    final result = await getCities(country: country, state: stateName);
    result.fold(
      (failure) => emit(
        state.copyWith(
          citiesStatus: LocationLoadStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (cities) => emit(
        state.copyWith(cities: cities, citiesStatus: LocationLoadStatus.loaded),
      ),
    );
  }
}
