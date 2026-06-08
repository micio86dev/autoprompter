// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Buscar en los prompts…';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get search => 'Buscar';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get menuTooltip => 'Menú';

  @override
  String get importMarkdown => 'Importar Markdown…';

  @override
  String get backupData => 'Copia de seguridad…';

  @override
  String get restoreBackup => 'Restaurar copia…';

  @override
  String get settings => 'Ajustes';

  @override
  String get newPrompt => 'Nuevo prompt';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get openTeleprompter => 'Abrir teleprompter';

  @override
  String get untitled => 'Sin título';

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get shareMd => 'Compartir (.md)';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePromptTitle => '¿Eliminar el prompt?';

  @override
  String deletePromptMessage(String title) {
    return '¿Quieres eliminar \"$title\"? Esta acción no se puede deshacer.';
  }

  @override
  String get promptDuplicated => 'Prompt duplicado';

  @override
  String get copySuffix => '(copia)';

  @override
  String shareFailed(String error) {
    return 'No se pudo compartir: $error';
  }

  @override
  String importFailed(String error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get noPromptsToBackup => 'No hay prompts para guardar';

  @override
  String backupFailed(String error) {
    return 'Error en la copia de seguridad: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prompts restaurados',
      one: '1 prompt restaurado',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'No se pudo restaurar: $error';
  }

  @override
  String get noContent => 'Sin contenido';

  @override
  String get noPromptsMatchFilters => 'Ningún prompt coincide con los filtros';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get noPrompts => 'No hay prompts';

  @override
  String get emptyStateMessage =>
      'Toca \"Nuevo prompt\" para crear tu primer texto para leer en el teleprompter.';

  @override
  String get sortUpdatedDesc => 'Editados recientemente';

  @override
  String get sortUpdatedAsc => 'Editados hace más tiempo';

  @override
  String get sortTitleAsc => 'Título A→Z';

  @override
  String get sortTitleDesc => 'Título Z→A';

  @override
  String get sortCreatedDesc => 'Creados recientemente';

  @override
  String get editPrompt => 'Editar prompt';

  @override
  String get markdownPreview => 'Vista previa de Markdown';

  @override
  String get hidePreview => 'Ocultar vista previa';

  @override
  String get save => 'Guardar';

  @override
  String get promptSaved => 'Prompt guardado';

  @override
  String get titleHint => 'Título';

  @override
  String get voiceLanguage => 'Idioma de voz:';

  @override
  String get editorPlaceholder => 'Escribe aquí el texto del prompt…';

  @override
  String get addTagHint => 'Añadir etiqueta…';

  @override
  String get emptyMarkdownPreview => '_(vacío)_';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystemSubtitle => 'Seguir el sistema';

  @override
  String get teleprompterDefaults => 'Teleprompter (valores predeterminados)';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get autoscrollSpeed => 'Velocidad de autoavance';

  @override
  String get readingLinePosition => 'Posición de la línea de lectura';

  @override
  String get decreaseText => 'Reducir texto';

  @override
  String get increaseText => 'Aumentar texto';

  @override
  String get restart => 'Reiniciar';

  @override
  String get readingSettings => 'Ajustes de lectura';

  @override
  String get mirrorHorizontal => 'Espejo horizontal';

  @override
  String get mirrorHorizontalSubtitle => 'Para el cristal del teleprompter';

  @override
  String get mirrorVertical => 'Espejo vertical';

  @override
  String get emptyPromptMessage =>
      'Este prompt está vacío. Edítalo para añadir texto.';

  @override
  String get stop => 'Detener';

  @override
  String get startReading => 'Iniciar lectura';

  @override
  String get speechUnavailable =>
      'El reconocimiento de voz no está disponible en este dispositivo o se ha denegado el permiso del micrófono.';

  @override
  String get micPermissionTitle => 'Acceso al micrófono';

  @override
  String get micPermissionRationale =>
      'Autoprompter usa el micrófono para seguir tu voz y desplazar el texto automáticamente. El audio se procesa en tu dispositivo para el reconocimiento de voz: no se graba ni se comparte.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get micPermissionDenied =>
      'Permiso de micrófono denegado. Actívalo en Ajustes para usar el desplazamiento por voz.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palabras',
      one: '1 palabra',
    );
    return '$_temp0 · ~$time';
  }
}
