import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:employee_management_system/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_event.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_state.dart';
import 'package:employee_management_system/features/auth/presentation/screens/login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthSignInWithEmailRequested(email: '', password: ''),
    );
  });

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthState.unknown());
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets(
    'renders email/password fields, sign-in button, and Google button',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    },
  );

  testWidgets('shows validation errors when submitting empty fields', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('dispatches AuthSignInWithEmailRequested with valid input', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthSignInWithEmailRequested(
          email: 'user@example.com',
          password: 'password123',
        ),
      ),
    ).called(1);
  });

  testWidgets('shows a snackbar with the error message on sign-in failure', (
    tester,
  ) async {
    whenListen(
      authBloc,
      Stream.fromIterable([
        const AuthState(
          actionStatus: AuthActionStatus.failure,
          errorMessage: 'Incorrect email or password.',
        ),
      ]),
      initialState: const AuthState.unknown(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });
}
