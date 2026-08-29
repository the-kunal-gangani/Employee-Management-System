import 'dart:convert';

import 'package:employee_management_system/core/errors/exceptions.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/storage_constants.dart';
import '../models/employee_model.dart';

abstract class EmployeeLocalDataSource {
  Future<List<EmployeeModel>> getCachedEmployees();

  Future<void> cacheEmployees(List<EmployeeModel> employees);

  Future<void> clearCache();
}

class EmployeeLocalDataSourceImpl implements EmployeeLocalDataSource {
  final Box box;

  EmployeeLocalDataSourceImpl(this.box);

  static Future<Box> openBox() async {
    return Hive.openBox(StorageConstants.employeeBox);
  }

  @override
  Future<List<EmployeeModel>> getCachedEmployees() async {
    final raw = box.get(StorageConstants.cachedEmployeesKey) as String?;
    if (raw == null) {
      throw const CacheException('No cached employee data found.');
    }
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CacheException('Cached employee data is corrupted.');
    }
  }

  @override
  Future<void> cacheEmployees(List<EmployeeModel> employees) async {
    final encoded = jsonEncode(employees.map((e) => e.toCacheJson()).toList());
    await box.put(StorageConstants.cachedEmployeesKey, encoded);
    await box.put(
      StorageConstants.lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<void> clearCache() async {
    await box.delete(StorageConstants.cachedEmployeesKey);
    await box.delete(StorageConstants.lastSyncKey);
  }
}
