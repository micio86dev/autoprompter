// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Cerca nei prompt…';

  @override
  String get closeSearch => 'Chiudi ricerca';

  @override
  String get search => 'Cerca';

  @override
  String get sortTooltip => 'Ordina';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get importMarkdown => 'Importa Markdown…';

  @override
  String get backupData => 'Backup dati…';

  @override
  String get restoreBackup => 'Ripristina backup…';

  @override
  String get settings => 'Impostazioni';

  @override
  String get newPrompt => 'Nuovo prompt';

  @override
  String get moreActions => 'Altre azioni';

  @override
  String get openTeleprompter => 'Apri teleprompter';

  @override
  String get untitled => 'Senza titolo';

  @override
  String get edit => 'Modifica';

  @override
  String get duplicate => 'Duplica';

  @override
  String get shareMd => 'Condividi (.md)';

  @override
  String get delete => 'Elimina';

  @override
  String get cancel => 'Annulla';

  @override
  String get deletePromptTitle => 'Eliminare il prompt?';

  @override
  String deletePromptMessage(String title) {
    return 'Vuoi eliminare \"$title\"? L\'operazione non può essere annullata.';
  }

  @override
  String get promptDuplicated => 'Prompt duplicato';

  @override
  String get copySuffix => '(copia)';

  @override
  String shareFailed(String error) {
    return 'Condivisione non riuscita: $error';
  }

  @override
  String importFailed(String error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String get noPromptsToBackup => 'Nessun prompt da salvare';

  @override
  String backupFailed(String error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ripristinati $count prompt',
      one: 'Ripristinato 1 prompt',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Ripristino non riuscito: $error';
  }

  @override
  String get noContent => 'Nessun contenuto';

  @override
  String get noPromptsMatchFilters => 'Nessun prompt corrisponde ai filtri';

  @override
  String get clearFilters => 'Azzera i filtri';

  @override
  String get noPrompts => 'Nessun prompt';

  @override
  String get emptyStateMessage =>
      'Tocca \"Nuovo prompt\" per creare il tuo primo testo da leggere al teleprompter.';

  @override
  String get sortUpdatedDesc => 'Modificati di recente';

  @override
  String get sortUpdatedAsc => 'Modificati meno di recente';

  @override
  String get sortTitleAsc => 'Titolo A→Z';

  @override
  String get sortTitleDesc => 'Titolo Z→A';

  @override
  String get sortCreatedDesc => 'Creati di recente';

  @override
  String get editPrompt => 'Modifica prompt';

  @override
  String get markdownPreview => 'Anteprima Markdown';

  @override
  String get hidePreview => 'Nascondi anteprima';

  @override
  String get save => 'Salva';

  @override
  String get promptSaved => 'Prompt salvato';

  @override
  String get titleHint => 'Titolo';

  @override
  String get voiceLanguage => 'Lingua voce:';

  @override
  String get editorPlaceholder => 'Scrivi qui il testo del prompt…';

  @override
  String get addTagHint => 'Aggiungi tag…';

  @override
  String get emptyMarkdownPreview => '_(vuoto)_';

  @override
  String get appearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeSystemSubtitle => 'Segui il sistema';

  @override
  String get teleprompterDefaults => 'Teleprompter (valori predefiniti)';

  @override
  String get textSize => 'Dimensione testo';

  @override
  String get autoscrollSpeed => 'Velocità autoscroll';

  @override
  String get readingLinePosition => 'Posizione riga di lettura';

  @override
  String get decreaseText => 'Riduci testo';

  @override
  String get increaseText => 'Ingrandisci testo';

  @override
  String get restart => 'Ricomincia';

  @override
  String get readingSettings => 'Impostazioni lettura';

  @override
  String get mirrorHorizontal => 'Specchio orizzontale';

  @override
  String get mirrorHorizontalSubtitle => 'Per il vetro del teleprompter';

  @override
  String get mirrorVertical => 'Specchio verticale';

  @override
  String get emptyPromptMessage =>
      'Questo prompt è vuoto. Modificalo per aggiungere del testo.';

  @override
  String get stop => 'Ferma';

  @override
  String get startReading => 'Avvia lettura';

  @override
  String get speechUnavailable =>
      'Riconoscimento vocale non disponibile su questo dispositivo o permesso microfono negato.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parole',
      one: '1 parola',
    );
    return '$_temp0 · ~$time';
  }
}
