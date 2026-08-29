import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/searchable_dropdown_field.dart';
import '../bloc/employee_form/employee_form_bloc.dart';
import '../bloc/employee_form/employee_form_event.dart';
import '../bloc/employee_form/employee_form_state.dart';

class CountryStateDistrictPicker extends StatelessWidget {
  const CountryStateDistrictPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchableDropdownField(
              label: 'Country',
              value: state.selectedCountry,
              options: state.countries.map((c) => c.name).toList(),
              isLoading: state.countriesStatus == LocationLoadStatus.loading,
              onChanged: (value) => context.read<EmployeeFormBloc>().add(
                EmployeeFormCountrySelected(value),
              ),
            ),
            const SizedBox(height: 16),
            SearchableDropdownField(
              label: 'State',
              value: state.selectedState,
              options: state.states.map((s) => s.name).toList(),
              isLoading: state.statesStatus == LocationLoadStatus.loading,
              enabled: state.selectedCountry != null,
              hint: state.selectedCountry == null
                  ? 'Select a country first'
                  : 'Select a state',
              onChanged: (value) => context.read<EmployeeFormBloc>().add(
                EmployeeFormStateSelected(value),
              ),
            ),
            const SizedBox(height: 16),
            SearchableDropdownField(
              label: 'District',
              value: state.selectedDistrict,
              options: state.cities.map((c) => c.name).toList(),
              isLoading: state.citiesStatus == LocationLoadStatus.loading,
              enabled: state.selectedState != null,
              hint: state.selectedState == null
                  ? 'Select a state first'
                  : 'Select a district',
              onChanged: (value) => context.read<EmployeeFormBloc>().add(
                EmployeeFormDistrictSelected(value),
              ),
            ),
          ],
        );
      },
    );
  }
}
