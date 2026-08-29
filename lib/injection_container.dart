import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:employee_management_system/features/auth/data/datasources/auth_data_remote_source.dart';
import 'package:employee_management_system/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:employee_management_system/features/auth/usecases/forgot_password.dart';
import 'package:employee_management_system/features/auth/usecases/get_auth_state_changes.dart';
import 'package:employee_management_system/features/auth/usecases/register_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_email.dart';
import 'package:employee_management_system/features/auth/usecases/sign_in_with_google.dart';
import 'package:employee_management_system/features/auth/usecases/sign_out.dart';
import 'package:employee_management_system/features/employee/data/repository/employee_repository_impl.dart';
import 'package:employee_management_system/features/employee/domain/usecases/create_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/delete_employees.dart';
import 'package:employee_management_system/features/employee/domain/usecases/get_employees_by_id.dart';
import 'package:employee_management_system/features/employee/domain/usecases/update_employees.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_preference_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/employee/data/datasources/employee_local_datasource.dart';
import 'features/employee/data/datasources/employee_remote_datasource.dart';
import 'features/employee/data/datasources/location_remote_datasource.dart';
import 'features/employee/domain/repositories/employee_repository.dart';
import 'features/employee/domain/usecases/get_cities.dart';
import 'features/employee/domain/usecases/get_countries.dart';
import 'features/employee/domain/usecases/get_employees.dart';
import 'features/employee/domain/usecases/get_states.dart';

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
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
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
  final employeeBox = await EmployeeLocalDataSourceImpl.openBox();
  sl.registerLazySingleton<EmployeeLocalDataSource>(
    () => EmployeeLocalDataSourceImpl(employeeBox),
  );
  sl.registerLazySingleton<EmployeeRemoteDataSource>(
    () => EmployeeRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(
      remoteDataSource: sl(),
      locationRemoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetEmployees(sl()));
  sl.registerLazySingleton(() => GetEmployeeById(sl()));
  sl.registerLazySingleton(() => CreateEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));
  sl.registerLazySingleton(() => DeleteEmployee(sl()));
  sl.registerLazySingleton(() => GetCountries(sl()));
  sl.registerLazySingleton(() => GetStates(sl()));
  sl.registerLazySingleton(() => GetCities(sl()));
}
