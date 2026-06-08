// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Search prompts…';

  @override
  String get closeSearch => 'Close search';

  @override
  String get search => 'Search';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get importMarkdown => 'Import Markdown…';

  @override
  String get backupData => 'Back up data…';

  @override
  String get restoreBackup => 'Restore backup…';

  @override
  String get settings => 'Settings';

  @override
  String get newPrompt => 'New prompt';

  @override
  String get moreActions => 'More actions';

  @override
  String get openTeleprompter => 'Open teleprompter';

  @override
  String get untitled => 'Untitled';

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get shareMd => 'Share (.md)';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deletePromptTitle => 'Delete prompt?';

  @override
  String deletePromptMessage(String title) {
    return 'Do you want to delete \"$title\"? This action cannot be undone.';
  }

  @override
  String get promptDuplicated => 'Prompt duplicated';

  @override
  String get copySuffix => '(copy)';

  @override
  String shareFailed(String error) {
    return 'Sharing failed: $error';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get noPromptsToBackup => 'No prompts to back up';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count prompts',
      one: 'Restored 1 prompt',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get noContent => 'No content';

  @override
  String get noPromptsMatchFilters => 'No prompts match the filters';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noPrompts => 'No prompts';

  @override
  String get emptyStateMessage =>
      'Tap \"New prompt\" to create your first script to read on the teleprompter.';

  @override
  String get sortUpdatedDesc => 'Recently edited';

  @override
  String get sortUpdatedAsc => 'Least recently edited';

  @override
  String get sortTitleAsc => 'Title A→Z';

  @override
  String get sortTitleDesc => 'Title Z→A';

  @override
  String get sortCreatedDesc => 'Recently created';

  @override
  String get editPrompt => 'Edit prompt';

  @override
  String get markdownPreview => 'Markdown preview';

  @override
  String get hidePreview => 'Hide preview';

  @override
  String get save => 'Save';

  @override
  String get promptSaved => 'Prompt saved';

  @override
  String get titleHint => 'Title';

  @override
  String get voiceLanguage => 'Voice language:';

  @override
  String get editorPlaceholder => 'Write the prompt text here…';

  @override
  String get addTagHint => 'Add tag…';

  @override
  String get emptyMarkdownPreview => '_(empty)_';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemSubtitle => 'Follow the system';

  @override
  String get teleprompterDefaults => 'Teleprompter (defaults)';

  @override
  String get textSize => 'Text size';

  @override
  String get autoscrollSpeed => 'Autoscroll speed';

  @override
  String get readingLinePosition => 'Reading line position';

  @override
  String get decreaseText => 'Decrease text';

  @override
  String get increaseText => 'Increase text';

  @override
  String get restart => 'Restart';

  @override
  String get readingSettings => 'Reading settings';

  @override
  String get mirrorHorizontal => 'Horizontal mirror';

  @override
  String get mirrorHorizontalSubtitle => 'For the teleprompter glass';

  @override
  String get mirrorVertical => 'Vertical mirror';

  @override
  String get emptyPromptMessage =>
      'This prompt is empty. Edit it to add some text.';

  @override
  String get stop => 'Stop';

  @override
  String get startReading => 'Start reading';

  @override
  String get speechUnavailable =>
      'Speech recognition is unavailable on this device or microphone permission was denied.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0 · ~$time';
  }
}
