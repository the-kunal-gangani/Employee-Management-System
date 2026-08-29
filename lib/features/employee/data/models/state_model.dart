import '../../domain/entities/state_entity.dart';

class StateModel extends StateEntity {
  const StateModel({required super.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(name: (json['name'] ?? '').toString());
  }
}
