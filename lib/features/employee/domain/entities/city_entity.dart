import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String name;

  const CityEntity({required this.name});

  @override
  List<Object?> get props => [name];
}
