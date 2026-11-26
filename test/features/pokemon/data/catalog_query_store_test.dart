import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/features/pokemon/data/preferences/catalog_query_store.dart';
import 'package:pokedex/features/pokemon/domain/entities/catalogo_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CatalogQueryStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = CatalogQueryStore(
      preferences: await SharedPreferences.getInstance(),
    );
  });

  test('sin nada guardado, devuelve el criterio por defecto', () {
    expect(store.load(), const CatalogoQuery());
  });

  test('lo que se guarda se recupera igual', () async {
    const criterio = CatalogoQuery(
      nombre: 'pika',
      tipoIds: {13, 12},
      generacionIds: {1},
      orden: CatalogoOrden.totalBase,
    );

    await store.save(criterio);

    expect(store.load(), criterio);
  });

  test('un JSON dañado no impide abrir la app', () async {
    SharedPreferences.setMockInitialValues({'catalog_query': '{no es json'});
    store = CatalogQueryStore(
      preferences: await SharedPreferences.getInstance(),
    );

    expect(store.load(), const CatalogoQuery());
  });

  test('un orden desconocido cae en el valor por defecto', () async {
    SharedPreferences.setMockInitialValues({
      'catalog_query': '{"orden":"no_existe"}',
    });
    store = CatalogQueryStore(
      preferences: await SharedPreferences.getInstance(),
    );

    expect(store.load().orden, CatalogoOrden.numero);
  });

  test('cerrar y reabrir: un store nuevo lee el criterio guardado', () async {
    const criterio = CatalogoQuery(
      tipoIds: {10},
      generacionIds: {2, 3},
      orden: CatalogoOrden.totalBase,
    );
    final prefs = await SharedPreferences.getInstance();

    await CatalogQueryStore(preferences: prefs).save(criterio);

    final reabierto = CatalogQueryStore(preferences: prefs);
    expect(reabierto.load(), criterio);
  });
}
