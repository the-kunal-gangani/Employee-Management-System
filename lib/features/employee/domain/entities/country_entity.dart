import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String id;
  final String name;

  const CountryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
