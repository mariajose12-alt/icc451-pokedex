// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get navPokedex => 'Pokédex';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navTrivia => 'Trivia';

  @override
  String get navSettings => 'Settings';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get catalogEmptyTitle => 'No Pokémon saved yet';

  @override
  String get catalogEmptyMessage =>
      'Connect to the Internet to download the catalog. After that you can use it offline.';

  @override
  String get catalogErrorTitle => 'The catalog could not be loaded';

  @override
  String get catalogRefreshFailedBanner =>
      'Could not update. Showing saved data.';

  @override
  String get errorNoConnection =>
      'No Internet connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The request took too long. Try again.';

  @override
  String get errorRateLimit =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorService => 'The service is not available right now.';

  @override
  String get errorUnknown => 'An unexpected error occurred.';

  @override
  String pokemonSemanticLabel(String name, int number, String types) {
    return '$name, Pokédex number $number, types: $types';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String pokemonCount(int count) {
    return '$count Pokemon';
  }

  @override
  String get viewGrid => 'Grid';

  @override
  String get viewList => 'List';

  @override
  String get indicatorOnline => 'Online';

  @override
  String get indicatorOffline => 'Offline';

  @override
  String get indicatorUnavailable => 'Service unavailable';

  @override
  String get indicatorSyncing => 'Syncing…';

  @override
  String get indicatorChecking => 'Checking…';

  @override
  String indicatorDetailOnline(String sync) {
    return 'Remote data · $sync';
  }

  @override
  String indicatorDetailOffline(String sync) {
    return 'Local data · $sync';
  }

  @override
  String indicatorDetailUnavailable(String sync) {
    return 'Network active, API not responding · local data · $sync';
  }

  @override
  String get indicatorDetailSyncing => 'Online · you can keep browsing';

  @override
  String get indicatorDetailChecking => 'Checking the service';

  @override
  String indicatorLastSync(String time) {
    return 'last sync $time';
  }

  @override
  String get indicatorNeverSynced => 'not synced yet';

  @override
  String indicatorSemantics(String status, String detail) {
    return 'Connection status: $status. $detail';
  }

  @override
  String get catalogRefreshFailedTitle => 'Update failed';

  @override
  String get catalogRefreshFailedMessage => 'Showing saved data. Try again.';

  @override
  String get catalogSearchHint => 'Search by name';

  @override
  String get catalogSearchClear => 'Clear search';

  @override
  String get catalogSearchOpen => 'Search';

  @override
  String get catalogSearchClose => 'Close search';

  @override
  String get catalogFilterType => 'Type';

  @override
  String get catalogFilterGeneration => 'Generation';

  @override
  String get catalogSortLabel => 'Sort';

  @override
  String get catalogRegion1 => 'Kanto';

  @override
  String get catalogRegion2 => 'Johto';

  @override
  String get catalogRegion3 => 'Hoenn';

  @override
  String get catalogRegion4 => 'Sinnoh';

  @override
  String get catalogRegion5 => 'Unova';

  @override
  String get catalogRegion6 => 'Kalos';

  @override
  String get catalogRegion7 => 'Alola';

  @override
  String get catalogRegion8 => 'Galar';

  @override
  String get catalogRegion9 => 'Paldea';

  @override
  String get catalogGenerationSheetTitle => 'Generation';

  @override
  String get catalogApplyFilter => 'Apply';

  @override
  String get catalogClearFilter => 'Clear';

  @override
  String get debugSimulateOutage => 'Simulate API outage (testing only)';

  @override
  String get detailNotFoundTitle => 'Pokémon not found';

  @override
  String get detailNotFoundMessage =>
      'This Pokémon is not saved on your device.';

  @override
  String get detailBack => 'Back';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailWeight => 'Weight';

  @override
  String detailHeightValue(String value) {
    return '$value m';
  }

  @override
  String detailWeightValue(String value) {
    return '$value kg';
  }

  @override
  String get detailStatsTitle => 'Base stats';

  @override
  String get detailStatsEmpty => 'Stats not available yet';

  @override
  String get detailStatTotal => 'Total';

  @override
  String detailStatPercent(int percent) {
    return '$percent%';
  }

  @override
  String detailStatSemantic(String name, int value, int percent) {
    return '$name: $value, $percent percent';
  }

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpAttack => 'Sp. Atk';

  @override
  String get statSpDefense => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get detailMatchupsTitle => 'Damage matchups';

  @override
  String get detailMatchupsWeak => 'Weak to';

  @override
  String get detailMatchupsResist => 'Resists';

  @override
  String get detailMatchupsImmune => 'Immune to';

  @override
  String get detailMatchupsEmpty => 'Matchups not available yet';

  @override
  String get detailTabSummary => 'Summary';

  @override
  String get detailTabEvolution => 'Evolution';

  @override
  String get detailTabCombat => 'Combat';

  @override
  String get detailTabMoves => 'Moves';

  @override
  String get detailDataTitle => 'Data';

  @override
  String get detailSectionPending => 'This section will be available soon';

  @override
  String get detailActionShiny => 'View shiny version';

  @override
  String get detailActionForm => 'Change form';

  @override
  String get detailActionShare => 'Share';

  @override
  String get detailAbilitiesTitle => 'Abilities';

  @override
  String get detailAbilitiesEmpty => 'No abilities recorded';

  @override
  String get detailAbilityHidden => 'Hidden';

  @override
  String get detailAbilityNoEffect => 'No description';

  @override
  String get detailAbilitiesEnglishNote => 'Descriptions are in English';

  @override
  String get detailExtrasPending =>
      'This data downloads when you open the Pokémon online';

  @override
  String get detailEggGroupsTitle => 'Egg groups';

  @override
  String get evolutionTitle => 'Evolution line';

  @override
  String get eggGroupMonster => 'Monster';

  @override
  String get eggGroupWater1 => 'Water 1';

  @override
  String get eggGroupWater2 => 'Water 2';

  @override
  String get eggGroupWater3 => 'Water 3';

  @override
  String get eggGroupBug => 'Bug';

  @override
  String get eggGroupFlying => 'Flying';

  @override
  String get eggGroupField => 'Field';

  @override
  String get eggGroupFairy => 'Fairy';

  @override
  String get eggGroupGrass => 'Grass';

  @override
  String get eggGroupHumanLike => 'Human-Like';

  @override
  String get eggGroupMineral => 'Mineral';

  @override
  String get eggGroupAmorphous => 'Amorphous';

  @override
  String get eggGroupDitto => 'Ditto';

  @override
  String get eggGroupDragon => 'Dragon';

  @override
  String get eggGroupUndiscovered => 'Undiscovered';

  @override
  String get evolutionNone => 'This Pokémon does not evolve';

  @override
  String get evolutionCurrent => 'Current';

  @override
  String evolutionTriggerLevel(int level) {
    return 'Level $level';
  }

  @override
  String get evolutionTriggerLevelUp => 'Level up';

  @override
  String get evolutionTriggerFriendship => 'High friendship';

  @override
  String get evolutionTriggerTrade => 'Trade';

  @override
  String evolutionTriggerItem(String item) {
    return 'Use $item';
  }

  @override
  String get evolutionTriggerItemGeneric => 'Use an item';

  @override
  String get evolutionTriggerUnknown => 'Special condition';

  @override
  String get evolutionTimeDay => 'during the day';

  @override
  String get evolutionTimeNight => 'at night';

  @override
  String get evolutionTimeDusk => 'at dusk';

  @override
  String get detailFormSheetTitle => 'Form';

  @override
  String get detailFormNormal => 'Normal';

  @override
  String get detailFormCurrent => 'Current';

  @override
  String get detailFormClose => 'Close';

  @override
  String get movesVersionLabel => 'Version';

  @override
  String get movesVersionSheetTitle => 'Game version';

  @override
  String movesVersionButtonLabel(String name) {
    return 'Game version: $name. Change';
  }

  @override
  String get movesMethodsLabel => 'Learning method';

  @override
  String get movesMethodLevel => 'Level';

  @override
  String get movesMethodMachine => 'TM';

  @override
  String get movesMethodTutor => 'Tutor';

  @override
  String get movesMethodEgg => 'Egg';

  @override
  String get movesOrderLabel => 'Sort by';

  @override
  String get movesOrderLevel => 'Level';

  @override
  String get movesOrderName => 'Name';

  @override
  String movesLevelTag(int level) {
    return 'Lv.$level';
  }

  @override
  String get movesEmptyTitle => 'No moves for this method';

  @override
  String get movesEmptyMessage => 'Try another method or game version.';

  @override
  String get cardNationalDex => 'NATIONAL POKÉDEX';

  @override
  String get cardTotal => 'TOTAL';

  @override
  String get cardHeightWeight => 'Height / Weight';

  @override
  String get cardAbilities => 'Abilities';

  @override
  String cardAbilityHidden(String name) {
    return '$name (hidden)';
  }

  @override
  String get cardWeakTo => 'Weak to';

  @override
  String get cardResists => 'Resists';

  @override
  String get cardFooter => 'Pokédex · ICC451';

  @override
  String get cardNoData => '—';

  @override
  String get cardShareAction => 'Share card';

  @override
  String get cardShareError => 'Couldn\'t create the image. Please try again.';

  @override
  String cardShareText(String name, String number) {
    return '$name · No. $number · Pokédex';
  }

  @override
  String get detailFavoriteAdd => 'Add to favorites';

  @override
  String get detailFavoriteRemove => 'Remove from favorites';

  @override
  String get catalogTypeSheetTitle => 'Type';

  @override
  String get catalogSortNumber => 'Number';

  @override
  String get catalogSortName => 'Name';

  @override
  String get catalogSortTotal => 'Base total';

  @override
  String get catalogPartialNotice =>
      'Filtering only the Pokémon saved on this device';

  @override
  String get catalogClearAll => 'Clear filters';
}
