import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/auth/usecases/forgot_password.dart';
import 'package:employee_management_system/features/auth/usecases/get_auth_state_changes.dart';
import 'package:employee_management_system/features/auth/usecases/register_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_google.dart';
import 'package:employee_management_system/features/auth/usecases/sign_out.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:employee_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_event.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_state.dart';

class MockGetAuthStateChanges extends Mock implements GetAuthStateChanges {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockRegisterWithEmail extends Mock implements RegisterWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockSignOut extends Mock implements SignOut {}

void main() {
  late MockGetAuthStateChanges getAuthStateChanges;
  late MockSignInWithEmail signInWithEmail;
  late MockRegisterWithEmail registerWithEmail;
  late MockSignInWithGoogle signInWithGoogle;
  late MockForgotPassword forgotPassword;
  late MockSignOut signOut;

  const tUser = UserEntity(uid: 'uid_123', email: 'user@example.com');
  const tEmail = 'user@example.com';
  const tPassword = 'password123';

  setUp(() {
    getAuthStateChanges = MockGetAuthStateChanges();
    signInWithEmail = MockSignInWithEmail();
    registerWithEmail = MockRegisterWithEmail();
    signInWithGoogle = MockSignInWithGoogle();
    forgotPassword = MockForgotPassword();
    signOut = MockSignOut();

    when(() => getAuthStateChanges()).thenAnswer((_) => const Stream.empty());
  });

  AuthBloc buildBloc() => AuthBloc(
    getAuthStateChanges: getAuthStateChanges,
    signInWithEmail: signInWithEmail,
    registerWithEmail: registerWithEmail,
    signInWithGoogle: signInWithGoogle,
    forgotPassword: forgotPassword,
    signOut: signOut,
  );

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'subscribes to auth state changes and emits authenticated when a user arrives',
      setUp: () {
        when(
          () => getAuthStateChanges(),
        ).thenAnswer((_) => Stream.value(tUser));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when stream yields null',
      setUp: () {
        when(() => getAuthStateChanges()).thenAnswer((_) => Stream.value(null));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.user, 'user', isNull),
      ],
    );
  });

  group('AuthSignInWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits submitting then authenticated success on valid credentials',
      build: buildBloc,
      setUp: () {
        when(
          () => signInWithEmail(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const Right(tUser));
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.success,
            )
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits submitting then failure on invalid credentials',
      build: buildBloc,
      setUp: () {
        when(
          () => signInWithEmail(email: tEmail, password: tPassword),
        ).thenAnswer(
          (_) async => const Left(AuthFailure('Incorrect email or password.')),
        );
      },
      act: (bloc) => bloc.add(
        const AuthSignInWithEmailRequested(email: tEmail, password: tPassword),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.failure,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Incorrect email or password.',
            ),
      ],
    );
  });

  group('AuthRegisterWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated success on successful registration',
      build: buildBloc,
      setUp: () {
        when(
          () => registerWithEmail(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const Right(tUser));
      },
      act: (bloc) => bloc.add(
        const AuthRegisterWithEmailRequested(
          email: tEmail,
          password: tPassword,
        ),
      ),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.success,
            )
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );
  });

  group('AuthSignInWithGoogleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated success when Google sign-in succeeds',
      build: buildBloc,
      setUp: () {
        when(
          () => signInWithGoogle(),
        ).thenAnswer((_) async => const Right(tUser));
      },
      act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.success,
            )
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits failure when the user cancels Google sign-in',
      build: buildBloc,
      setUp: () {
        when(() => signInWithGoogle()).thenAnswer(
          (_) async => const Left(AuthFailure('Google sign in was cancelled.')),
        );
      },
      act: (bloc) => bloc.add(const AuthSignInWithGoogleRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.failure,
            )
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Google sign in was cancelled.',
            ),
      ],
    );
  });

  group('AuthForgotPasswordRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits success with a confirmation message',
      build: buildBloc,
      setUp: () {
        when(
          () => forgotPassword(email: tEmail),
        ).thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email: tEmail)),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.actionStatus,
          'actionStatus',
          AuthActionStatus.submitting,
        ),
        isA<AuthState>()
            .having(
              (s) => s.actionStatus,
              'actionStatus',
              AuthActionStatus.success,
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Password reset email sent. Check your inbox.',
            ),
      ],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated with cleared user on success',
      build: buildBloc,
      setUp: () {
        when(() => signOut()).thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.user, 'user', isNull),
      ],
    );
  });
}
