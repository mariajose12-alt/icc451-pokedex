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
  String get triviaBadge => 'TRIVIA';

  @override
  String get triviaTitle => 'Who is this Pokémon?';

  @override
  String get triviaStatBest => 'BEST';

  @override
  String get triviaStatStreak => 'STREAK';

  @override
  String get triviaStatGames => 'GAMES';

  @override
  String get triviaRules =>
      '10 Pokémon per game · 15 seconds each · hints cost points';

  @override
  String get triviaPlay => 'Play';

  @override
  String get triviaRanking => 'Ranking';

  @override
  String get triviaAchievements => 'Achievements';

  @override
  String triviaSavedCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Pokémon ready to play · offline, only the ones you\'ve seen';
  }

  @override
  String triviaNumber(int value) {
    final intl.NumberFormat valueNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String valueString = valueNumberFormat.format(value);

    return '$valueString';
  }

  @override
  String get triviaSilhouetteLabel => 'Silhouette of a mystery Pokémon';

  @override
  String triviaQuestionProgress(int current, int total) {
    return 'QUESTION $current/$total';
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
  String get triviaGuessHint => 'Type the name…';

  @override
  String triviaHintButton(int cost) {
    return 'Hint · −$cost pts';
  }

  @override
  String get triviaSkip => 'Skip';

  @override
  String get triviaGuess => 'Guess';

  @override
  String triviaLettersLabel(int count) {
    return 'The name has $count letters';
  }

  @override
  String get triviaCorrect => 'Correct!';

  @override
  String get triviaTimeUp => 'Time is up!';

  @override
  String triviaWasNumber(String number) {
    return 'It was $number';
  }

  @override
  String get triviaBreakdownHit => 'Correct answer';

  @override
  String triviaBreakdownSpeed(int seconds) {
    return 'Speed bonus ($seconds s)';
  }

  @override
  String triviaStreakReset(int streak) {
    return 'Your streak of $streak was reset. Keep trying!';
  }

  @override
  String get triviaNext => 'Next';

  @override
  String get triviaGameOver => 'GAME OVER';

  @override
  String get triviaNewRecord => '★ New record!';

  @override
  String get triviaCorrectLabel => 'Correct';

  @override
  String triviaCorrectOf(int correct, int total) {
    return '$correct of $total';
  }

  @override
  String get triviaAchievementUnlocked => 'ACHIEVEMENT UNLOCKED';

  @override
  String get triviaPlayAgain => 'Play again';

  @override
  String get triviaSeeRanking => 'See ranking';

  @override
  String get triviaBackHome => 'Home';

  @override
  String triviaDotsLabel(int correct, int total) {
    return '$correct correct out of $total questions';
  }

  @override
  String get triviaBack => 'Back';

  @override
  String get triviaRankingSubtitle => 'Your best games';

  @override
  String get triviaNewTag => 'NEW';

  @override
  String triviaPodiumLabel(int position, int score) {
    final intl.NumberFormat scoreNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Place $position: $scoreString points';
  }

  @override
  String triviaRankingRowDetail(int correct, int total, String date) {
    return '$correct of $total correct · $date';
  }

  @override
  String get triviaRankingEmptyTitle => 'No games yet';

  @override
  String get triviaRankingEmptyMessage =>
      'Play a game and your score will show up here.';

  @override
  String triviaUnlockedOf(int unlocked, int total) {
    return '$unlocked of $total unlocked';
  }

  @override
  String get triviaUnlocked => 'Unlocked';

  @override
  String get triviaLocked => 'Locked';

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
  String get triviaNoDataBadge => 'OFFLINE';

  @override
  String get triviaNoDataTitle => 'Not enough Pokémon yet';

  @override
  String triviaNoDataMessage(int required) {
    return 'Offline you can only play with Pokémon whose image is already saved. You need at least $required. Connect and open Pokémon in the catalog to save them.';
  }

  @override
  String triviaNoDataProgress(int saved, int required) {
    return '$saved of $required available';
  }

  @override
  String get triviaGoCatalog => 'Go to catalog';

  @override
  String get triviaRetry => 'Retry';

  @override
  String get triviaNoDataNote =>
      'Ranking and achievements stay available offline.';

  @override
  String get triviaAchFirstGameName => 'First game';

  @override
  String get triviaAchFirstGameDesc => 'Finish your first game';

  @override
  String get triviaAchStreak5Name => 'Streak';

  @override
  String triviaAchStreak5Desc(int count) {
    return 'Get $count right in a row';
  }

  @override
  String get triviaAchLightningName => 'Lightning';

  @override
  String triviaAchLightningDesc(int seconds) {
    return 'Answer correctly in under $seconds seconds';
  }

  @override
  String get triviaAchExpertName => 'Expert';

  @override
  String triviaAchExpertDesc(int points) {
    final intl.NumberFormat pointsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pointsString = pointsNumberFormat.format(points);

    return '$pointsString points in a single game';
  }

  @override
  String get triviaAchPerfectName => 'Perfect';

  @override
  String triviaAchPerfectDesc(int count) {
    return 'Get all $count questions right';
  }

  @override
  String get triviaAchNoHintsName => 'No hints';

  @override
  String triviaAchNoHintsDesc(int count) {
    return 'Get $count or more right without hints';
  }

  @override
  String get triviaAchTrainerName => 'Trainer';

  @override
  String triviaAchTrainerDesc(int count) {
    return 'Get $count Pokémon right in total';
  }

  @override
  String get triviaAchCollectorName => 'Collector';

  @override
  String triviaAchCollectorDesc(int count) {
    return 'Play $count games';
  }

  @override
  String get triviaAchievementsHint =>
      'Each achievement shows what you need to unlock it';

  @override
  String get triviaExitTitle => 'Leave the game?';

  @override
  String get triviaExitMessage =>
      'If you leave now, this game won\'t be saved.';

  @override
  String get triviaExitStay => 'Keep playing';

  @override
  String get triviaExitLeave => 'Leave';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCatalogView => 'Catalog view';

  @override
  String get settingsLastSync => 'Last sync';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncNeedsConnection => 'You need a connection to sync.';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsTestTools => 'Testing tools';

  @override
  String get settingsOutageHint =>
      'The service shows as unavailable even with a network.';

  @override
  String get settingsSubtitle => 'Your Pokédex and preferences';

  @override
  String get settingsSavedLabel => 'Your Pokédex has saved';

  @override
  String get settingsSavedUnit => 'Pokémon';

  @override
  String settingsLastSyncValue(String time) {
    return 'Last sync · $time';
  }

  @override
  String get favoritesSubtitle => 'Saved on this phone · available offline';

  @override
  String get favoritesSortLabel => 'Sort by';

  @override
  String get favoritesSortRecent => 'Recent';

  @override
  String get favoritesSortName => 'Name';

  @override
  String get favoritesSortNumber => 'Number';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage =>
      'Tap the heart on a Pokémon to save it here. Favorites work offline.';

  @override
  String get favoritesEmptyAction => 'Explore the Pokédex';

  @override
  String get favoritesUndo => 'Undo';

  @override
  String favoritesRemovedSnack(String name) {
    return '$name removed from favorites';
  }

  @override
  String favoriteAddNamed(String name) {
    return 'Add $name to favorites';
  }

  @override
  String favoriteRemoveNamed(String name) {
    return 'Remove $name from favorites';
  }
}
