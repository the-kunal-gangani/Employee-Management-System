class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://669b3f09276e45187d34eb4e.mockapi.io/api/v1';

  static const String country = '/country';
  static const String employee = '/employee';

  static String employeeById(String id) => '/employee/$id';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
