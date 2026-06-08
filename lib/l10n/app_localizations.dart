import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Application name shown in the list screen app bar.
  ///
  /// In en, this message translates to:
  /// **'Autoprompter'**
  String get appTitle;

  /// No description provided for @searchPromptsHint.
  ///
  /// In en, this message translates to:
  /// **'Search prompts…'**
  String get searchPromptsHint;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @importMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Import Markdown…'**
  String get importMarkdown;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Back up data…'**
  String get backupData;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup…'**
  String get restoreBackup;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newPrompt.
  ///
  /// In en, this message translates to:
  /// **'New prompt'**
  String get newPrompt;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @openTeleprompter.
  ///
  /// In en, this message translates to:
  /// **'Open teleprompter'**
  String get openTeleprompter;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @shareMd.
  ///
  /// In en, this message translates to:
  /// **'Share (.md)'**
  String get shareMd;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete prompt?'**
  String get deletePromptTitle;

  /// No description provided for @deletePromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{title}\"? This action cannot be undone.'**
  String deletePromptMessage(String title);

  /// No description provided for @promptDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Prompt duplicated'**
  String get promptDuplicated;

  /// No description provided for @copySuffix.
  ///
  /// In en, this message translates to:
  /// **'(copy)'**
  String get copySuffix;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing failed: {error}'**
  String shareFailed(String error);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @noPromptsToBackup.
  ///
  /// In en, this message translates to:
  /// **'No prompts to back up'**
  String get noPromptsToBackup;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @promptsRestored.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 prompt} other{Restored {count} prompts}}'**
  String promptsRestored(int count);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get noContent;

  /// No description provided for @noPromptsMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No prompts match the filters'**
  String get noPromptsMatchFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noPrompts.
  ///
  /// In en, this message translates to:
  /// **'No prompts'**
  String get noPrompts;

  /// No description provided for @emptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"New prompt\" to create your first script to read on the teleprompter.'**
  String get emptyStateMessage;

  /// No description provided for @sortUpdatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Recently edited'**
  String get sortUpdatedDesc;

  /// No description provided for @sortUpdatedAsc.
  ///
  /// In en, this message translates to:
  /// **'Least recently edited'**
  String get sortUpdatedAsc;

  /// No description provided for @sortTitleAsc.
  ///
  /// In en, this message translates to:
  /// **'Title A→Z'**
  String get sortTitleAsc;

  /// No description provided for @sortTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'Title Z→A'**
  String get sortTitleDesc;

  /// No description provided for @sortCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Recently created'**
  String get sortCreatedDesc;

  /// No description provided for @editPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit prompt'**
  String get editPrompt;

  /// No description provided for @markdownPreview.
  ///
  /// In en, this message translates to:
  /// **'Markdown preview'**
  String get markdownPreview;

  /// No description provided for @hidePreview.
  ///
  /// In en, this message translates to:
  /// **'Hide preview'**
  String get hidePreview;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @promptSaved.
  ///
  /// In en, this message translates to:
  /// **'Prompt saved'**
  String get promptSaved;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice language:'**
  String get voiceLanguage;

  /// No description provided for @editorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write the prompt text here…'**
  String get editorPlaceholder;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add tag…'**
  String get addTagHint;

  /// No description provided for @emptyMarkdownPreview.
  ///
  /// In en, this message translates to:
  /// **'_(empty)_'**
  String get emptyMarkdownPreview;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow the system'**
  String get themeSystemSubtitle;

  /// No description provided for @teleprompterDefaults.
  ///
  /// In en, this message translates to:
  /// **'Teleprompter (defaults)'**
  String get teleprompterDefaults;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @autoscrollSpeed.
  ///
  /// In en, this message translates to:
  /// **'Autoscroll speed'**
  String get autoscrollSpeed;

  /// No description provided for @readingLinePosition.
  ///
  /// In en, this message translates to:
  /// **'Reading line position'**
  String get readingLinePosition;

  /// No description provided for @decreaseText.
  ///
  /// In en, this message translates to:
  /// **'Decrease text'**
  String get decreaseText;

  /// No description provided for @increaseText.
  ///
  /// In en, this message translates to:
  /// **'Increase text'**
  String get increaseText;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @readingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading settings'**
  String get readingSettings;

  /// No description provided for @mirrorHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal mirror'**
  String get mirrorHorizontal;

  /// No description provided for @mirrorHorizontalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For the teleprompter glass'**
  String get mirrorHorizontalSubtitle;

  /// No description provided for @mirrorVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical mirror'**
  String get mirrorVertical;

  /// No description provided for @emptyPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'This prompt is empty. Edit it to add some text.'**
  String get emptyPromptMessage;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is unavailable on this device or microphone permission was denied.'**
  String get speechUnavailable;

  /// Word count and estimated reading time shown under the editor.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 word} other{{count} words}} · ~{time}'**
  String readingStatsLabel(int count, String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
