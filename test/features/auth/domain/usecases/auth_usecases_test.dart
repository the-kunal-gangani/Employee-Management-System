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
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const tUser = UserEntity(uid: 'uid_123', email: 'user@example.com');
  const tEmail = 'user@example.com';
  const tPassword = 'password123';

  setUp(() {
    repository = MockAuthRepository();
  });

  group('SignInWithEmail', () {
    test(
      'delegates to repository.signInWithEmail and returns its result',
      () async {
        when(
          () => repository.signInWithEmail(email: tEmail, password: tPassword),
        ).thenAnswer((_) async => const Right(tUser));

        final usecase = SignInWithEmail(repository);
        final result = await usecase(email: tEmail, password: tPassword);

        expect(result, const Right<Failure, UserEntity>(tUser));
        verify(
          () => repository.signInWithEmail(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    test('propagates failure from repository', () async {
      when(
        () => repository.signInWithEmail(email: tEmail, password: tPassword),
      ).thenAnswer(
        (_) async => const Left(AuthFailure('Incorrect email or password.')),
      );

      final usecase = SignInWithEmail(repository);
      final result = await usecase(email: tEmail, password: tPassword);

      expect(
        result,
        const Left<Failure, UserEntity>(
          AuthFailure('Incorrect email or password.'),
        ),
      );
    });
  });

  group('RegisterWithEmail', () {
    test('delegates to repository.registerWithEmail', () async {
      when(
        () => repository.registerWithEmail(email: tEmail, password: tPassword),
      ).thenAnswer((_) async => const Right(tUser));

      final usecase = RegisterWithEmail(repository);
      final result = await usecase(email: tEmail, password: tPassword);

      expect(result, const Right<Failure, UserEntity>(tUser));
    });
  });

  group('SignInWithGoogle', () {
    test('delegates to repository.signInWithGoogle', () async {
      when(
        () => repository.signInWithGoogle(),
      ).thenAnswer((_) async => const Right(tUser));

      final usecase = SignInWithGoogle(repository);
      final result = await usecase();

      expect(result, const Right<Failure, UserEntity>(tUser));
      verify(() => repository.signInWithGoogle()).called(1);
    });
  });

  group('ForgotPassword', () {
    test('delegates to repository.sendPasswordResetEmail', () async {
      when(
        () => repository.sendPasswordResetEmail(email: tEmail),
      ).thenAnswer((_) async => const Right(null));

      final usecase = ForgotPassword(repository);
      final result = await usecase(email: tEmail);

      expect(result, const Right<Failure, void>(null));
    });
  });

  group('SignOut', () {
    test('delegates to repository.signOut', () async {
      when(
        () => repository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      final usecase = SignOut(repository);
      final result = await usecase();

      expect(result, const Right<Failure, void>(null));
      verify(() => repository.signOut()).called(1);
    });
  });

  group('GetAuthStateChanges', () {
    test('returns the repository stream', () {
      when(
        () => repository.authStateChanges,
      ).thenAnswer((_) => Stream.value(tUser));

      final usecase = GetAuthStateChanges(repository);

      expect(usecase(), emits(tUser));
    });
  });
}
