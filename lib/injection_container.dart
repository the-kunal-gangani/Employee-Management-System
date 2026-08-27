import 'package:connectivity_plus/connectivity_plus.dart';
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
  sl.registerLazySingleton(() => GoogleSignIn());

  // ---------------- Feature: Auth ----------------
  // Registered in initAuthDependencies() — called from here once
  // the auth data/domain/presentation layers exist.

  // ---------------- Feature: Employee ----------------
  // Registered in initEmployeeDependencies() — called from here once
  // the employee data/domain/presentation layers exist.
}
