import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:employee_management_system/features/auth/data/datasources/auth_data_remote_source.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:employee_management_system/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management_system/features/auth/usecases/forgot_password.dart';
import 'package:employee_management_system/features/auth/usecases/get_auth_state_changes.dart';
import 'package:employee_management_system/features/auth/usecases/register_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_google.dart';
import 'package:employee_management_system/features/auth/usecases/sign_out.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_preference_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------------- Core ----------------
  sl.registerLazySingleton(() => DioClient.create());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final settingsBox = await ThemePreferenceService.openBox();
  sl.registerLazySingleton(() => ThemePreferenceService(settingsBox));
  sl.registerFactory(() => ThemeCubit(sl()));

  // ---------------- Firebase ----------------
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // GoogleSignIn v7 is a singleton that must be initialized once,
  // asynchronously, before authenticate() can be called.
  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize();
  sl.registerLazySingleton(() => googleSignIn);

  // ---------------- Feature: Auth ----------------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetAuthStateChanges(sl()));

  sl.registerFactory(
    () => AuthBloc(
      getAuthStateChanges: sl(),
      signInWithEmail: sl(),
      registerWithEmail: sl(),
      signInWithGoogle: sl(),
      forgotPassword: sl(),
      signOut: sl(),
    ),
  );

  // ---------------- Feature: Employee ----------------
  // Registered in initEmployeeDependencies() — called from here once
  // the employee data/domain/presentation layers exist.
}