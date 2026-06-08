// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Pesquisar nos prompts…';

  @override
  String get closeSearch => 'Fechar pesquisa';

  @override
  String get search => 'Pesquisar';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get menuTooltip => 'Menu';

  @override
  String get importMarkdown => 'Importar Markdown…';

  @override
  String get backupData => 'Backup dos dados…';

  @override
  String get restoreBackup => 'Restaurar backup…';

  @override
  String get settings => 'Configurações';

  @override
  String get newPrompt => 'Novo prompt';

  @override
  String get moreActions => 'Mais ações';

  @override
  String get openTeleprompter => 'Abrir teleprompter';

  @override
  String get untitled => 'Sem título';

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get shareMd => 'Compartilhar (.md)';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deletePromptTitle => 'Excluir o prompt?';

  @override
  String deletePromptMessage(String title) {
    return 'Deseja excluir \"$title\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get promptDuplicated => 'Prompt duplicado';

  @override
  String get copySuffix => '(cópia)';

  @override
  String shareFailed(String error) {
    return 'Falha ao compartilhar: $error';
  }

  @override
  String importFailed(String error) {
    return 'Falha ao importar: $error';
  }

  @override
  String get noPromptsToBackup => 'Nenhum prompt para salvar';

  @override
  String backupFailed(String error) {
    return 'Falha no backup: $error';
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
    return 'Falha ao restaurar: $error';
  }

  @override
  String get noContent => 'Sem conteúdo';

  @override
  String get noPromptsMatchFilters => 'Nenhum prompt corresponde aos filtros';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get noPrompts => 'Nenhum prompt';

  @override
  String get emptyStateMessage =>
      'Toque em \"Novo prompt\" para criar seu primeiro texto para ler no teleprompter.';

  @override
  String get sortUpdatedDesc => 'Editados recentemente';

  @override
  String get sortUpdatedAsc => 'Editados há mais tempo';

  @override
  String get sortTitleAsc => 'Título A→Z';

  @override
  String get sortTitleDesc => 'Título Z→A';

  @override
  String get sortCreatedDesc => 'Criados recentemente';

  @override
  String get editPrompt => 'Editar prompt';

  @override
  String get markdownPreview => 'Pré-visualização do Markdown';

  @override
  String get hidePreview => 'Ocultar pré-visualização';

  @override
  String get save => 'Salvar';

  @override
  String get promptSaved => 'Prompt salvo';

  @override
  String get titleHint => 'Título';

  @override
  String get voiceLanguage => 'Idioma da voz:';

  @override
  String get editorPlaceholder => 'Escreva aqui o texto do prompt…';

  @override
  String get addTagHint => 'Adicionar tag…';

  @override
  String get emptyMarkdownPreview => '_(vazio)_';

  @override
  String get appearance => 'Aparência';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeSystemSubtitle => 'Seguir o sistema';

  @override
  String get teleprompterDefaults => 'Teleprompter (valores padrão)';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get autoscrollSpeed => 'Velocidade da rolagem automática';

  @override
  String get readingLinePosition => 'Posição da linha de leitura';

  @override
  String get decreaseText => 'Diminuir texto';

  @override
  String get increaseText => 'Aumentar texto';

  @override
  String get restart => 'Reiniciar';

  @override
  String get readingSettings => 'Configurações de leitura';

  @override
  String get mirrorHorizontal => 'Espelho horizontal';

  @override
  String get mirrorHorizontalSubtitle => 'Para o vidro do teleprompter';

  @override
  String get mirrorVertical => 'Espelho vertical';

  @override
  String get emptyPromptMessage =>
      'Este prompt está vazio. Edite-o para adicionar texto.';

  @override
  String get stop => 'Parar';

  @override
  String get startReading => 'Iniciar leitura';

  @override
  String get speechUnavailable =>
      'O reconhecimento de voz não está disponível neste dispositivo ou a permissão do microfone foi negada.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palavras',
      one: '1 palavra',
    );
    return '$_temp0 · ~$time';
  }
}
