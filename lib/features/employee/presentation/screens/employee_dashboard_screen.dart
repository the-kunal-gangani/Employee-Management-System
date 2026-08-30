import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/shimmer_placeholders.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_list/employee_list_bloc.dart';
import '../bloc/employee_list/employee_list_event.dart';
import '../bloc/employee_list/employee_list_state.dart';
import '../widgets/employee_card.dart' hide EmployeeListBloc;
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  final _searchController = TextEditingController();
  final _filterController = TextEditingController();
  EmployeeFilterField _selectedFilterField = EmployeeFilterField.none;

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context, EmployeeEntity employee) async {
    return ConfirmationDialog.show(
      context,
      title: 'Delete employee',
      message: 'Are you sure you want to delete ${employee.name}? You can undo this for a few seconds.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
  }

  void _deleteWithUndo(BuildContext context, EmployeeEntity employee) {
    context.read<EmployeeListBloc>().add(EmployeeDeletePending(employee));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${employee.name} deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () =>
              context.read<EmployeeListBloc>().add(const EmployeeDeleteUndone()),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: EmployeeFilterField.values
                    .where((f) => f != EmployeeFilterField.none)
                    .map((field) {
                  final label = switch (field) {
                    EmployeeFilterField.name => 'Name',
                    EmployeeFilterField.email => 'Email',
                    EmployeeFilterField.mobile => 'Mobile',
                    EmployeeFilterField.country => 'Country',
                    EmployeeFilterField.none => '',
                  };
                  return ChoiceChip(
                    label: Text(label),
                    selected: _selectedFilterField == field,
                    onSelected: (_) {
                      setState(() => _selectedFilterField = field);
                      Navigator.of(sheetContext).pop();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _filterController,
                decoration: const InputDecoration(hintText: 'Filter value'),
                onSubmitted: (value) {
                  context.read<EmployeeListBloc>().add(
                        EmployeeFilterChanged(
                          field: _selectedFilterField,
                          query: value,
                        ),
                      );
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _selectedFilterField = EmployeeFilterField.none);
                        _filterController.clear();
                        context.read<EmployeeListBloc>().add(
                              const EmployeeFilterChanged(
                                field: EmployeeFilterField.none,
                                query: '',
                              ),
                            );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Clear filter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<EmployeeListBloc>().add(
                              EmployeeFilterChanged(
                                field: _selectedFilterField,
                                query: _filterController.text,
                              ),
                            );
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by employee ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => context
                  .read<EmployeeListBloc>()
                  .add(EmployeeSearchByIdChanged(value)),
            ),
          ),
          Expanded(
            child: BlocConsumer<EmployeeListBloc, EmployeeListState>(
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus,
              listener: (context, state) {
                if (state.deleteStatus == EmployeeDeleteStatus.failure &&
                    state.deleteErrorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.deleteErrorMessage!)),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == EmployeeListStatus.loading) {
                  return const ShimmerEmployeeList();
                }
                if (state.status == EmployeeListStatus.error) {
                  return ErrorView(
                    message: state.errorMessage ?? 'Something went wrong.',
                    onRetry: () => context
                        .read<EmployeeListBloc>()
                        .add(const EmployeeListStarted()),
                  );
                }
                if (state.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.people_outline,
                    title: 'No employees found',
                    subtitle: state.searchId.isNotEmpty ||
                            state.filterField != EmployeeFilterField.none
                        ? 'Try adjusting your search or filter.'
                        : 'Tap + to add your first employee.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<EmployeeListBloc>().add(const EmployeeListRefreshed());
                    await context.read<EmployeeListBloc>().stream.firstWhere(
                          (s) => !s.isRefreshing,
                        );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: state.filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = state.filteredEmployees[index];
                      return Dismissible(
                        key: ValueKey(employee.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context, employee),
                        onDismissed: (_) => _deleteWithUndo(context, employee),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        child: EmployeeCard(
                          employee: employee,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EmployeeDetailScreen(employee: employee),
                              ),
                            );
                          },
                          onDelete: () async {
                            final confirmed = await _confirmDelete(context, employee);
                            if (confirmed && context.mounted) {
                              _deleteWithUndo(context, employee);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}