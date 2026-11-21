import 'package:equatable/equatable.dart';

/// Grupo de versión de los juegos: 'red-blue', 'scarlet-violet'...
class MoveVersionGroup extends Equatable {
  const MoveVersionGroup({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
