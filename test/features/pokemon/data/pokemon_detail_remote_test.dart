import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/network/network_exceptions.dart';
import 'package:pokedex/core/network/poke_api_client.dart';
import 'package:pokedex/features/pokemon/data/datasources/remote/pokemon_remote_datasource.dart';
import 'package:pokedex/features/pokemon/data/models/pokemon_detail_dto.dart';

import '../../../helpers/pokemon_detail_sample.dart';

// Cliente falso: devuelve lo que le digamos y recuerda las variables.
class FakeApiClient implements PokeApiClient {
  Map<String, dynamic>? response;
  Map<String, dynamic>? lastVariables;

  @override
  final String url = 'fake';

  @override
  final Duration timeout = const Duration(seconds: 1);

  @override
  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic> variables = const <String, dynamic>{},
  }) async {
    lastVariables = variables;
    return response!;
  }
}

void main() {
  late FakeApiClient client;
  late PokemonRemoteDataSource dataSource;

  setUp(() {
    client = FakeApiClient();
    dataSource = PokemonRemoteDataSource(client: client);
  });

  test('envía el id del Pokémon como variable', () async {
    client.response = sampleDetail();
    await dataSource.fetchPokemonDetail(1);

    expect(client.lastVariables, <String, dynamic>{'id': 1});
  });

  test('convierte los datos base igual que el catálogo', () async {
    client.response = sampleDetail();
    final detail = await dataSource.fetchPokemonDetail(1);

    expect(detail.base.name, 'bulbasaur');
    expect(detail.base.stats.length, 6);
  });

  test(
    'las habilidades traen nombre por idioma y el indicador de oculta',
    () async {
      client.response = sampleDetail();
      final detail = await dataSource.fetchPokemonDetail(1);

      expect(detail.abilities.length, 2);

      final overgrow = detail.abilities.first;
      expect(overgrow.nameEs, 'Espesura');
      expect(overgrow.nameEn, 'Overgrow');
      expect(overgrow.isHidden, isFalse);
      expect(overgrow.effectEn, 'Boosts grass moves.');

      final chlorophyll = detail.abilities.last;
      expect(chlorophyll.isHidden, isTrue);
      // Sin traducción al español y sin efecto: quedan en null.
      expect(chlorophyll.nameEs, isNull);
      expect(chlorophyll.effectEn, isNull);
    },
  );

  test('lee los egg groups', () async {
    client.response = sampleDetail();
    final detail = await dataSource.fetchPokemonDetail(1);

    expect(detail.eggGroups, ['monster', 'plant']);
  });

  test('la cadena evolutiva trae el trigger y deja la hora en null', () async {
    client.response = sampleDetail();
    final detail = await dataSource.fetchPokemonDetail(1);

    final chain = detail.evolutionChain!;
    expect(chain.nodes.length, 2);

    // La primera especie no viene de nadie y no tiene condición.
    expect(chain.nodes.first.fromSpeciesId, isNull);
    expect(chain.nodes.first.trigger, isNull);

    final ivysaur = chain.nodes.last;
    expect(ivysaur.fromSpeciesId, 1);
    expect(ivysaur.trigger, 'level-up');
    expect(ivysaur.minLevel, 16);
    // '' de PokeAPI se convierte en null.
    expect(ivysaur.timeOfDay, isNull);
  });

  test('las formas traen los sprites normal y shiny', () async {
    client.response = sampleDetail();
    final detail = await dataSource.fetchPokemonDetail(1);

    final form = detail.forms.single;
    expect(form.isDefault, isTrue);
    expect(form.shinySpriteUrl, 'sh.png');
    expect(form.shinyArtworkUrl, 'ash.png');
    expect(form.types.single.typeId, 12);
  });

  test('los movimientos traen método, grupo de versión y nivel', () async {
    client.response = sampleDetail();
    final detail = await dataSource.fetchPokemonDetail(1);

    expect(detail.moves.length, 2);
    final tackle = detail.moves.first;
    expect(tackle.moveName, 'tackle');
    expect(tackle.learnMethodId, 1);
    expect(tackle.versionGroupId, 1);
    expect(tackle.level, 1);
  });

  test('un id que no existe lanza un error tipado', () async {
    final response = sampleDetail();
    response['base'] = <dynamic>[];
    client.response = response;

    expect(
      () => dataSource.fetchPokemonDetail(99999),
      throwsA(isA<UnexpectedNetworkException>()),
    );
  });

  group('AbilityDto.summarize', () {
    test('un texto corto queda igual', () {
      expect(
        AbilityDto.summarize('Boosts grass moves.'),
        'Boosts grass moves.',
      );
    });

    test('sin texto devuelve null', () {
      expect(AbilityDto.summarize(null), isNull);
      expect(AbilityDto.summarize('   '), isNull);
    });

    test('un texto largo se corta en 160 como máximo con «…»', () {
      final long = List.filled(60, 'palabra').join(' ');

      final summary = AbilityDto.summarize(long)!;

      expect(summary.length, lessThanOrEqualTo(160));
      expect(summary.endsWith('…'), isTrue);
      // No parte una palabra por la mitad.
      expect(summary.contains('palabr…'), isFalse);
    });

    test('los saltos de línea se vuelven espacios', () {
      expect(AbilityDto.summarize('uno\n  dos'), 'uno dos');
    });
  });
}
