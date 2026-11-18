import 'package:equatable/equatable.dart';

/// Una fila de la tabla de efectividades: un ataque de tipo [damageTypeId]
/// contra un Pokémon de tipo [targetTypeId] hace [damageFactor] % de daño.
class TypeEfficacy extends Equatable {
  const TypeEfficacy({
    required this.damageTypeId,
    required this.targetTypeId,
    required this.damageFactor,
  });

  final int damageTypeId;
  final int targetTypeId;

  /// Porcentaje: 0 (inmune), 50, 100 o 200.
  final int damageFactor;

  @override
  List<Object?> get props => [damageTypeId, targetTypeId, damageFactor];
}