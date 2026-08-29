import '../../domain/entities/country_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({required super.id, required super.name});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['country'] ?? '').toString(),
    );
  }
}
