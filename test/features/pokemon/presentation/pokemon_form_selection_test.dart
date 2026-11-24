import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/domain/entities/pokemon_form.dart';
import 'package:pokedex/features/pokemon/presentation/widgets/pokemon_details/pokemon_form_selection.dart';

PokemonForm _form(
  int id, {
  bool isDefault = false,
  String? artwork,
  String? shinyArtwork,
  String? sprite,
  String? shinySprite,
}) => PokemonForm(
  id: id,
  name: 'form-$id',
  isDefault: isDefault,
  typeIds: const [10],
  spriteUrl: sprite,
  shinySpriteUrl: shinySprite,
  artworkUrl: artwork,
  shinyArtworkUrl: shinyArtwork,
);

void main() {
  test('sin formas no hay nada que elegir ni shiny', () {
    final selection = PokemonFormSelection.resolve(
      forms: const [],
      chosenFormId: null,
      shinyRequested: true,
    );

    expect(selection.current, isNull);
    expect(selection.canShiny, isFalse);
    expect(selection.shinyOn, isFalse);
    expect(selection.overrideImage, isFalse);
  });

  test('forma normal sin shiny usa las imágenes del catálogo', () {
    final selection = PokemonFormSelection.resolve(
      forms: [_form(6, isDefault: true, artwork: 'a')],
      chosenFormId: null,
      shinyRequested: false,
    );

    expect(selection.current?.id, 6);
    expect(selection.overrideImage, isFalse);
    expect(selection.isOtherForm, isFalse);
  });

  test('shiny en la forma normal usa las imágenes shiny', () {
    final selection = PokemonFormSelection.resolve(
      forms: [_form(6, isDefault: true, shinyArtwork: 'sa', shinySprite: 'ss')],
      chosenFormId: null,
      shinyRequested: true,
    );

    expect(selection.canShiny, isTrue);
    expect(selection.shinyOn, isTrue);
    expect(selection.overrideImage, isTrue);
    expect(selection.artworkUrl, 'sa');
    expect(selection.spriteUrl, 'ss');
  });

  test('otra forma usa sus propias imágenes', () {
    final selection = PokemonFormSelection.resolve(
      forms: [
        _form(6, isDefault: true, artwork: 'a6'),
        _form(10034, artwork: 'a34', sprite: 's34'),
      ],
      chosenFormId: 10034,
      shinyRequested: false,
    );

    expect(selection.isOtherForm, isTrue);
    expect(selection.overrideImage, isTrue);
    expect(selection.artworkUrl, 'a34');
    expect(selection.spriteUrl, 's34');
  });

  test('shiny pedido en una forma sin shiny no se activa', () {
    final selection = PokemonFormSelection.resolve(
      forms: [
        _form(6, isDefault: true, shinyArtwork: 'sa'),
        _form(10034, artwork: 'a34'),
      ],
      chosenFormId: 10034,
      shinyRequested: true,
    );

    expect(selection.canShiny, isFalse);
    expect(selection.shinyOn, isFalse);
    // Se ve la forma elegida normal, no la shiny de otra.
    expect(selection.artworkUrl, 'a34');
  });

  test('un id de forma que no existe cae en la forma normal', () {
    final selection = PokemonFormSelection.resolve(
      forms: [_form(6, isDefault: true), _form(10034)],
      chosenFormId: 999,
      shinyRequested: false,
    );

    expect(selection.current?.id, 6);
    expect(selection.isOtherForm, isFalse);
  });

  test('si ninguna viene marcada como normal usa la primera', () {
    final selection = PokemonFormSelection.resolve(
      forms: [_form(1), _form(2)],
      chosenFormId: null,
      shinyRequested: false,
    );

    expect(selection.current?.id, 1);
  });
}
