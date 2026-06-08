// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Rechercher dans les prompts…';

  @override
  String get closeSearch => 'Fermer la recherche';

  @override
  String get search => 'Rechercher';

  @override
  String get sortTooltip => 'Trier';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get importMarkdown => 'Importer du Markdown…';

  @override
  String get backupData => 'Sauvegarder les données…';

  @override
  String get restoreBackup => 'Restaurer une sauvegarde…';

  @override
  String get settings => 'Paramètres';

  @override
  String get newPrompt => 'Nouveau prompt';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get openTeleprompter => 'Ouvrir le téléprompteur';

  @override
  String get untitled => 'Sans titre';

  @override
  String get edit => 'Modifier';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get shareMd => 'Partager (.md)';

  @override
  String get delete => 'Supprimer';

  @override
  String get cancel => 'Annuler';

  @override
  String get deletePromptTitle => 'Supprimer le prompt ?';

  @override
  String deletePromptMessage(String title) {
    return 'Voulez-vous supprimer « $title » ? Cette action est irréversible.';
  }

  @override
  String get promptDuplicated => 'Prompt dupliqué';

  @override
  String get copySuffix => '(copie)';

  @override
  String shareFailed(String error) {
    return 'Échec du partage : $error';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get noPromptsToBackup => 'Aucun prompt à sauvegarder';

  @override
  String backupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prompts restaurés',
      one: '1 prompt restauré',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get noContent => 'Aucun contenu';

  @override
  String get noPromptsMatchFilters => 'Aucun prompt ne correspond aux filtres';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get noPrompts => 'Aucun prompt';

  @override
  String get emptyStateMessage =>
      'Touchez « Nouveau prompt » pour créer votre premier texte à lire au téléprompteur.';

  @override
  String get sortUpdatedDesc => 'Modifiés récemment';

  @override
  String get sortUpdatedAsc => 'Modifiés il y a longtemps';

  @override
  String get sortTitleAsc => 'Titre A→Z';

  @override
  String get sortTitleDesc => 'Titre Z→A';

  @override
  String get sortCreatedDesc => 'Créés récemment';

  @override
  String get editPrompt => 'Modifier le prompt';

  @override
  String get markdownPreview => 'Aperçu du Markdown';

  @override
  String get hidePreview => 'Masquer l\'aperçu';

  @override
  String get save => 'Enregistrer';

  @override
  String get promptSaved => 'Prompt enregistré';

  @override
  String get titleHint => 'Titre';

  @override
  String get voiceLanguage => 'Langue de la voix :';

  @override
  String get editorPlaceholder => 'Écrivez ici le texte du prompt…';

  @override
  String get addTagHint => 'Ajouter une étiquette…';

  @override
  String get emptyMarkdownPreview => '_(vide)_';

  @override
  String get appearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystemSubtitle => 'Suivre le système';

  @override
  String get teleprompterDefaults => 'Téléprompteur (valeurs par défaut)';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get autoscrollSpeed => 'Vitesse de défilement';

  @override
  String get readingLinePosition => 'Position de la ligne de lecture';

  @override
  String get decreaseText => 'Réduire le texte';

  @override
  String get increaseText => 'Agrandir le texte';

  @override
  String get restart => 'Recommencer';

  @override
  String get readingSettings => 'Paramètres de lecture';

  @override
  String get mirrorHorizontal => 'Miroir horizontal';

  @override
  String get mirrorHorizontalSubtitle => 'Pour la vitre du téléprompteur';

  @override
  String get mirrorVertical => 'Miroir vertical';

  @override
  String get emptyPromptMessage =>
      'Ce prompt est vide. Modifiez-le pour ajouter du texte.';

  @override
  String get stop => 'Arrêter';

  @override
  String get startReading => 'Démarrer la lecture';

  @override
  String get speechUnavailable =>
      'La reconnaissance vocale n\'est pas disponible sur cet appareil ou l\'autorisation du microphone a été refusée.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mots',
      one: '1 mot',
    );
    return '$_temp0 · ~$time';
  }
}
