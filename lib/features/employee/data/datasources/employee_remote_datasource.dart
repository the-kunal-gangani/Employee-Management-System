import 'package:dio/dio.dart';
import 'package:employee_management_system/core/errors/exceptions.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/country_model.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees();

  Future<EmployeeModel> getEmployeeById(String id);

  Future<EmployeeModel> createEmployee(EmployeeModel employee);

  Future<EmployeeModel> updateEmployee(EmployeeModel employee);

  Future<void> deleteEmployee(String id);

  Future<List<CountryModel>> getCountries();
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final Dio dio;

  EmployeeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await dio.get(ApiConstants.employee);
      final data = response.data as List;
      return data
          .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    try {
      final response = await dio.get(ApiConstants.employeeById(id));
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      final response = await dio.post(
        ApiConstants.employee,
        data: employee.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    try {
      final response = await dio.put(
        ApiConstants.employeeById(employee.id),
        data: employee.toJson(),
      );
      return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await dio.delete(ApiConstants.employeeById(id));
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await dio.get(ApiConstants.country);
      final data = response.data as List;
      return data
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.response?.statusCode == 404) {
      return 'The requested employee was not found.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
