// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => 'プロンプトを検索…';

  @override
  String get closeSearch => '検索を閉じる';

  @override
  String get search => '検索';

  @override
  String get sortTooltip => '並べ替え';

  @override
  String get menuTooltip => 'メニュー';

  @override
  String get importMarkdown => 'Markdown をインポート…';

  @override
  String get backupData => 'データをバックアップ…';

  @override
  String get restoreBackup => 'バックアップを復元…';

  @override
  String get settings => '設定';

  @override
  String get newPrompt => '新しいプロンプト';

  @override
  String get moreActions => 'その他の操作';

  @override
  String get openTeleprompter => 'テレプロンプターを開く';

  @override
  String get untitled => '無題';

  @override
  String get edit => '編集';

  @override
  String get duplicate => '複製';

  @override
  String get shareMd => '共有 (.md)';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get deletePromptTitle => 'プロンプトを削除しますか？';

  @override
  String deletePromptMessage(String title) {
    return '「$title」を削除しますか？この操作は取り消せません。';
  }

  @override
  String get promptDuplicated => 'プロンプトを複製しました';

  @override
  String get copySuffix => '（コピー）';

  @override
  String shareFailed(String error) {
    return '共有に失敗しました: $error';
  }

  @override
  String importFailed(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get noPromptsToBackup => 'バックアップするプロンプトがありません';

  @override
  String backupFailed(String error) {
    return 'バックアップに失敗しました: $error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のプロンプトを復元しました',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return '復元に失敗しました: $error';
  }

  @override
  String get noContent => '内容なし';

  @override
  String get noPromptsMatchFilters => 'フィルターに一致するプロンプトがありません';

  @override
  String get clearFilters => 'フィルターをクリア';

  @override
  String get noPrompts => 'プロンプトがありません';

  @override
  String get emptyStateMessage =>
      '「新しいプロンプト」をタップして、テレプロンプターで読む最初のテキストを作成しましょう。';

  @override
  String get sortUpdatedDesc => '最近編集した順';

  @override
  String get sortUpdatedAsc => '編集が古い順';

  @override
  String get sortTitleAsc => 'タイトル A→Z';

  @override
  String get sortTitleDesc => 'タイトル Z→A';

  @override
  String get sortCreatedDesc => '最近作成した順';

  @override
  String get editPrompt => 'プロンプトを編集';

  @override
  String get markdownPreview => 'Markdown プレビュー';

  @override
  String get hidePreview => 'プレビューを隠す';

  @override
  String get save => '保存';

  @override
  String get promptSaved => 'プロンプトを保存しました';

  @override
  String get titleHint => 'タイトル';

  @override
  String get voiceLanguage => '音声の言語:';

  @override
  String get editorPlaceholder => 'ここにプロンプトのテキストを入力…';

  @override
  String get addTagHint => 'タグを追加…';

  @override
  String get emptyMarkdownPreview => '_(空)_';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystemSubtitle => 'システムに合わせる';

  @override
  String get teleprompterDefaults => 'テレプロンプター（既定値）';

  @override
  String get textSize => '文字サイズ';

  @override
  String get autoscrollSpeed => '自動スクロール速度';

  @override
  String get readingLinePosition => '読み取り行の位置';

  @override
  String get decreaseText => '文字を小さく';

  @override
  String get increaseText => '文字を大きく';

  @override
  String get restart => '最初から';

  @override
  String get readingSettings => '読み上げ設定';

  @override
  String get mirrorHorizontal => '左右反転';

  @override
  String get mirrorHorizontalSubtitle => 'テレプロンプターのガラス用';

  @override
  String get mirrorVertical => '上下反転';

  @override
  String get emptyPromptMessage => 'このプロンプトは空です。編集してテキストを追加してください。';

  @override
  String get stop => '停止';

  @override
  String get startReading => '読み上げを開始';

  @override
  String get speechUnavailable => 'この端末では音声認識を利用できないか、マイクの権限が拒否されています。';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 語',
    );
    return '$_temp0 · ~$time';
  }
}
