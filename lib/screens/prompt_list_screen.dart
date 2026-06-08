import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prompt.dart';
import '../services/data_service.dart';
import '../services/markdown_service.dart';
import '../state/prompt_store.dart';
import '../state/settings_store.dart';
import 'prompt_editor_screen.dart';
import 'settings_screen.dart';
import 'teleprompter_screen.dart';

/// Schermata principale: elenco dei prompt salvati, con ricerca, ordinamento e
/// filtro per tag.
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
    final store = context.read<PromptStore>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare il prompt?'),
        content: Text(
          'Vuoi eliminare "${prompt.title.isEmpty ? 'Senza titolo' : prompt.title}"? '
          'L\'operazione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.delete(prompt.id);
    }
  }

  Future<void> _duplicate(Prompt prompt) async {
    final store = context.read<PromptStore>();
    final messenger = ScaffoldMessenger.of(context);
    await store.duplicate(prompt);
    messenger.showSnackBar(const SnackBar(content: Text('Prompt duplicato')));
  }

  Future<void> _share(Prompt prompt) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await DataService.instance.sharePrompt(prompt);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Condivisione non riuscita: $e')),
      );
    }
  }

  Future<void> _importMarkdown(PromptStore store) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final prompt = await DataService.instance.importMarkdown();
      if (prompt == null) return;
      final saved = await store.save(prompt);
      if (!mounted) return;
      _openEditor(saved);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Importazione non riuscita: $e')),
      );
    }
  }

  Future<void> _backup(PromptStore store) async {
    final messenger = ScaffoldMessenger.of(context);
    if (store.prompts.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nessun prompt da salvare')),
      );
      return;
    }
    try {
      await DataService.instance.backup(store.prompts);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Backup non riuscito: $e')),
      );
    }
  }

  Future<void> _restore(PromptStore store) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await DataService.instance.restore();
      if (result == null) return;
      final n = await store.restore(result.prompts);
      messenger.showSnackBar(
        SnackBar(content: Text('Ripristinati $n prompt')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Ripristino non riuscito: $e')),
      );
    }
  }

  void _showActions(Prompt prompt) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                prompt.title.isEmpty ? 'Senza titolo' : prompt.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modifica'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openEditor(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Apri teleprompter'),
              onTap: () {
                Navigator.of(ctx).pop();
                _openTeleprompter(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplica'),
              onTap: () {
                Navigator.of(ctx).pop();
                _duplicate(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: const Text('Condividi (.md)'),
              onTap: () {
                Navigator.of(ctx).pop();
                _share(prompt);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Elimina', style: TextStyle(color: Colors.red)),
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
    if (plain.isEmpty) return 'Nessun contenuto';
    return plain.length > 100 ? '${plain.substring(0, 100)}…' : plain;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PromptStore>();
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cerca nei prompt…',
                  border: InputBorder.none,
                ),
                onChanged: store.setQuery,
              )
            : const Text('Autoprompter'),
        actions: [
          if (_searching)
            IconButton(
              tooltip: 'Chiudi ricerca',
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                store.setQuery('');
                setState(() => _searching = false);
              },
            )
          else
            IconButton(
              tooltip: 'Cerca',
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
          PopupMenuButton<PromptSort>(
            tooltip: 'Ordina',
            icon: const Icon(Icons.sort),
            initialValue: store.sort,
            onSelected: store.setSort,
            itemBuilder: (_) => [
              for (final s in PromptSort.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
          ),
          PopupMenuButton<String>(
            tooltip: 'Menu',
            onSelected: (value) => _onMenuSelected(value, store),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'import', child: Text('Importa Markdown…')),
              PopupMenuItem(value: 'backup', child: Text('Backup dati…')),
              PopupMenuItem(value: 'restore', child: Text('Ripristina backup…')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'settings', child: Text('Impostazioni')),
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
        label: const Text('Nuovo prompt'),
      ),
    );
  }

  Widget _buildList(PromptStore store) {
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
            return false; // la cancellazione la gestisce lo store
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(
              prompt.title.isEmpty ? 'Senza titolo' : prompt.title,
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
                  tooltip: 'Apri teleprompter',
                  icon: const Icon(Icons.play_circle_fill),
                  color: Theme.of(context).colorScheme.primary,
                  iconSize: 34,
                  onPressed: () => _openTeleprompter(prompt),
                ),
                IconButton(
                  tooltip: 'Altre azioni',
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

/// Barra orizzontale di chip per filtrare per tag. Si nasconde se non ci sono
/// tag tra i prompt.
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          const Text('Nessun prompt corrisponde ai filtri'),
          const SizedBox(height: 8),
          TextButton(onPressed: onClear, child: const Text('Azzera i filtri')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 72, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            const Text(
              'Nessun prompt',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tocca "Nuovo prompt" per creare il tuo primo testo da leggere '
              'al teleprompter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
