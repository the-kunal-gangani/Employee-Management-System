import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.country,
    required super.state,
    required super.district,
    super.avatarUrl,
    super.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      avatarUrl: json['avatar']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      mobile: entity.mobile,
      country: entity.country,
      state: entity.state,
      district: entity.district,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
      if (avatarUrl != null) 'avatar': avatarUrl,
    };
  }

  Map<String, dynamic> toCacheJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
      'avatar': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
