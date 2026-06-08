import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/prompt.dart';
import '../services/data_service.dart';
import '../services/markdown_service.dart';
import '../state/prompt_store.dart';
import '../state/settings_store.dart';
import 'prompt_editor_screen.dart';
import 'settings_screen.dart';
import 'teleprompter_screen.dart';

/// The localized label for a [PromptSort] value.
String sortLabel(AppLocalizations l10n, PromptSort sort) => switch (sort) {
      PromptSort.updatedDesc => l10n.sortUpdatedDesc,
      PromptSort.updatedAsc => l10n.sortUpdatedAsc,
      PromptSort.titleAsc => l10n.sortTitleAsc,
      PromptSort.titleDesc => l10n.sortTitleDesc,
      PromptSort.createdDesc => l10n.sortCreatedDesc,
    };

/// Main screen: list of saved prompts, with search, sorting and tag filtering.
class PromptListScreen extends StatefulWidget {
  const PromptListScreen({super.key});

  @override
  State<PromptListScreen> createState() => _PromptListScreenState();
}

class _PromptListScreenState extends State<PromptListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromptStore>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEditor(Prompt prompt) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PromptEditorScreen(prompt: prompt)),
    );
  }

  void _openTeleprompter(Prompt prompt) {
    final settings = context.read<SettingsStore>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeleprompterScreen(
          prompt: prompt,
          initialFontSize: settings.defaultFontSize,
          initialScrollSpeed: settings.defaultScrollSpeed,
          initialReadingLine: settings.defaultReadingLine,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _onMenuSelected(String value, PromptStore store) async {
    switch (value) {
      case 'settings':
        _openSettings();
      case 'import':
        await _importMarkdown(store);
      case 'backup':
        await _backup(store);
      case 'restore':
        await _restore(store);
    }
  }

  Future<void> _confirmDelete(Prompt prompt) async {
    final l10n = AppLocalizations.of(context);
    final store = context.read<PromptStore>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deletePromptTitle),
        content: Text(
          l10n.deletePromptMessage(
            prompt.title.isEmpty ? l10n.untitled : prompt.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.delete(prompt.id);
    }
  }

  Future<void> _duplicate(Prompt prompt) async {
    final l10n = AppLocalizations.of(context);
    final store = context.read<PromptStore>();
    final messenger = ScaffoldMessenger.of(context);
    await store.duplicate(
      prompt,
      copySuffix: l10n.copySuffix,
      untitledLabel: l10n.untitled,
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.promptDuplicated)));
  }

  Future<void> _share(Prompt prompt) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DataService.instance.sharePrompt(prompt);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.shareFailed('$e'))),
      );
    }
  }

  Future<void> _importMarkdown(PromptStore store) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final prompt = await DataService.instance.importMarkdown();
      if (prompt == null) return;
      final saved = await store.save(prompt);
      if (!mounted) return;
      _openEditor(saved);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importFailed('$e'))),
      );
    }
  }

  Future<void> _backup(PromptStore store) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (store.prompts.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noPromptsToBackup)),
      );
      return;
    }
    try {
      await DataService.instance.backup(store.prompts);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupFailed('$e'))),
      );
    }
  }

  Future<void> _restore(PromptStore store) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await DataService.instance.restore();
      if (result == null) return;
      final n = await store.restore(result.prompts);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.promptsRestored(n))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.restoreFailed('$e'))),
      );
    }
  }

  void _showActions(Prompt prompt) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                prompt.title.isEmpty ? l10n.untitled : prompt.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.of(ctx).pop();
                _openEditor(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: Text(l10n.openTeleprompter),
              onTap: () {
                Navigator.of(ctx).pop();
                _openTeleprompter(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l10n.duplicate),
              onTap: () {
                Navigator.of(ctx).pop();
                _duplicate(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.shareMd),
              onTap: () {
                Navigator.of(ctx).pop();
                _share(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(prompt);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _preview(Prompt prompt) {
    final plain = MarkdownService.markdownToPlainText(prompt.contentMarkdown)
        .replaceAll('\n', ' ')
        .trim();
    if (plain.isEmpty) return AppLocalizations.of(context).noContent;
    return plain.length > 100 ? '${plain.substring(0, 100)}…' : plain;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = context.watch<PromptStore>();
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchPromptsHint,
                  border: InputBorder.none,
                ),
                onChanged: store.setQuery,
              )
            : Text(l10n.appTitle),
        actions: [
          if (_searching)
            IconButton(
              tooltip: l10n.closeSearch,
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                store.setQuery('');
                setState(() => _searching = false);
              },
            )
          else
            IconButton(
              tooltip: l10n.search,
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
          PopupMenuButton<PromptSort>(
            tooltip: l10n.sortTooltip,
            icon: const Icon(Icons.sort),
            initialValue: store.sort,
            onSelected: store.setSort,
            itemBuilder: (_) => [
              for (final s in PromptSort.values)
                PopupMenuItem(value: s, child: Text(sortLabel(l10n, s))),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: l10n.menuTooltip,
            onSelected: (value) => _onMenuSelected(value, store),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'import', child: Text(l10n.importMarkdown)),
              PopupMenuItem(value: 'backup', child: Text(l10n.backupData)),
              PopupMenuItem(value: 'restore', child: Text(l10n.restoreBackup)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _TagFilterBar(store: store),
          Expanded(child: _buildList(store)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(Prompt.create()),
        icon: const Icon(Icons.add),
        label: Text(l10n.newPrompt),
      ),
    );
  }

  Widget _buildList(PromptStore store) {
    final l10n = AppLocalizations.of(context);
    if (store.loading && store.prompts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.prompts.isEmpty) {
      return const _EmptyState();
    }
    final items = store.visiblePrompts;
    if (items.isEmpty) {
      return _NoResults(onClear: () {
        _searchController.clear();
        setState(() => _searching = false);
        store.clearFilters();
      });
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final prompt = items[index];
        return Dismissible(
          key: ValueKey(prompt.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            await _confirmDelete(prompt);
            return false; // deletion is handled by the store
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(
              prompt.title.isEmpty ? l10n.untitled : prompt.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _preview(prompt),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (prompt.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: -8,
                      children: [
                        for (final tag in prompt.tags)
                          Chip(
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            labelStyle: const TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            isThreeLine: prompt.tags.isNotEmpty,
            onTap: () => _openEditor(prompt),
            onLongPress: () => _showActions(prompt),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.openTeleprompter,
                  icon: const Icon(Icons.play_circle_fill),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 34,
                  onPressed: () => _openTeleprompter(prompt),
                ),
                IconButton(
                  tooltip: l10n.moreActions,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showActions(prompt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal bar of chips to filter by tag. Hidden when there are no tags
/// across the prompts.
class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({required this.store});

  final PromptStore store;

  @override
  Widget build(BuildContext context) {
    final tags = store.allTags;
    if (tags.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final tag in tags)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(tag),
                selected: store.activeTags.contains(tag),
                onSelected: (_) => store.toggleTag(tag),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text(l10n.noPromptsMatchFilters),
          const SizedBox(height: 8),
          TextButton(onPressed: onClear, child: Text(l10n.clearFilters)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 72, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              l10n.noPrompts,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyStateMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
