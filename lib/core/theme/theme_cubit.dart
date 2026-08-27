import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_preference_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemePreferenceService _service;

  ThemeCubit(this._service) : super(_service.getThemeMode());

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);
    emit(mode);
  }
}
