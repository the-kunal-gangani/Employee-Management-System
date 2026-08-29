import 'package:dio/dio.dart';
import 'package:employee_management_system/core/errors/exceptions.dart';
import '../models/city_model.dart';
import '../models/state_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<StateModel>> getStates(String country);

  Future<List<CityModel>> getCities({
    required String country,
    required String state,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;

  static const String _baseUrl = 'https://countriesnow.space/api/v0.1';

  LocationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<StateModel>> getStates(String country) async {
    try {
      final response = await dio.post(
        '$_baseUrl/countries/states',
        data: {'country': country},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['error'] == true) {
        throw ServerException(
          data['msg']?.toString() ?? 'Could not load states.',
        );
      }
      final states = (data['data']?['states'] as List?) ?? [];
      return states
          .map((s) => StateModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  @override
  Future<List<CityModel>> getCities({
    required String country,
    required String state,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/countries/state/cities',
        data: {'country': country, 'state': state},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['error'] == true) {
        throw ServerException(
          data['msg']?.toString() ?? 'Could not load cities.',
        );
      }
      final cities = (data['data'] as List?) ?? [];
      return cities.map((c) => CityModel.fromName(c.toString())).toList();
    } on DioException catch (e) {
      throw ServerException(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Could not connect to the server.';
    }
    return e.message ?? 'Something went wrong. Please try again.';
  }
}
