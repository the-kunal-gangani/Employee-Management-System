import 'package:equatable/equatable.dart';

class StateEntity extends Equatable {
  final String name;

  const StateEntity({required this.name});

  @override
  List<Object?> get props => [name];
}
