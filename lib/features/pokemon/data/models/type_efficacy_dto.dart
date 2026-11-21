/// Una fila de la tabla de efectividades tal como la devuelve PokeAPI:
/// "un ataque de tipo [damageTypeId] contra un Pokémon de tipo
/// [targetTypeId] hace [damageFactor] % de daño".
class TypeEfficacyDto {
  const TypeEfficacyDto({
    required this.damageTypeId,
    required this.targetTypeId,
    required this.damageFactor,
  });

  final int damageTypeId;
  final int targetTypeId;

  /// Porcentaje: 0 (inmune), 50, 100 o 200.
  final int damageFactor;

  factory TypeEfficacyDto.fromJson(Map<String, dynamic> json) {
    return TypeEfficacyDto(
      damageTypeId: json['damage_type_id'] as int,
      targetTypeId: json['target_type_id'] as int,
      damageFactor: json['damage_factor'] as int,
    );
  }

  /// Convierte la respuesta completa (`{ typeefficacy: [...] }`) en una lista.
  static List<TypeEfficacyDto> listFromJson(Map<String, dynamic> data) {
    final rows = data['typeefficacy'] as List<dynamic>;
    final result = <TypeEfficacyDto>[];
    for (final row in rows) {
      result.add(TypeEfficacyDto.fromJson(row as Map<String, dynamic>));
    }
    return result;
  }
}
