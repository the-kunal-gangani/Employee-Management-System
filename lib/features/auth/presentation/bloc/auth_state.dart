import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthActionStatus { idle, submitting, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final AuthActionStatus actionStatus;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.actionStatus = AuthActionStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  const AuthState.unknown() : this();

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool clearUser = false,
    AuthActionStatus? actionStatus,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    actionStatus,
    errorMessage,
    successMessage,
  ];
}
