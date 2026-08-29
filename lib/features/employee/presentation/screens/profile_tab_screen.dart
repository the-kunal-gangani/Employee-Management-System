import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Profile', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                  backgroundImage: hasPhoto
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: !hasPhoto
                      ? Text(
                          (user?.displayName?.trim().isNotEmpty ?? false)
                              ? user!.displayName!
                                    .trim()
                                    .substring(0, 1)
                                    .toUpperCase()
                              : (user?.email?.substring(0, 1).toUpperCase() ??
                                    '?'),
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.displayName?.trim().isNotEmpty ?? false
                      ? user!.displayName!
                      : 'Employee Admin',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Sign out',
                outlined: true,
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
              ),
            ],
          );
        },
      ),
    );
  }
}
