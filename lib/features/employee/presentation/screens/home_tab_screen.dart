import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/shimmer_placeholders.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../presentation/bloc/employee_list/employee_list_bloc.dart';
import '../../presentation/bloc/employee_list/employee_list_event.dart';
import '../../presentation/bloc/employee_list/employee_list_state.dart';
import '../widgets/country_bar_chart.dart';
import '../widgets/employee_card.dart';
import 'employee_detail_screen.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<EmployeeListBloc, EmployeeListState>(
        builder: (context, listState) {
          final employees = listState.employees;
          final isLoading = listState.status == EmployeeListStatus.loading;
          final totalCount = employees.length;
          final countryCount = employees.map((e) => e.country).toSet().length;
          final stateCount = employees.map((e) => e.state).toSet().length;
          final withDistrict = employees
              .where((e) => e.district.isNotEmpty)
              .length;

          final countsByCountry = <String, int>{};
          for (final employee in employees) {
            if (employee.country.isEmpty) continue;
            countsByCountry[employee.country] =
                (countsByCountry[employee.country] ?? 0) + 1;
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EmployeeListBloc>().add(
                const EmployeeListRefreshed(),
              );
              await context.read<EmployeeListBloc>().stream.firstWhere(
                (s) => !s.isRefreshing,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final name =
                        authState.user?.displayName ??
                        authState.user?.email?.split('@').first ??
                        'there';
                    return Text(
                      'Good ${_greetingPeriod()}, $name',
                      style: theme.textTheme.headlineMedium,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s what\'s happening with your team',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const ShimmerStatGrid()
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        label: 'Total Employees',
                        value: '$totalCount',
                        icon: Icons.groups_outlined,
                        color: StatCardColor.blue,
                      ),
                      StatCard(
                        label: 'States Covered',
                        value: '$stateCount',
                        icon: Icons.map_outlined,
                        color: StatCardColor.green,
                      ),
                      StatCard(
                        label: 'Countries',
                        value: '$countryCount',
                        icon: Icons.public,
                        color: StatCardColor.purple,
                      ),
                      StatCard(
                        label: 'Profiles Complete',
                        value: '$withDistrict',
                        icon: Icons.verified_outlined,
                        color: StatCardColor.yellow,
                      ),
                    ],
                  ),
                if (!isLoading && countsByCountry.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Employees by country',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CountryBarChart(countsByCountry: countsByCountry),
                ],
                const SizedBox(height: 12),
                Text('Recent employees', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                if (isLoading)
                  const SizedBox(
                    height: 260,
                    child: ShimmerEmployeeList(itemCount: 3),
                  )
                else if (employees.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No employees yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  ...employees
                      .take(5)
                      .map(
                        (employee) => EmployeeCard(
                          employee: employee,
                          heroEnabled: false,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EmployeeDetailScreen(employee: employee),
                              ),
                            );
                          },
                          onDelete: () {},
                          showDeleteAction: false,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _greetingPeriod() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
