// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Autoprompter';

  @override
  String get searchPromptsHint => '搜索提示词…';

  @override
  String get closeSearch => '关闭搜索';

  @override
  String get search => '搜索';

  @override
  String get sortTooltip => '排序';

  @override
  String get menuTooltip => '菜单';

  @override
  String get importMarkdown => '导入 Markdown…';

  @override
  String get backupData => '备份数据…';

  @override
  String get restoreBackup => '恢复备份…';

  @override
  String get settings => '设置';

  @override
  String get newPrompt => '新建提示词';

  @override
  String get moreActions => '更多操作';

  @override
  String get openTeleprompter => '打开提词器';

  @override
  String get untitled => '无标题';

  @override
  String get edit => '编辑';

  @override
  String get duplicate => '复制';

  @override
  String get shareMd => '分享 (.md)';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get deletePromptTitle => '删除提示词？';

  @override
  String deletePromptMessage(String title) {
    return '要删除“$title”吗？此操作无法撤销。';
  }

  @override
  String get promptDuplicated => '提示词已复制';

  @override
  String get copySuffix => '（副本）';

  @override
  String shareFailed(String error) {
    return '分享失败：$error';
  }

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get noPromptsToBackup => '没有可备份的提示词';

  @override
  String backupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String promptsRestored(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已恢复 $count 个提示词',
    );
    return '$_temp0';
  }

  @override
  String restoreFailed(String error) {
    return '恢复失败：$error';
  }

  @override
  String get noContent => '无内容';

  @override
  String get noPromptsMatchFilters => '没有符合筛选条件的提示词';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get noPrompts => '没有提示词';

  @override
  String get emptyStateMessage => '点按“新建提示词”，创建你要在提词器上朗读的第一段文字。';

  @override
  String get sortUpdatedDesc => '最近编辑';

  @override
  String get sortUpdatedAsc => '最早编辑';

  @override
  String get sortTitleAsc => '标题 A→Z';

  @override
  String get sortTitleDesc => '标题 Z→A';

  @override
  String get sortCreatedDesc => '最近创建';

  @override
  String get editPrompt => '编辑提示词';

  @override
  String get markdownPreview => 'Markdown 预览';

  @override
  String get hidePreview => '隐藏预览';

  @override
  String get save => '保存';

  @override
  String get promptSaved => '提示词已保存';

  @override
  String get titleHint => '标题';

  @override
  String get voiceLanguage => '语音语言：';

  @override
  String get editorPlaceholder => '在此输入提示词内容…';

  @override
  String get addTagHint => '添加标签…';

  @override
  String get emptyMarkdownPreview => '_(空)_';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystemSubtitle => '跟随系统';

  @override
  String get teleprompterDefaults => '提词器（默认值）';

  @override
  String get textSize => '文字大小';

  @override
  String get autoscrollSpeed => '自动滚动速度';

  @override
  String get readingLinePosition => '阅读行位置';

  @override
  String get decreaseText => '缩小文字';

  @override
  String get increaseText => '放大文字';

  @override
  String get restart => '重新开始';

  @override
  String get readingSettings => '阅读设置';

  @override
  String get mirrorHorizontal => '水平镜像';

  @override
  String get mirrorHorizontalSubtitle => '用于提词器镜面';

  @override
  String get mirrorVertical => '垂直镜像';

  @override
  String get emptyPromptMessage => '此提示词为空。请编辑以添加文字。';

  @override
  String get stop => '停止';

  @override
  String get startReading => '开始朗读';

  @override
  String get speechUnavailable => '此设备不支持语音识别，或麦克风权限被拒绝。';

  @override
  String readingStatsLabel(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个词',
    );
    return '$_temp0 · ~$time';
  }
}
