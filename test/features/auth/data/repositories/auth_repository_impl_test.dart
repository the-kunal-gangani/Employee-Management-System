import 'package:dartz/dartz.dart';
import 'package:employee_management_system/core/errors/exceptions.dart';
import 'package:employee_management_system/core/errors/failures.dart';
import 'package:employee_management_system/features/auth/data/datasources/auth_data_remote_source.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:employee_management_system/core/network/network_info.dart';
import 'package:employee_management_system/features/auth/data/models/user_model.dart';
import 'package:employee_management_system/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockNetworkInfo networkInfo;

  const tEmail = 'user@example.com';
  const tPassword = 'password123';
  const tUserModel = UserModel(uid: 'uid_123', email: tEmail);

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    networkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
  });

  group('signInWithEmail', () {
    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.signInWithEmail(
        email: tEmail,
        password: tPassword,
      );

      expect(
        result,
        const Left<Failure, UserEntity>(
          NetworkFailure('No internet connection.'),
        ),
      );
      verifyNever(
        () => remoteDataSource.signInWithEmail(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test(
      'returns Right(UserEntity) when the datasource call succeeds',
      () async {
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => remoteDataSource.signInWithEmail(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => tUserModel);

        final result = await repository.signInWithEmail(
          email: tEmail,
          password: tPassword,
        );

        expect(result, const Right<Failure, UserEntity>(tUserModel));
      },
    );

    test('maps AuthException to AuthFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.signInWithEmail(
          email: tEmail,
          password: tPassword,
        ),
      ).thenThrow(const AuthException('Incorrect email or password.'));

      final result = await repository.signInWithEmail(
        email: tEmail,
        password: tPassword,
      );

      expect(
        result,
        const Left<Failure, UserEntity>(
          AuthFailure('Incorrect email or password.'),
        ),
      );
    });
  });

  group('registerWithEmail', () {
    test('returns Right(UserEntity) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.registerWithEmail(
          email: tEmail,
          password: tPassword,
        ),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.registerWithEmail(
        email: tEmail,
        password: tPassword,
      );

      expect(result, const Right<Failure, UserEntity>(tUserModel));
    });

    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.registerWithEmail(
        email: tEmail,
        password: tPassword,
      );

      expect(
        result,
        const Left<Failure, UserEntity>(
          NetworkFailure('No internet connection.'),
        ),
      );
    });
  });

  group('signInWithGoogle', () {
    test('returns Right(UserEntity) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.signInWithGoogle(),
      ).thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithGoogle();

      expect(result, const Right<Failure, UserEntity>(tUserModel));
    });

    test('maps AuthException (cancelled) to AuthFailure', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.signInWithGoogle(),
      ).thenThrow(const AuthException('Google sign in was cancelled.'));

      final result = await repository.signInWithGoogle();

      expect(
        result,
        const Left<Failure, UserEntity>(
          AuthFailure('Google sign in was cancelled.'),
        ),
      );
    });
  });

  group('sendPasswordResetEmail', () {
    test('returns Right(null) on success', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => remoteDataSource.sendPasswordResetEmail(email: tEmail),
      ).thenAnswer((_) async {});

      final result = await repository.sendPasswordResetEmail(email: tEmail);

      expect(result, const Right<Failure, void>(null));
    });

    test('returns NetworkFailure when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.sendPasswordResetEmail(email: tEmail);

      expect(
        result,
        const Left<Failure, void>(NetworkFailure('No internet connection.')),
      );
    });
  });

  group('signOut', () {
    test(
      'returns Right(null) on success without checking connectivity',
      () async {
        when(() => remoteDataSource.signOut()).thenAnswer((_) async {});

        final result = await repository.signOut();

        expect(result, const Right<Failure, void>(null));
        verifyNever(() => networkInfo.isConnected);
      },
    );

    test('maps AuthException to AuthFailure', () async {
      when(
        () => remoteDataSource.signOut(),
      ).thenThrow(const AuthException('Sign out failed.'));

      final result = await repository.signOut();

      expect(
        result,
        const Left<Failure, void>(AuthFailure('Sign out failed.')),
      );
    });
  });
}
