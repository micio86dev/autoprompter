// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'Поиск по промптам…';

  @override
  String get closeSearch => 'Закрыть поиск';

  @override
  String get search => 'Поиск';

  @override
  String get sortTooltip => 'Сортировка';

  @override
  String get menuTooltip => 'Меню';

  @override
  String get importMarkdown => 'Импорт Markdown…';

  @override
  String get backupData => 'Резервная копия данных…';

  @override
  String get restoreBackup => 'Восстановить из копии…';

  @override
  String get settings => 'Настройки';

  @override
  String get newPrompt => 'Новый промпт';

  @override
  String get moreActions => 'Другие действия';

  @override
  String get openTeleprompter => 'Открыть телесуфлёр';

  @override
  String get untitled => 'Без названия';

  @override
  String get edit => 'Изменить';

  @override
  String get duplicate => 'Дублировать';

  @override
  String get shareMd => 'Поделиться (.md)';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get deletePromptTitle => 'Удалить промпт?';

  @override
  String deletePromptMessage(String title) {
    return 'Удалить «$title»? Это действие нельзя отменить.';
  }

  @override
  String get promptDuplicated => 'Промпт дублирован';

  @override
  String get copySuffix => '(копия)';

  @override
  String shareFailed(String error) {
    return 'Не удалось поделиться: $error';
  }

  @override
  String importFailed(String error) {
    return 'Не удалось импортировать: $error';
  }

  @override
  String get noPromptsToBackup => 'Нет промптов для сохранения';

  @override
  String backupFailed(String error) {
    return 'Не удалось создать резервную копию: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Восстановлено $count промптов',
      many: 'Восстановлено $count промптов',
      few: 'Восстановлено $count промпта',
      one: 'Восстановлен $count промпт',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return 'Не удалось восстановить: $error';
  }

  @override
  String get noContent => 'Нет содержимого';

  @override
  String get noPromptsMatchFilters => 'Нет промптов, соответствующих фильтрам';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get noPrompts => 'Нет промптов';

  @override
  String get emptyStateMessage =>
      'Нажмите «Новый промпт», чтобы создать первый текст для чтения на телесуфлёре.';

  @override
  String get sortUpdatedDesc => 'Недавно изменённые';

  @override
  String get sortUpdatedAsc => 'Давно изменённые';

  @override
  String get sortTitleAsc => 'Название А→Я';

  @override
  String get sortTitleDesc => 'Название Я→А';

  @override
  String get sortCreatedDesc => 'Недавно созданные';

  @override
  String get editPrompt => 'Изменить промпт';

  @override
  String get markdownPreview => 'Предпросмотр Markdown';

  @override
  String get hidePreview => 'Скрыть предпросмотр';

  @override
  String get save => 'Сохранить';

  @override
  String get promptSaved => 'Промпт сохранён';

  @override
  String get titleHint => 'Название';

  @override
  String get voiceLanguage => 'Язык голоса:';

  @override
  String get editorPlaceholder => 'Введите здесь текст промпта…';

  @override
  String get addTagHint => 'Добавить тег…';

  @override
  String get emptyMarkdownPreview => '_(пусто)_';

  @override
  String get appearance => 'Оформление';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystemSubtitle => 'Как в системе';

  @override
  String get teleprompterDefaults => 'Телесуфлёр (значения по умолчанию)';

  @override
  String get textSize => 'Размер текста';

  @override
  String get autoscrollSpeed => 'Скорость автопрокрутки';

  @override
  String get readingLinePosition => 'Положение линии чтения';

  @override
  String get decreaseText => 'Уменьшить текст';

  @override
  String get increaseText => 'Увеличить текст';

  @override
  String get restart => 'Заново';

  @override
  String get readingSettings => 'Настройки чтения';

  @override
  String get mirrorHorizontal => 'Горизонтальное зеркало';

  @override
  String get mirrorHorizontalSubtitle => 'Для стекла телесуфлёра';

  @override
  String get mirrorVertical => 'Вертикальное зеркало';

  @override
  String get emptyPromptMessage =>
      'Этот промпт пуст. Измените его, чтобы добавить текст.';

  @override
  String get stop => 'Стоп';

  @override
  String get startReading => 'Начать чтение';

  @override
  String get speechUnavailable =>
      'Распознавание речи недоступно на этом устройстве или нет доступа к микрофону.';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слов',
      many: '$count слов',
      few: '$count слова',
      one: '$count слово',
    );
    return '$_temp0 · ~$time';
  }
}
