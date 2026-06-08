// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Prompts durchsuchen…';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get search => 'Suchen';

  @override
  String get sortTooltip => 'Sortieren';

  @override
  String get menuTooltip => 'Menü';

  @override
  String get importMarkdown => 'Markdown importieren…';

  @override
  String get backupData => 'Daten sichern…';

  @override
  String get restoreBackup => 'Backup wiederherstellen…';

  @override
  String get settings => 'Einstellungen';

  @override
  String get newPrompt => 'Neuer Prompt';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get openTeleprompter => 'Teleprompter öffnen';

  @override
  String get untitled => 'Ohne Titel';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get duplicate => 'Duplizieren';

  @override
  String get shareMd => 'Teilen (.md)';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deletePromptTitle => 'Prompt löschen?';

  @override
  String deletePromptMessage(String title) {
    return 'Möchtest du \"$title\" löschen? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get promptDuplicated => 'Prompt dupliziert';

  @override
  String get copySuffix => '(Kopie)';

  @override
  String shareFailed(String error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get noPromptsToBackup => 'Keine Prompts zum Sichern';

  @override
  String backupFailed(String error) {
    return 'Backup fehlgeschlagen: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Prompts wiederhergestellt',
      one: '1 Prompt wiederhergestellt',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get noContent => 'Kein Inhalt';

  @override
  String get noPromptsMatchFilters => 'Keine Prompts entsprechen den Filtern';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get noPrompts => 'Keine Prompts';

  @override
  String get emptyStateMessage =>
      'Tippe auf \"Neuer Prompt\", um deinen ersten Text zum Vorlesen am Teleprompter zu erstellen.';

  @override
  String get sortUpdatedDesc => 'Zuletzt bearbeitet';

  @override
  String get sortUpdatedAsc => 'Am längsten nicht bearbeitet';

  @override
  String get sortTitleAsc => 'Titel A→Z';

  @override
  String get sortTitleDesc => 'Titel Z→A';

  @override
  String get sortCreatedDesc => 'Zuletzt erstellt';

  @override
  String get editPrompt => 'Prompt bearbeiten';

  @override
  String get markdownPreview => 'Markdown-Vorschau';

  @override
  String get hidePreview => 'Vorschau ausblenden';

  @override
  String get save => 'Speichern';

  @override
  String get promptSaved => 'Prompt gespeichert';

  @override
  String get titleHint => 'Titel';

  @override
  String get voiceLanguage => 'Sprache der Stimme:';

  @override
  String get editorPlaceholder => 'Schreibe hier den Text des Prompts…';

  @override
  String get addTagHint => 'Tag hinzufügen…';

  @override
  String get emptyMarkdownPreview => '_(leer)_';

  @override
  String get appearance => 'Darstellung';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSystemSubtitle => 'System folgen';

  @override
  String get teleprompterDefaults => 'Teleprompter (Standardwerte)';

  @override
  String get textSize => 'Textgröße';

  @override
  String get autoscrollSpeed => 'Autoscroll-Geschwindigkeit';

  @override
  String get readingLinePosition => 'Position der Leselinie';

  @override
  String get decreaseText => 'Text verkleinern';

  @override
  String get increaseText => 'Text vergrößern';

  @override
  String get restart => 'Neu starten';

  @override
  String get readingSettings => 'Leseeinstellungen';

  @override
  String get mirrorHorizontal => 'Horizontal spiegeln';

  @override
  String get mirrorHorizontalSubtitle => 'Für das Teleprompter-Glas';

  @override
  String get mirrorVertical => 'Vertikal spiegeln';

  @override
  String get emptyPromptMessage =>
      'Dieser Prompt ist leer. Bearbeite ihn, um Text hinzuzufügen.';

  @override
  String get stop => 'Stopp';

  @override
  String get startReading => 'Lesen starten';

  @override
  String get speechUnavailable =>
      'Die Spracherkennung ist auf diesem Gerät nicht verfügbar oder die Mikrofonberechtigung wurde verweigert.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wörter',
      one: '1 Wort',
    );
    return '$_temp0 · ~$time';
  }
}
