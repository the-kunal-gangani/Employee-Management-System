import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/storage_constants.dart';

class ThemePreferenceService {
  final Box _settingsBox;

  ThemePreferenceService(this._settingsBox);

  static Future<Box> openBox() async {
    return Hive.openBox(StorageConstants.settingsBox);
  }

  ThemeMode getThemeMode() {
    final value = _settingsBox.get(
      StorageConstants.themeModeKey,
      defaultValue: 'system',
    );
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _settingsBox.put(StorageConstants.themeModeKey, value);
  }
}
