import '../../domain/entities/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({required super.name});

  factory CityModel.fromName(String name) {
    return CityModel(name: name);
  }
}
