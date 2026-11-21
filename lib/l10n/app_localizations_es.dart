// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get navPokedex => 'Pokédex';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navTrivia => 'Trivia';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get loading => 'Cargando';

  @override
  String get retry => 'Reintentar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get catalogEmptyTitle => 'Aún no hay Pokémon guardados';

  @override
  String get catalogEmptyMessage => 'Conéctate a Internet para descargar el catálogo. Después podrás usarlo sin conexión.';

  @override
  String get catalogErrorTitle => 'No se pudo cargar el catálogo';

  @override
  String get catalogRefreshFailedBanner => 'No se pudo actualizar. Mostrando los datos guardados.';

  @override
  String get errorNoConnection => 'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout => 'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorRateLimit => 'Se hicieron demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';

  @override
  String get errorService => 'El servicio no está disponible en este momento.';

  @override
  String get errorUnknown => 'Ocurrió un error inesperado.';

  @override
  String pokemonSemanticLabel(String name, int number, String types) {
    return '$name, Pokédex número $number, tipos: $types';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String pokemonCount(int count) {
    return '$count Pokémon';
  }

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get viewList => 'Lista';

  @override
  String get indicatorOnline => 'En línea';

  @override
  String get indicatorOffline => 'Sin conexión';

  @override
  String get indicatorUnavailable => 'Servicio no disponible';

  @override
  String get indicatorSyncing => 'Sincronizando…';

  @override
  String get indicatorChecking => 'Verificando…';

  @override
  String indicatorDetailOnline(String sync) {
    return 'Datos remotos · $sync';
  }

  @override
  String indicatorDetailOffline(String sync) {
    return 'Datos locales · $sync';
  }

  @override
  String indicatorDetailUnavailable(String sync) {
    return 'Red activa, API sin respuesta · datos locales · $sync';
  }

  @override
  String get indicatorDetailSyncing => 'En línea · puedes seguir navegando';

  @override
  String get indicatorDetailChecking => 'Comprobando el servicio';

  @override
  String indicatorLastSync(String time) {
    return 'última sync $time';
  }

  @override
  String get indicatorNeverSynced => 'sin sincronizar';

  @override
  String indicatorSemantics(String status, String detail) {
    return 'Estado de conexión: $status. $detail';
  }

  @override
  String get catalogRefreshFailedTitle => 'No se pudo actualizar';

  @override
  String get catalogRefreshFailedMessage => 'Se muestran los datos guardados. Inténtalo de nuevo.';

  @override
  String get debugSimulateOutage => 'Simular caída de la API (solo pruebas)';

  @override
  String get detailNotFoundTitle => 'Pokémon no encontrado';

  @override
  String get detailNotFoundMessage => 'Este Pokémon no está guardado en tu dispositivo.';

  @override
  String get detailBack => 'Volver';

  @override
  String get detailHeight => 'Altura';

  @override
  String get detailWeight => 'Peso';

  @override
  String detailHeightValue(String value) {
    return '$value m';
  }

  @override
  String detailWeightValue(String value) {
    return '$value kg';
  }

  @override
  String get detailStatsTitle => 'Estadísticas base';

  @override
  String get detailStatsEmpty => 'Estadísticas no disponibles todavía';

  @override
  String get detailStatTotal => 'Total';

  @override
  String detailStatPercent(int percent) {
    return '$percent %';
  }

  @override
  String detailStatSemantic(String name, int value, int percent) {
    return '$name: $value, $percent por ciento';
  }

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Ataque';

  @override
  String get statDefense => 'Defensa';

  @override
  String get statSpAttack => 'At. esp.';

  @override
  String get statSpDefense => 'Def. esp.';

  @override
  String get statSpeed => 'Velocidad';

  @override
  String get detailMatchupsTitle => 'Matchups de daño';

  @override
  String get detailMatchupsWeak => 'Débil contra';

  @override
  String get detailMatchupsResist => 'Resiste';

  @override
  String get detailMatchupsImmune => 'Inmune a';

  @override
  String get detailMatchupsEmpty => 'Matchups no disponibles todavía';

  @override
  String get detailTabSummary => 'Resumen';

  @override
  String get detailTabEvolution => 'Evolución';

  @override
  String get detailTabCombat => 'Combate';

  @override
  String get detailTabMoves => 'Movs.';

  @override
  String get detailDataTitle => 'Datos';

  @override
  String get detailSectionPending => 'Esta sección estará disponible pronto';

  @override
  String get detailActionShiny => 'Ver versión shiny';

  @override
  String get detailActionForm => 'Cambiar de forma';

  @override
  String get detailActionShare => 'Compartir';

  @override
  String get detailAbilitiesTitle => 'Habilidades';

  @override
  String get detailAbilitiesEmpty => 'Sin habilidades registradas';

  @override
  String get detailAbilityHidden => 'Oculta';

  @override
  String get detailAbilityNoEffect => 'Sin descripción';

  @override
  String get detailAbilitiesEnglishNote => 'Las descripciones están en inglés';

  @override
  String get detailExtrasPending => 'Estos datos se descargan al abrir el Pokémon con conexión';

  @override
  String get detailEggGroupsTitle => 'Grupos huevo';

  @override
  String get evolutionTitle => 'Línea evolutiva';

  @override
  String get eggGroupMonster => 'Monstruo';

  @override
  String get eggGroupWater1 => 'Agua 1';

  @override
  String get eggGroupWater2 => 'Agua 2';

  @override
  String get eggGroupWater3 => 'Agua 3';

  @override
  String get eggGroupBug => 'Bicho';

  @override
  String get eggGroupFlying => 'Volador';

  @override
  String get eggGroupField => 'Campo';

  @override
  String get eggGroupFairy => 'Hada';

  @override
  String get eggGroupGrass => 'Planta';

  @override
  String get eggGroupHumanLike => 'Humanoide';

  @override
  String get eggGroupMineral => 'Mineral';

  @override
  String get eggGroupAmorphous => 'Amorfo';

  @override
  String get eggGroupDitto => 'Ditto';

  @override
  String get eggGroupDragon => 'Dragón';

  @override
  String get eggGroupUndiscovered => 'Desconocido';

  @override
  String get evolutionNone => 'Este Pokémon no evoluciona';

  @override
  String get evolutionCurrent => 'Actual';

  @override
  String evolutionTriggerLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get evolutionTriggerLevelUp => 'Subir de nivel';

  @override
  String get evolutionTriggerFriendship => 'Amistad alta';

  @override
  String get evolutionTriggerTrade => 'Intercambio';

  @override
  String evolutionTriggerItem(String item) {
    return 'Usar $item';
  }

  @override
  String get evolutionTriggerItemGeneric => 'Usar un objeto';

  @override
  String get evolutionTriggerUnknown => 'Condición especial';

  @override
  String get evolutionTimeDay => 'de día';

  @override
  String get evolutionTimeNight => 'de noche';

  @override
  String get evolutionTimeDusk => 'al anochecer';

  @override
  String get detailFormSheetTitle => 'Forma';

  @override
  String get detailFormNormal => 'Normal';

  @override
  String get detailFormCurrent => 'Actual';

  @override
  String get detailFormClose => 'Cerrar';

  @override
  String get movesVersionLabel => 'Versión';

  @override
  String get movesVersionSheetTitle => 'Versión del juego';

  @override
  String movesVersionButtonLabel(String name) {
    return 'Versión del juego: $name. Cambiar';
  }

  @override
  String get movesMethodsLabel => 'Método de aprendizaje';

  @override
  String get movesMethodLevel => 'Nivel';

  @override
  String get movesMethodMachine => 'MT';

  @override
  String get movesMethodTutor => 'Tutor';

  @override
  String get movesMethodEgg => 'Huevo';

  @override
  String get movesOrderLabel => 'Ordenar por';

  @override
  String get movesOrderLevel => 'Nivel';

  @override
  String get movesOrderName => 'Nombre';

  @override
  String movesLevelTag(int level) {
    return 'Nv.$level';
  }

  @override
  String get movesEmptyTitle => 'Sin movimientos por este método';

  @override
  String get movesEmptyMessage => 'Prueba con otro método o con otra versión del juego.';
}
