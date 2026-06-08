import 'package:flutter/foundation.dart';

import '../data/prompt_repository.dart';
import '../models/prompt.dart';

/// Sort criteria for the prompt list. The localized label is resolved in the
/// UI layer (see `PromptListScreen`), so the enum stays free of display text.
enum PromptSort {
  updatedDesc,
  updatedAsc,
  titleAsc,
  titleDesc,
  createdDesc,
}

/// Shared state for the prompt list, layered on top of [PromptRepository].
///
/// Besides CRUD it handles text search, tag filtering and sorting; the list to
/// display is exposed by [visiblePrompts].
class PromptStore extends ChangeNotifier {
  PromptStore(this._repository);

  final PromptRepository _repository;

  List<Prompt> _prompts = [];
  bool _loading = false;

  String _query = '';
  PromptSort _sort = PromptSort.updatedDesc;
  final Set<String> _activeTags = {};

  /// All prompts (unfiltered), already sorted.
  List<Prompt> get prompts => List.unmodifiable(_prompts);
  bool get loading => _loading;

  String get query => _query;
  PromptSort get sort => _sort;
  Set<String> get activeTags => Set.unmodifiable(_activeTags);

  /// The prompts to display, after search/filter/sort.
  List<Prompt> get visiblePrompts =>
      filterAndSort(_prompts, query: _query, tags: _activeTags, sort: _sort);

  /// All tags present across the prompts, sorted alphabetically.
  List<String> get allTags {
    final set = <String>{};
    for (final p in _prompts) {
      set.addAll(p.tags);
    }
    final list = set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  bool get hasActiveFilters => _query.trim().isNotEmpty || _activeTags.isNotEmpty;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _prompts = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  /// Saves (insert or update) a prompt, refreshing its timestamp.
  Future<Prompt> save(Prompt prompt) async {
    final updated = prompt.copyWith(updatedAt: DateTime.now());
    await _repository.upsert(updated);
    final index = _prompts.indexWhere((p) => p.id == updated.id);
    if (index >= 0) {
      _prompts[index] = updated;
    } else {
      _prompts.add(updated);
    }
    _prompts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
    return updated;
  }

  /// Creates a copy of [prompt] with a new id and a "… (copy)" title.
  ///
  /// The localized [copySuffix] (e.g. "(copy)") and [untitledLabel] are passed
  /// in by the UI layer so the store stays free of display text.
  Future<Prompt> duplicate(
    Prompt prompt, {
    required String copySuffix,
    required String untitledLabel,
  }) async {
    final copy = Prompt.create(
      title: _copyTitle(prompt.title, copySuffix, untitledLabel),
      contentMarkdown: prompt.contentMarkdown,
      localeId: prompt.localeId,
      tags: prompt.tags,
    );
    return save(copy);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _prompts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Restores (upserts) a set of prompts from a backup and reloads the list.
  /// Returns how many prompts were imported.
  Future<int> restore(List<Prompt> prompts) async {
    for (final p in prompts) {
      await _repository.upsert(p);
    }
    await load();
    return prompts.length;
  }

  // --- filtering / sorting ---

  void setQuery(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }

  void setSort(PromptSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (!_activeTags.remove(tag)) _activeTags.add(tag);
    notifyListeners();
  }

  void clearFilters() {
    if (!hasActiveFilters) return;
    _query = '';
    _activeTags.clear();
    notifyListeners();
  }

  static String _copyTitle(
      String title, String copySuffix, String untitledLabel) {
    final base = title.trim().isEmpty ? untitledLabel : title.trim();
    return '$base $copySuffix';
  }

  /// Applies text search, tag filtering and sorting. Pure function, so it is
  /// easy to test.
  ///
  /// - [query] searches (case-insensitive) in the title, content and tags.
  /// - [tags] requires the prompt to contain **all** the given tags.
  static List<Prompt> filterAndSort(
    List<Prompt> prompts, {
    String query = '',
    Set<String> tags = const {},
    PromptSort sort = PromptSort.updatedDesc,
  }) {
    final q = query.trim().toLowerCase();
    final wanted = tags.map((t) => t.toLowerCase()).toSet();

    bool matches(Prompt p) {
      if (wanted.isNotEmpty) {
        final has = p.tags.map((t) => t.toLowerCase()).toSet();
        if (!wanted.every(has.contains)) return false;
      }
      if (q.isEmpty) return true;
      if (p.title.toLowerCase().contains(q)) return true;
      if (p.contentMarkdown.toLowerCase().contains(q)) return true;
      if (p.tags.any((t) => t.toLowerCase().contains(q))) return true;
      return false;
    }

    final result = prompts.where(matches).toList();
    int byTitle(Prompt a, Prompt b) =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase());
    switch (sort) {
      case PromptSort.updatedDesc:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case PromptSort.updatedAsc:
        result.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case PromptSort.titleAsc:
        result.sort(byTitle);
      case PromptSort.titleDesc:
        result.sort((a, b) => byTitle(b, a));
      case PromptSort.createdDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return result;
  }
}
