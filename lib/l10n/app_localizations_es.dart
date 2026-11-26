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
  String get catalogEmptyMessage =>
      'Conéctate a Internet para descargar el catálogo. Después podrás usarlo sin conexión.';

  @override
  String get catalogErrorTitle => 'No se pudo cargar el catálogo';

  @override
  String get catalogRefreshFailedBanner =>
      'No se pudo actualizar. Mostrando los datos guardados.';

  @override
  String get errorNoConnection =>
      'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout =>
      'La solicitud tardó demasiado. Inténtalo de nuevo.';

  @override
  String get errorRateLimit =>
      'Se hicieron demasiadas solicitudes. Espera un momento e inténtalo de nuevo.';

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
  String get catalogRefreshFailedMessage =>
      'Se muestran los datos guardados. Inténtalo de nuevo.';

  @override
  String get catalogSearchHint => 'Buscar por nombre';

  @override
  String get catalogSearchClear => 'Limpiar búsqueda';

  @override
  String get catalogSearchOpen => 'Buscar';

  @override
  String get catalogSearchClose => 'Cerrar búsqueda';

  @override
  String get catalogFilterType => 'Tipo';

  @override
  String get catalogFilterGeneration => 'Generación';

  @override
  String get catalogSortLabel => 'Orden';

  @override
  String get catalogRegion1 => 'Kanto';

  @override
  String get catalogRegion2 => 'Johto';

  @override
  String get catalogRegion3 => 'Hoenn';

  @override
  String get catalogRegion4 => 'Sinnoh';

  @override
  String get catalogRegion5 => 'Teselia';

  @override
  String get catalogRegion6 => 'Kalos';

  @override
  String get catalogRegion7 => 'Alola';

  @override
  String get catalogRegion8 => 'Galar';

  @override
  String get catalogRegion9 => 'Paldea';

  @override
  String get catalogGenerationSheetTitle => 'Generación';

  @override
  String get catalogApplyFilter => 'Aplicar';

  @override
  String get catalogClearFilter => 'Limpiar';

  @override
  String get debugSimulateOutage => 'Simular caída de la API (solo pruebas)';

  @override
  String get detailNotFoundTitle => 'Pokémon no encontrado';

  @override
  String get detailNotFoundMessage =>
      'Este Pokémon no está guardado en tu dispositivo.';

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
  String get detailExtrasPending =>
      'Estos datos se descargan al abrir el Pokémon con conexión';

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
  String get movesEmptyMessage =>
      'Prueba con otro método o con otra versión del juego.';

  @override
  String get cardNationalDex => 'POKÉDEX NACIONAL';

  @override
  String get cardTotal => 'TOTAL';

  @override
  String get cardHeightWeight => 'Altura / Peso';

  @override
  String get cardAbilities => 'Habilidades';

  @override
  String cardAbilityHidden(String name) {
    return '$name (oculta)';
  }

  @override
  String get cardWeakTo => 'Débil contra';

  @override
  String get cardResists => 'Resiste';

  @override
  String get cardFooter => 'Pokédex · ICC451';

  @override
  String get cardNoData => '—';

  @override
  String get cardShareAction => 'Compartir carta';

  @override
  String get cardShareError =>
      'No se pudo generar la imagen. Inténtalo de nuevo.';

  @override
  String cardShareText(String name, String number) {
    return '$name · N.º $number · Pokédex';
  }

  @override
  String get detailFavoriteAdd => 'Agregar a favoritos';

  @override
  String get detailFavoriteRemove => 'Quitar de favoritos';

  @override
  String get catalogTypeSheetTitle => 'Tipo';

  @override
  String get catalogSortNumber => 'Número';

  @override
  String get catalogSortName => 'Nombre';

  @override
  String get catalogSortTotal => 'Total base';

  @override
  String get catalogPartialNotice =>
      'Filtrando solo los Pokémon guardados en este dispositivo';

  @override
  String get catalogClearAll => 'Quitar filtros';

  @override
  String get triviaBadge => 'TRIVIA';

  @override
  String get triviaTitle => '¿Quién es este Pokémon?';

  @override
  String get triviaStatBest => 'MEJOR';

  @override
  String get triviaStatStreak => 'RACHA';

  @override
  String get triviaStatGames => 'PARTIDAS';

  @override
  String get triviaRules =>
      '10 Pokémon por partida · 15 segundos cada uno · las pistas restan puntos';

  @override
  String get triviaPlay => 'Jugar';

  @override
  String get triviaRanking => 'Ranking';

  @override
  String get triviaAchievements => 'Logros';

  @override
  String triviaSavedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Pokémon disponibles para jugar · sin conexión, solo los que ya viste';
  }

  @override
  String triviaNumber(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get triviaSilhouetteLabel => 'Silueta de un Pokémon misterioso';

  @override
  String triviaQuestionProgress(int current, int total) {
    return 'PREGUNTA $current/$total';
  }

  @override
  String triviaPoints(int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return '$scoreString pts';
  }

  @override
  String triviaSecondsLeft(int seconds) {
    return '$seconds s';
  }

  @override
  String get triviaGuessHint => 'Escribe el nombre…';

  @override
  String triviaHintButton(int cost) {
    return 'Pista · −$cost pts';
  }

  @override
  String get triviaSkip => 'Saltar';

  @override
  String get triviaGuess => 'Adivinar';

  @override
  String triviaLettersLabel(int count) {
    return 'El nombre tiene $count letras';
  }

  @override
  String get triviaCorrect => '¡Correcto!';

  @override
  String get triviaTimeUp => '¡Tiempo agotado!';

  @override
  String triviaWasNumber(String number) {
    return 'Era el $number';
  }

  @override
  String get triviaBreakdownHit => 'Acierto';

  @override
  String triviaBreakdownSpeed(int seconds) {
    return 'Bonus por rapidez ($seconds s)';
  }

  @override
  String triviaStreakReset(int streak) {
    return 'Tu racha de $streak se reinició. ¡Sigue intentando!';
  }

  @override
  String get triviaNext => 'Siguiente';

  @override
  String get triviaGameOver => 'PARTIDA TERMINADA';

  @override
  String get triviaNewRecord => '★ ¡Nuevo récord!';

  @override
  String get triviaCorrectLabel => 'Aciertos';

  @override
  String triviaCorrectOf(int correct, int total) {
    return '$correct de $total';
  }

  @override
  String get triviaAchievementUnlocked => 'LOGRO DESBLOQUEADO';

  @override
  String get triviaPlayAgain => 'Jugar otra vez';

  @override
  String get triviaSeeRanking => 'Ver ranking';

  @override
  String get triviaBackHome => 'Inicio';

  @override
  String triviaDotsLabel(int correct, int total) {
    return '$correct aciertos de $total preguntas';
  }

  @override
  String get triviaBack => 'Volver';

  @override
  String get triviaRankingSubtitle => 'Tus mejores partidas';

  @override
  String get triviaNewTag => 'NUEVO';

  @override
  String triviaPodiumLabel(int position, int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Puesto $position: $scoreString puntos';
  }

  @override
  String triviaRankingRowDetail(int correct, int total, String date) {
    return '$correct de $total aciertos · $date';
  }

  @override
  String get triviaRankingEmptyTitle => 'Aún no hay partidas';

  @override
  String get triviaRankingEmptyMessage =>
      'Juega una partida y tu puntaje aparecerá aquí.';

  @override
  String triviaUnlockedOf(int unlocked, int total) {
    return '$unlocked de $total desbloqueados';
  }

  @override
  String get triviaUnlocked => 'Desbloqueado';

  @override
  String get triviaLocked => 'Bloqueado';

  @override
  String triviaProgressOf(int current, int target) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat targetNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String targetString = targetNumberFormat.format(target);

    return '$currentString/$targetString';
  }

  @override
  String get triviaNoDataBadge => 'SIN CONEXIÓN';

  @override
  String get triviaNoDataTitle => 'Aún no hay suficientes Pokémon';

  @override
  String triviaNoDataMessage(int required) {
    return 'Sin conexión solo se juega con Pokémon cuya imagen ya está guardada. Necesitas al menos $required. Conéctate y abre Pokémon en el catálogo para guardarlos.';
  }

  @override
  String triviaNoDataProgress(int saved, int required) {
    return '$saved de $required disponibles';
  }

  @override
  String get triviaGoCatalog => 'Ir al catálogo';

  @override
  String get triviaRetry => 'Reintentar';

  @override
  String get triviaNoDataNote =>
      'El ranking y los logros siguen disponibles sin conexión.';

  @override
  String get triviaAchFirstGameName => 'Primera partida';

  @override
  String get triviaAchFirstGameDesc => 'Termina tu primera partida';

  @override
  String get triviaAchStreak5Name => 'Racha';

  @override
  String triviaAchStreak5Desc(int count) {
    return 'Acierta $count seguidas';
  }

  @override
  String get triviaAchLightningName => 'Relámpago';

  @override
  String triviaAchLightningDesc(int seconds) {
    return 'Acierta en menos de $seconds segundos';
  }

  @override
  String get triviaAchExpertName => 'Experto';

  @override
  String triviaAchExpertDesc(int points) {
    final intl.NumberFormat pointsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pointsString = pointsNumberFormat.format(points);

    return '$pointsString puntos en una partida';
  }

  @override
  String get triviaAchPerfectName => 'Perfecto';

  @override
  String triviaAchPerfectDesc(int count) {
    return 'Acierta las $count preguntas';
  }

  @override
  String get triviaAchNoHintsName => 'Sin pistas';

  @override
  String triviaAchNoHintsDesc(int count) {
    return 'Acierta $count o más sin usar pistas';
  }

  @override
  String get triviaAchTrainerName => 'Entrenador';

  @override
  String triviaAchTrainerDesc(int count) {
    return 'Acierta $count Pokémon en total';
  }

  @override
  String get triviaAchCollectorName => 'Coleccionista';

  @override
  String triviaAchCollectorDesc(int count) {
    return 'Juega $count partidas';
  }

  @override
  String get triviaAchievementsHint =>
      'Cada logro muestra lo que necesitas para lograrlo';

  @override
  String get triviaExitTitle => '¿Salir de la partida?';

  @override
  String get triviaExitMessage => 'Si sales ahora, esta partida no se guarda.';

  @override
  String get triviaExitStay => 'Seguir jugando';

  @override
  String get triviaExitLeave => 'Salir';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsCatalogView => 'Vista del catálogo';

  @override
  String get settingsLastSync => 'Última sincronización';

  @override
  String get settingsSyncNow => 'Sincronizar ahora';

  @override
  String get settingsSyncNeedsConnection =>
      'Necesitas conexión para sincronizar.';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get settingsTestTools => 'Herramientas de prueba';

  @override
  String get settingsOutageHint =>
      'El servicio aparece como no disponible aunque haya red.';

  @override
  String get settingsSubtitle => 'Tu Pokédex y tus preferencias';

  @override
  String get settingsSavedLabel => 'Tu Pokédex guarda';

  @override
  String get settingsSavedUnit => 'Pokémon';

  @override
  String settingsLastSyncValue(String time) {
    return 'Última sincronización · $time';
  }

  @override
  String get favoritesSubtitle =>
      'Guardados en este teléfono · disponibles sin conexión';

  @override
  String get favoritesSortLabel => 'Ordenar por';

  @override
  String get favoritesSortRecent => 'Recientes';

  @override
  String get favoritesSortName => 'Nombre';

  @override
  String get favoritesSortNumber => 'Número';

  @override
  String get favoritesEmptyTitle => 'Aún no tienes favoritos';

  @override
  String get favoritesEmptyMessage =>
      'Toca el corazón en un Pokémon para guardarlo aquí. Tus favoritos funcionan sin conexión.';

  @override
  String get favoritesEmptyAction => 'Explorar el Pokédex';

  @override
  String get favoritesUndo => 'Deshacer';

  @override
  String favoritesRemovedSnack(String name) {
    return '$name quitado de favoritos';
  }

  @override
  String favoriteAddNamed(String name) {
    return 'Agregar a $name a favoritos';
  }

  @override
  String favoriteRemoveNamed(String name) {
    return 'Quitar a $name de favoritos';
  }

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String onboardingStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingTitle1 => 'Explora cada Pokémon';

  @override
  String get onboardingBody1 =>
      'Toca una tarjeta para ver sus tipos y estadísticas. Esta es de práctica.';

  @override
  String get onboardingTitle2 => 'Guarda tus favoritos';

  @override
  String get onboardingBody2 =>
      'Toca el corazón para guardar un Pokémon y encuéntralo después en Favoritos.';

  @override
  String get onboardingTitle3 => 'Mira si estás en línea';

  @override
  String get onboardingBody3 =>
      'El lente de arriba cambia según tu conexión. La app funciona igual sin internet.';

  @override
  String get onboardingTitle4 => 'Juega a la trivia';

  @override
  String get onboardingBody4 =>
      'Adivina quién es el Pokémon escondido y sube en el ranking.';

  @override
  String onboardingWhereTab(String tab) {
    return 'Dónde: pestaña «$tab»';
  }

  @override
  String get onboardingWhereTop => 'Dónde: arriba, en la barra de estado';

  @override
  String get onboardingTryCard => 'Pruébalo: toca la tarjeta';

  @override
  String get onboardingTryHeart => 'Pruébalo: toca el corazón';

  @override
  String get onboardingTryLens => 'Pruébalo: toca el lente';

  @override
  String get onboardingTryQuestion => 'Pruébalo: toca el «?»';

  @override
  String get onboardingDoneCard =>
      '¡Así de fácil! Cada Pokémon de la Pokédex se abre igual.';

  @override
  String get onboardingDoneHeart =>
      '¡Guardado! Tus favoritos se ven aunque no tengas conexión.';

  @override
  String get onboardingDoneLens =>
      'Así sabes si tus datos están al día. Sigue tocando para ver los demás estados.';

  @override
  String get onboardingDoneQuestion =>
      '¡Es Pikachu! En la trivia lo tendrás que adivinar tú.';

  @override
  String get onboardingDemoType => 'Eléctrico';

  @override
  String get onboardingDemoSpeed => 'Velocidad';

  @override
  String get onboardingDemoCardLabel => 'Tarjeta de práctica: Pikachu';

  @override
  String get onboardingDemoFavorite => 'Marcar como favorito';

  @override
  String get onboardingDemoUnfavorite => 'Quitar de favoritos';

  @override
  String get onboardingDemoLensLabel => 'Lente de práctica: cambia el estado';

  @override
  String get onboardingDemoQuestionLabel =>
      'Pokémon escondido: toca para revelarlo';

  @override
  String get settingsShowIntro => 'Ver introducción';

  @override
  String get detailTabMap => 'Mapa';

  @override
  String regionsNoGames(String region) {
    return 'No hay datos de este Pokémon en juegos de $region.';
  }

  @override
  String regionAvailable(int count, String region) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$region: $count entregas',
      one: '$region: 1 entrega',
    );
    return '$_temp0';
  }

  @override
  String regionUnavailable(String region) {
    return '$region: sin datos';
  }

  @override
  String get regionsEmpty => 'Todavía no hay juegos guardados de este Pokémon.';

  @override
  String get regionsDisclaimer =>
      'Se cuentan los juegos donde el Pokémon tiene movimientos registrados.';

  @override
  String get regionUnova => 'Teselia';

  @override
  String regionsMapLabel(int count, int total) {
    return 'Mapa de regiones. Aparece en $count de $total regiones.';
  }

  @override
  String regionPanelLabel(String region, String generation) {
    return '$region · GENERACIÓN $generation';
  }

  @override
  String regionEntregas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aparece en $count entregas',
      one: 'Aparece en 1 entrega',
    );
    return '$_temp0';
  }

  @override
  String regionStarters(String names) {
    return 'Iniciales de la región: $names';
  }
}
