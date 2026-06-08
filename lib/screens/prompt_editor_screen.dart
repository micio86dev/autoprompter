import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/prompt.dart';
import '../services/markdown_service.dart';
import '../services/reading_stats.dart';
import '../services/speech_service.dart';
import '../state/prompt_store.dart';
import 'teleprompter_screen.dart';

/// Languages offered by default when the device exposes none (e.g. desktop).
const List<SpeechLocale> _fallbackLocales = [
  SpeechLocale('it_IT', 'Italian (Italy)'),
  SpeechLocale('en_US', 'English (US)'),
  SpeechLocale('en_GB', 'English (UK)'),
  SpeechLocale('es_ES', 'Spanish (Spain)'),
  SpeechLocale('fr_FR', 'French (France)'),
  SpeechLocale('de_DE', 'German (Germany)'),
  SpeechLocale('pt_PT', 'Portuguese (Portugal)'),
];

/// Width above which the editor and Markdown preview sit side by side.
const double _splitBreakpoint = 720;

class PromptEditorScreen extends StatefulWidget {
  const PromptEditorScreen({super.key, required this.prompt, this.speech});

  /// The prompt to edit (use [Prompt.create] for a new one).
  final Prompt prompt;

  /// Injectable in tests to list languages; defaults to the real recognizer.
  final SpeechService? speech;

  @override
  State<PromptEditorScreen> createState() => _PromptEditorScreenState();
}

class _PromptEditorScreenState extends State<PromptEditorScreen> {
  late final TextEditingController _titleController;
  final TextEditingController _tagController = TextEditingController();
  late final QuillController _quillController;
  late String _localeId;
  late List<String> _tags;

  List<SpeechLocale> _locales = _fallbackLocales;
  bool _saving = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prompt.title);
    _localeId = widget.prompt.localeId;
    _tags = List.of(widget.prompt.tags);
    final doc = MarkdownService.documentFromMarkdown(widget.prompt.contentMarkdown);
    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
    // Update statistics and preview while typing.
    _quillController.addListener(_onDocChanged);
    _loadLocales();
  }

  void _onDocChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadLocales() async {
    final fetched = await (widget.speech ?? SttSpeechService()).locales();
    if (!mounted) return;
    final merged = <String, SpeechLocale>{
      for (final l in _fallbackLocales) l.id: l,
      for (final l in fetched) l.id: l,
    };
    // Ensure the selected language is present in the list.
    merged.putIfAbsent(_localeId, () => SpeechLocale(_localeId, _localeId));
    final list = merged.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    setState(() => _locales = list);
  }

  @override
  void dispose() {
    _quillController.removeListener(_onDocChanged);
    _titleController.dispose();
    _tagController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  String _currentMarkdown() =>
      MarkdownService.deltaToMarkdown(_quillController.document.toDelta());

  Prompt _buildPrompt() {
    return widget.prompt.copyWith(
      title: _titleController.text.trim(),
      contentMarkdown: _currentMarkdown(),
      localeId: _localeId,
      tags: Prompt.normalizeTags(_tags),
    );
  }

  Future<Prompt> _save() async {
    setState(() => _saving = true);
    final store = context.read<PromptStore>();
    final saved = await store.save(_buildPrompt());
    if (mounted) setState(() => _saving = false);
    return saved;
  }

  Future<void> _onSavePressed() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await _save();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.promptSaved)),
    );
    navigator.pop();
  }

  Future<void> _openTeleprompter() async {
    final navigator = Navigator.of(context);
    final saved = await _save();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => TeleprompterScreen(prompt: saved),
      ),
    );
  }

  void _addTagsFromInput(String raw) {
    final added = raw.split(',');
    if (added.every((t) => t.trim().isEmpty)) return;
    setState(() {
      _tags = Prompt.normalizeTags([..._tags, ...added]);
      _tagController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() => _tags = _tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats =
        ReadingStats.fromPlainText(_quillController.document.toPlainText());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _save();
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editPrompt),
          actions: [
            IconButton(
              tooltip: _showPreview ? l10n.hidePreview : l10n.markdownPreview,
              icon: Icon(_showPreview ? Icons.code_off : Icons.code),
              onPressed: () => setState(() => _showPreview = !_showPreview),
            ),
            IconButton(
              tooltip: l10n.openTeleprompter,
              icon: const Icon(Icons.play_circle_fill),
              onPressed: _saving ? null : _openTeleprompter,
            ),
            IconButton(
              tooltip: l10n.save,
              icon: const Icon(Icons.check),
              onPressed: _saving ? null : _onSavePressed,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: l10n.titleHint,
                  border: InputBorder.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.mic, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.voiceLanguage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _localeId,
                      items: _locales
                          .map((l) => DropdownMenuItem(
                                value: l.id,
                                child: Text(l.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _localeId = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            _TagEditor(
              tags: _tags,
              controller: _tagController,
              onSubmit: _addTagsFromInput,
              onRemove: _removeTag,
            ),
            const Divider(height: 1),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showHeaderStyle: true,
                showListBullets: true,
                showListNumbers: true,
                showQuote: true,
                showLink: true,
                showInlineCode: true,
                showCodeBlock: true,
                showUndo: true,
                showRedo: true,
                showUnderLineButton: false,
                showStrikeThrough: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showFontFamily: false,
                showFontSize: false,
                showSmallButton: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showListCheck: false,
                showIndent: false,
                showAlignmentButtons: false,
                showLeftAlignment: false,
                showCenterAlignment: false,
                showRightAlignment: false,
                showJustifyAlignment: false,
                showDirection: false,
                showDividers: false,
                showLineHeightButton: false,
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildBody()),
            _StatsBar(stats: stats),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    final editor = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: QuillEditor.basic(
        controller: _quillController,
        config: QuillEditorConfig(
          placeholder: l10n.editorPlaceholder,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );

    if (!_showPreview) return editor;

    final preview = _MarkdownPreview(markdown: _currentMarkdown());
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _splitBreakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: editor),
              const VerticalDivider(width: 1),
              Expanded(child: preview),
            ],
          );
        }
        // On narrow screens the preview replaces the editor.
        return preview;
      },
    );
  }
}

/// Tag editor: removable chips + a field to add more (comma or enter).
class _TagEditor extends StatelessWidget {
  const _TagEditor({
    required this.tags,
    required this.controller,
    required this.onSubmit,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.label_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in tags)
                  InputChip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () => onRemove(tag),
                  ),
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: l10n.addTagHint,
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      if (value.endsWith(',')) onSubmit(value);
                    },
                    onSubmitted: onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Preview of the generated Markdown source (read-only, monospace).
class _MarkdownPreview extends StatelessWidget {
  const _MarkdownPreview({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: SelectableText(
          markdown.isEmpty ? l10n.emptyMarkdownPreview : markdown,
          style: const TextStyle(fontFamily: 'monospace', height: 1.4),
        ),
      ),
    );
  }
}

/// Bottom bar with word count and estimated reading time.
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.timer_outlined,
                size: 16, color: Theme.of(context).hintColor),
            const SizedBox(width: 6),
            Text(
              l10n.readingStatsLabel(stats.wordCount, stats.durationLabel),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
