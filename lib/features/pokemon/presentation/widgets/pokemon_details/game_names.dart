import 'package:pokedex/features/pokemon/domain/entities/game_region.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_detail_labels.dart';
import 'package:pokedex/l10n/app_localizations.dart';

/// Nombre de la región en el idioma de la app. Solo Unova cambia de nombre
/// (Teselia en español); los demás se escriben igual.
String gameRegionName(AppLocalizations l10n, GameRegion region) {
  return switch (region) {
    GameRegion.unova => l10n.regionUnova,
    _ => prettifySlug(region.name),
  };
}

// (español, inglés) de cada grupo de versión de PokeAPI.
const Map<String, (String, String)> _gameNames = {
  'red-blue': ('Rojo · Azul', 'Red · Blue'),
  'yellow': ('Amarillo', 'Yellow'),
  'gold-silver': ('Oro · Plata', 'Gold · Silver'),
  'crystal': ('Cristal', 'Crystal'),
  'ruby-sapphire': ('Rubí · Zafiro', 'Ruby · Sapphire'),
  'emerald': ('Esmeralda', 'Emerald'),
  'firered-leafgreen': ('Rojo Fuego · Verde Hoja', 'FireRed · LeafGreen'),
  'diamond-pearl': ('Diamante · Perla', 'Diamond · Pearl'),
  'platinum': ('Platino', 'Platinum'),
  'heartgold-soulsilver': ('HeartGold · SoulSilver', 'HeartGold · SoulSilver'),
  'black-white': ('Negro · Blanco', 'Black · White'),
  'black-2-white-2': ('Negro 2 · Blanco 2', 'Black 2 · White 2'),
  'x-y': ('X · Y', 'X · Y'),
  'omega-ruby-alpha-sapphire': (
    'Rubí Omega · Zafiro Alfa',
    'Omega Ruby · Alpha Sapphire',
  ),
  'sun-moon': ('Sol · Luna', 'Sun · Moon'),
  'ultra-sun-ultra-moon': ('Ultrasol · Ultraluna', 'Ultra Sun · Ultra Moon'),
  'lets-go-pikachu-lets-go-eevee': (
    "Let's Go Pikachu · Eevee",
    "Let's Go Pikachu · Eevee",
  ),
  'sword-shield': ('Espada · Escudo', 'Sword · Shield'),
  'the-isle-of-armor': ('La Isla de la Armadura', 'The Isle of Armor'),
  'the-crown-tundra': ('Las Nieves de la Corona', 'The Crown Tundra'),
  'brilliant-diamond-and-shining-pearl': (
    'Diamante Brillante · Perla Reluciente',
    'Brilliant Diamond · Shining Pearl',
  ),
  'legends-arceus': ('Leyendas: Arceus', 'Legends: Arceus'),
  'scarlet-violet': ('Escarlata · Púrpura', 'Scarlet · Violet'),
  'the-teal-mask': ('La Máscara Turquesa', 'The Teal Mask'),
  'the-indigo-disk': ('El Disco Índigo', 'The Indigo Disk'),
  'legends-za': ('Leyendas: Z-A', 'Legends: Z-A'),
};

/// Nombre de un grupo de versión («Rojo · Azul»). Si llega uno que no
/// conocemos se muestra formateado, como en el selector de Movs.
String versionGroupName(String slug, String languageCode) {
  final names = _gameNames[slug];
  if (names == null) return prettifySlug(slug);
  return languageCode == 'es' ? names.$1 : names.$2;
}
