import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get appTitle;

  /// No description provided for @navPokedex.
  ///
  /// In en, this message translates to:
  /// **'Pokédex'**
  String get navPokedex;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navTrivia.
  ///
  /// In en, this message translates to:
  /// **'Trivia'**
  String get navTrivia;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon saved yet'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Connect to the Internet to download the catalog. After that you can use it offline.'**
  String get catalogEmptyMessage;

  /// No description provided for @catalogErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'The catalog could not be loaded'**
  String get catalogErrorTitle;

  /// No description provided for @catalogRefreshFailedBanner.
  ///
  /// In en, this message translates to:
  /// **'Could not update. Showing saved data.'**
  String get catalogRefreshFailedBanner;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection. Check your network and try again.'**
  String get errorNoConnection;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Try again.'**
  String get errorTimeout;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get errorRateLimit;

  /// No description provided for @errorService.
  ///
  /// In en, this message translates to:
  /// **'The service is not available right now.'**
  String get errorService;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnknown;

  /// No description provided for @pokemonSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}, Pokédex number {number}, types: {types}'**
  String pokemonSemanticLabel(String name, int number, String types);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @pokemonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Pokemon'**
  String pokemonCount(int count);

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @indicatorOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get indicatorOnline;

  /// No description provided for @indicatorOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get indicatorOffline;

  /// No description provided for @indicatorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable'**
  String get indicatorUnavailable;

  /// No description provided for @indicatorSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get indicatorSyncing;

  /// No description provided for @indicatorChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get indicatorChecking;

  /// No description provided for @indicatorDetailOnline.
  ///
  /// In en, this message translates to:
  /// **'Remote data · {sync}'**
  String indicatorDetailOnline(String sync);

  /// No description provided for @indicatorDetailOffline.
  ///
  /// In en, this message translates to:
  /// **'Local data · {sync}'**
  String indicatorDetailOffline(String sync);

  /// No description provided for @indicatorDetailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Network active, API not responding · local data · {sync}'**
  String indicatorDetailUnavailable(String sync);

  /// No description provided for @indicatorDetailSyncing.
  ///
  /// In en, this message translates to:
  /// **'Online · you can keep browsing'**
  String get indicatorDetailSyncing;

  /// No description provided for @indicatorDetailChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking the service'**
  String get indicatorDetailChecking;

  /// No description provided for @indicatorLastSync.
  ///
  /// In en, this message translates to:
  /// **'last sync {time}'**
  String indicatorLastSync(String time);

  /// No description provided for @indicatorNeverSynced.
  ///
  /// In en, this message translates to:
  /// **'not synced yet'**
  String get indicatorNeverSynced;

  /// No description provided for @indicatorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Connection status: {status}. {detail}'**
  String indicatorSemantics(String status, String detail);

  /// No description provided for @catalogRefreshFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get catalogRefreshFailedTitle;

  /// No description provided for @catalogRefreshFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Showing saved data. Try again.'**
  String get catalogRefreshFailedMessage;

  /// No description provided for @debugSimulateOutage.
  ///
  /// In en, this message translates to:
  /// **'Simulate API outage (testing only)'**
  String get debugSimulateOutage;

  /// No description provided for @detailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokémon not found'**
  String get detailNotFoundTitle;

  /// No description provided for @detailNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon is not saved on your device.'**
  String get detailNotFoundMessage;

  /// No description provided for @detailBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get detailBack;

  /// No description provided for @detailHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// No description provided for @detailWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailWeight;

  /// No description provided for @detailHeightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String detailHeightValue(String value);

  /// No description provided for @detailWeightValue.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String detailWeightValue(String value);

  /// No description provided for @detailStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Base stats'**
  String get detailStatsTitle;

  /// No description provided for @detailStatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Stats not available yet'**
  String get detailStatsEmpty;

  /// No description provided for @detailStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get detailStatTotal;

  /// No description provided for @detailStatPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String detailStatPercent(int percent);

  /// No description provided for @detailStatSemantic.
  ///
  /// In en, this message translates to:
  /// **'{name}: {value}, {percent} percent'**
  String detailStatSemantic(String name, int value, int percent);

  /// No description provided for @statHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// No description provided for @statAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get statAttack;

  /// No description provided for @statDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get statDefense;

  /// No description provided for @statSpAttack.
  ///
  /// In en, this message translates to:
  /// **'Sp. Atk'**
  String get statSpAttack;

  /// No description provided for @statSpDefense.
  ///
  /// In en, this message translates to:
  /// **'Sp. Def'**
  String get statSpDefense;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// No description provided for @detailMatchupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Damage matchups'**
  String get detailMatchupsTitle;

  /// No description provided for @detailMatchupsWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak to'**
  String get detailMatchupsWeak;

  /// No description provided for @detailMatchupsResist.
  ///
  /// In en, this message translates to:
  /// **'Resists'**
  String get detailMatchupsResist;

  /// No description provided for @detailMatchupsImmune.
  ///
  /// In en, this message translates to:
  /// **'Immune to'**
  String get detailMatchupsImmune;

  /// No description provided for @detailMatchupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Matchups not available yet'**
  String get detailMatchupsEmpty;

  /// No description provided for @detailTabSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get detailTabSummary;

  /// No description provided for @detailTabEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get detailTabEvolution;

  /// No description provided for @detailTabCombat.
  ///
  /// In en, this message translates to:
  /// **'Combat'**
  String get detailTabCombat;

  /// No description provided for @detailTabMoves.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get detailTabMoves;

  /// No description provided for @detailDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get detailDataTitle;

  /// No description provided for @detailSectionPending.
  ///
  /// In en, this message translates to:
  /// **'This section will be available soon'**
  String get detailSectionPending;

  /// No description provided for @detailActionShiny.
  ///
  /// In en, this message translates to:
  /// **'View shiny version'**
  String get detailActionShiny;

  /// No description provided for @detailActionForm.
  ///
  /// In en, this message translates to:
  /// **'Change form'**
  String get detailActionForm;

  /// No description provided for @detailActionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get detailActionShare;

  /// No description provided for @detailAbilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get detailAbilitiesTitle;

  /// No description provided for @detailAbilitiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No abilities recorded'**
  String get detailAbilitiesEmpty;

  /// No description provided for @detailAbilityHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get detailAbilityHidden;

  /// No description provided for @detailAbilityNoEffect.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get detailAbilityNoEffect;

  /// No description provided for @detailAbilitiesEnglishNote.
  ///
  /// In en, this message translates to:
  /// **'Descriptions are in English'**
  String get detailAbilitiesEnglishNote;

  /// No description provided for @detailExtrasPending.
  ///
  /// In en, this message translates to:
  /// **'This data downloads when you open the Pokémon online'**
  String get detailExtrasPending;

  /// No description provided for @detailEggGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Egg groups'**
  String get detailEggGroupsTitle;

  /// No description provided for @evolutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolution line'**
  String get evolutionTitle;

  /// No description provided for @eggGroupMonster.
  ///
  /// In en, this message translates to:
  /// **'Monster'**
  String get eggGroupMonster;

  /// No description provided for @eggGroupWater1.
  ///
  /// In en, this message translates to:
  /// **'Water 1'**
  String get eggGroupWater1;

  /// No description provided for @eggGroupWater2.
  ///
  /// In en, this message translates to:
  /// **'Water 2'**
  String get eggGroupWater2;

  /// No description provided for @eggGroupWater3.
  ///
  /// In en, this message translates to:
  /// **'Water 3'**
  String get eggGroupWater3;

  /// No description provided for @eggGroupBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get eggGroupBug;

  /// No description provided for @eggGroupFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get eggGroupFlying;

  /// No description provided for @eggGroupField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get eggGroupField;

  /// No description provided for @eggGroupFairy.
  ///
  /// In en, this message translates to:
  /// **'Fairy'**
  String get eggGroupFairy;

  /// No description provided for @eggGroupGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get eggGroupGrass;

  /// No description provided for @eggGroupHumanLike.
  ///
  /// In en, this message translates to:
  /// **'Human-Like'**
  String get eggGroupHumanLike;

  /// No description provided for @eggGroupMineral.
  ///
  /// In en, this message translates to:
  /// **'Mineral'**
  String get eggGroupMineral;

  /// No description provided for @eggGroupAmorphous.
  ///
  /// In en, this message translates to:
  /// **'Amorphous'**
  String get eggGroupAmorphous;

  /// No description provided for @eggGroupDitto.
  ///
  /// In en, this message translates to:
  /// **'Ditto'**
  String get eggGroupDitto;

  /// No description provided for @eggGroupDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get eggGroupDragon;

  /// No description provided for @eggGroupUndiscovered.
  ///
  /// In en, this message translates to:
  /// **'Undiscovered'**
  String get eggGroupUndiscovered;

  /// No description provided for @evolutionNone.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon does not evolve'**
  String get evolutionNone;

  /// No description provided for @evolutionCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get evolutionCurrent;

  /// No description provided for @evolutionTriggerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String evolutionTriggerLevel(int level);

  /// No description provided for @evolutionTriggerLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get evolutionTriggerLevelUp;

  /// No description provided for @evolutionTriggerFriendship.
  ///
  /// In en, this message translates to:
  /// **'High friendship'**
  String get evolutionTriggerFriendship;

  /// No description provided for @evolutionTriggerTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get evolutionTriggerTrade;

  /// No description provided for @evolutionTriggerItem.
  ///
  /// In en, this message translates to:
  /// **'Use {item}'**
  String evolutionTriggerItem(String item);

  /// No description provided for @evolutionTriggerItemGeneric.
  ///
  /// In en, this message translates to:
  /// **'Use an item'**
  String get evolutionTriggerItemGeneric;

  /// No description provided for @evolutionTriggerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Special condition'**
  String get evolutionTriggerUnknown;

  /// No description provided for @evolutionTimeDay.
  ///
  /// In en, this message translates to:
  /// **'during the day'**
  String get evolutionTimeDay;

  /// No description provided for @evolutionTimeNight.
  ///
  /// In en, this message translates to:
  /// **'at night'**
  String get evolutionTimeNight;

  /// No description provided for @evolutionTimeDusk.
  ///
  /// In en, this message translates to:
  /// **'at dusk'**
  String get evolutionTimeDusk;

  /// No description provided for @detailFormSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get detailFormSheetTitle;

  /// No description provided for @detailFormNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get detailFormNormal;

  /// No description provided for @detailFormCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get detailFormCurrent;

  /// No description provided for @detailFormClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get detailFormClose;

  /// No description provided for @movesVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get movesVersionLabel;

  /// No description provided for @movesVersionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Game version'**
  String get movesVersionSheetTitle;

  /// No description provided for @movesVersionButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Game version: {name}. Change'**
  String movesVersionButtonLabel(String name);

  /// No description provided for @movesMethodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Learning method'**
  String get movesMethodsLabel;

  /// No description provided for @movesMethodLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get movesMethodLevel;

  /// No description provided for @movesMethodMachine.
  ///
  /// In en, this message translates to:
  /// **'TM'**
  String get movesMethodMachine;

  /// No description provided for @movesMethodTutor.
  ///
  /// In en, this message translates to:
  /// **'Tutor'**
  String get movesMethodTutor;

  /// No description provided for @movesMethodEgg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get movesMethodEgg;

  /// No description provided for @movesOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get movesOrderLabel;

  /// No description provided for @movesOrderLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get movesOrderLevel;

  /// No description provided for @movesOrderName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get movesOrderName;

  /// No description provided for @movesLevelTag.
  ///
  /// In en, this message translates to:
  /// **'Lv.{level}'**
  String movesLevelTag(int level);

  /// No description provided for @movesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No moves for this method'**
  String get movesEmptyTitle;

  /// No description provided for @movesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another method or game version.'**
  String get movesEmptyMessage;

  /// No description provided for @cardNationalDex.
  ///
  /// In en, this message translates to:
  /// **'NATIONAL POKÉDEX'**
  String get cardNationalDex;

  /// No description provided for @cardTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get cardTotal;

  /// No description provided for @cardHeightWeight.
  ///
  /// In en, this message translates to:
  /// **'Height / Weight'**
  String get cardHeightWeight;

  /// No description provided for @cardAbilities.
  ///
  /// In en, this message translates to:
  /// **'Abilities'**
  String get cardAbilities;

  /// No description provided for @cardAbilityHidden.
  ///
  /// In en, this message translates to:
  /// **'{name} (hidden)'**
  String cardAbilityHidden(String name);

  /// No description provided for @cardWeakTo.
  ///
  /// In en, this message translates to:
  /// **'Weak to'**
  String get cardWeakTo;

  /// No description provided for @cardResists.
  ///
  /// In en, this message translates to:
  /// **'Resists'**
  String get cardResists;

  /// No description provided for @cardFooter.
  ///
  /// In en, this message translates to:
  /// **'Pokédex · ICC451'**
  String get cardFooter;

  /// No description provided for @cardNoData.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get cardNoData;

  /// No description provided for @cardShareAction.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get cardShareAction;

  /// No description provided for @cardShareError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the image. Please try again.'**
  String get cardShareError;

  /// No description provided for @cardShareText.
  ///
  /// In en, this message translates to:
  /// **'{name} · No. {number} · Pokédex'**
  String cardShareText(String name, String number);

  /// No description provided for @detailFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get detailFavoriteAdd;

  /// No description provided for @detailFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get detailFavoriteRemove;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
