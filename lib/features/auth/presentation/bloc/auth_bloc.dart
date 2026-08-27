import 'dart:async';

import 'package:employee_management_system/features/auth/usecases/forgot_password.dart';
import 'package:employee_management_system/features/auth/usecases/get_auth_state_changes.dart';
import 'package:employee_management_system/features/auth/usecases/register_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_google.dart';
import 'package:employee_management_system/features/auth/usecases/sign_out.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateChanges getAuthStateChanges;
  final SignInWithEmail signInWithEmail;
  final RegisterWithEmail registerWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final ForgotPassword forgotPassword;
  final SignOut signOut;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({
    required this.getAuthStateChanges,
    required this.signInWithEmail,
    required this.registerWithEmail,
    required this.signInWithGoogle,
    required this.forgotPassword,
    required this.signOut,
  }) : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthRegisterWithEmailRequested>(_onRegisterWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = getAuthStateChanges().listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: event.user,
        clearUser: event.user == null,
      ),
    );
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AuthActionStatus.submitting,
        clearError: true,
      ),
    );
    final result = await signInWithEmail(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.success,
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onRegisterWithEmail(
    AuthRegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AuthActionStatus.submitting,
        clearError: true,
      ),
    );
    final result = await registerWithEmail(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.success,
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AuthActionStatus.submitting,
        clearError: true,
      ),
    );
    final result = await signInWithGoogle();
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.success,
          status: AuthStatus.authenticated,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AuthActionStatus.submitting,
        clearError: true,
        clearSuccess: true,
      ),
    );
    final result = await forgotPassword(email: event.email);
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.success,
          successMessage: 'Password reset email sent. Check your inbox.',
        ),
      ),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await signOut();
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: AuthActionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          actionStatus: AuthActionStatus.idle,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
