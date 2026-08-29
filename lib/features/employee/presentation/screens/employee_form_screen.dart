import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_form/employee_form_bloc.dart';
import '../bloc/employee_form/employee_form_event.dart';
import '../bloc/employee_form/employee_form_state.dart';
import '../bloc/employee_list/employee_list_bloc.dart';
import '../bloc/employee_list/employee_list_event.dart';
import '../widgets/country_state_district_picker.dart';

class EmployeeFormScreen extends StatelessWidget {
  final EmployeeEntity? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<EmployeeFormBloc>()
            ..add(EmployeeFormStarted(existingEmployee: employee)),
      child: _EmployeeFormView(isEditing: employee != null),
    );
  }
}

class _EmployeeFormView extends StatefulWidget {
  final bool isEditing;

  const _EmployeeFormView({required this.isEditing});

  @override
  State<_EmployeeFormView> createState() => _EmployeeFormViewState();
}

class _EmployeeFormViewState extends State<_EmployeeFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    final existing = context.read<EmployeeFormBloc>().state.editingEmployee;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _emailController = TextEditingController(text: existing?.email ?? '');
    _mobileController = TextEditingController(text: existing?.mobile ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<EmployeeFormBloc>().add(
        EmployeeFormSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _mobileController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SafeArea(
        child: BlocListener<EmployeeFormBloc, EmployeeFormState>(
          listenWhen: (previous, current) =>
              previous.submitStatus != current.submitStatus,
          listener: (context, state) {
            if (state.submitStatus == EmployeeFormSubmitStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            } else if (state.submitStatus == EmployeeFormSubmitStatus.success) {
              context.read<EmployeeListBloc>().add(
                const EmployeeListRefreshed(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isEditing ? 'Employee updated' : 'Employee added',
                  ),
                ),
              );
              Navigator.of(context).pop();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Full name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => Validators.required(v, fieldName: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Mobile',
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: Validators.mobile,
                  ),
                  const SizedBox(height: 16),
                  const CountryStateDistrictPicker(),
                  const SizedBox(height: 28),
                  BlocBuilder<EmployeeFormBloc, EmployeeFormState>(
                    builder: (context, state) {
                      final isSubmitting =
                          state.submitStatus ==
                          EmployeeFormSubmitStatus.submitting;
                      return CustomButton(
                        label: widget.isEditing
                            ? 'Save changes'
                            : 'Add employee',
                        isLoading: isSubmitting,
                        onPressed: isSubmitting ? null : _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
