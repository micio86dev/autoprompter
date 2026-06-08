import 'package:flutter/foundation.dart';

import '../data/prompt_repository.dart';
import '../models/prompt.dart';

/// Criteri di ordinamento della lista dei prompt.
enum PromptSort {
  updatedDesc('Modificati di recente'),
  updatedAsc('Modificati meno di recente'),
  titleAsc('Titolo A→Z'),
  titleDesc('Titolo Z→A'),
  createdDesc('Creati di recente');

  const PromptSort(this.label);
  final String label;
}

/// Stato condiviso della lista dei prompt, sopra [PromptRepository].
///
/// Oltre al CRUD gestisce ricerca testuale, filtro per tag e ordinamento; la
/// lista da mostrare è esposta da [visiblePrompts].
class PromptStore extends ChangeNotifier {
  PromptStore(this._repository);

  final PromptRepository _repository;

  List<Prompt> _prompts = [];
  bool _loading = false;

  String _query = '';
  PromptSort _sort = PromptSort.updatedDesc;
  final Set<String> _activeTags = {};

  /// Tutti i prompt (non filtrati), già ordinati.
  List<Prompt> get prompts => List.unmodifiable(_prompts);
  bool get loading => _loading;

  String get query => _query;
  PromptSort get sort => _sort;
  Set<String> get activeTags => Set.unmodifiable(_activeTags);

  /// I prompt da mostrare, dopo ricerca/filtro/ordinamento.
  List<Prompt> get visiblePrompts =>
      filterAndSort(_prompts, query: _query, tags: _activeTags, sort: _sort);

  /// Tutti i tag presenti tra i prompt, ordinati alfabeticamente.
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

  /// Salva (insert o update) un prompt, aggiornando il timestamp.
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

  /// Crea una copia di [prompt] con nuovo id e titolo "… (copia)".
  Future<Prompt> duplicate(Prompt prompt) async {
    final copy = Prompt.create(
      title: _copyTitle(prompt.title),
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

  /// Ripristina (upsert) un insieme di prompt da un backup e ricarica la lista.
  /// Ritorna quanti prompt sono stati importati.
  Future<int> restore(List<Prompt> prompts) async {
    for (final p in prompts) {
      await _repository.upsert(p);
    }
    await load();
    return prompts.length;
  }

  // --- filtri / ordinamento ---

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

  static String _copyTitle(String title) {
    final base = title.trim().isEmpty ? 'Senza titolo' : title.trim();
    return '$base (copia)';
  }

  /// Applica ricerca testuale, filtro per tag e ordinamento. Funzione pura,
  /// così è facilmente testabile.
  ///
  /// - [query] cerca (case-insensitive) nel titolo, nel contenuto e nei tag.
  /// - [tags] richiede che il prompt contenga **tutti** i tag indicati.
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
