import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employee_list/employee_list_bloc.dart';
import '../bloc/employee_list/employee_list_event.dart';
import 'employee_form_screen.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final EmployeeEntity employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete employee',
      message:
          'Are you sure you want to delete ${employee.name}? You can undo this for a few seconds.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final bloc = context.read<EmployeeListBloc>();
    final messenger = ScaffoldMessenger.of(context);

    bloc.add(EmployeeDeletePending(employee));
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${employee.name} deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => bloc.add(const EmployeeDeleteUndone()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmployeeFormScreen(employee: employee),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () => _confirmAndDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Hero(
              tag: 'employee-avatar-${employee.id}',
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    employee.name.trim().isNotEmpty
                        ? employee.name.trim().substring(0, 1).toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(employee.name, style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 32),
          _DetailTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: employee.email,
          ),
          _DetailTile(
            icon: Icons.phone_outlined,
            label: 'Mobile',
            value: employee.mobile,
          ),
          _DetailTile(
            icon: Icons.public,
            label: 'Country',
            value: employee.country,
          ),
          _DetailTile(
            icon: Icons.map_outlined,
            label: 'State',
            value: employee.state,
          ),
          _DetailTile(
            icon: Icons.location_city_outlined,
            label: 'District',
            value: employee.district,
          ),
          _DetailTile(
            icon: Icons.badge_outlined,
            label: 'Employee ID',
            value: employee.id,
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
