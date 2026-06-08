import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/state/prompt_store.dart';
import 'package:flutter_test/flutter_test.dart';

Prompt _p({
  required String title,
  String content = '',
  List<String> tags = const [],
  int updated = 0,
  int created = 0,
}) {
  return Prompt(
    id: title,
    title: title,
    contentMarkdown: content,
    localeId: 'it_IT',
    createdAt: DateTime.fromMillisecondsSinceEpoch(created),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updated),
    tags: tags,
  );
}

void main() {
  final prompts = [
    _p(title: 'Intro', content: 'benvenuti alla demo', tags: ['lavoro'], updated: 300, created: 100),
    _p(title: 'Chiusura', content: 'grazie a tutti', tags: ['lavoro', 'demo'], updated: 100, created: 300),
    _p(title: 'Appunti', content: 'lista della spesa', tags: ['personale'], updated: 200, created: 200),
  ];

  group('PromptStore.filterAndSort', () {
    test('ricerca nel titolo (case-insensitive)', () {
      final r = PromptStore.filterAndSort(prompts, query: 'intro');
      expect(r.map((p) => p.title), ['Intro']);
    });

    test('ricerca nel contenuto', () {
      final r = PromptStore.filterAndSort(prompts, query: 'spesa');
      expect(r.map((p) => p.title), ['Appunti']);
    });

    test('ricerca nei tag', () {
      final r = PromptStore.filterAndSort(prompts, query: 'personale');
      expect(r.map((p) => p.title), ['Appunti']);
    });

    test('filtro per tag richiede tutti i tag', () {
      final r = PromptStore.filterAndSort(prompts, tags: {'lavoro', 'demo'});
      expect(r.map((p) => p.title), ['Chiusura']);
    });

    test('ordinamento per titolo A→Z', () {
      final r = PromptStore.filterAndSort(prompts, sort: PromptSort.titleAsc);
      expect(r.map((p) => p.title), ['Appunti', 'Chiusura', 'Intro']);
    });

    test('ordinamento per modifica recente (default)', () {
      final r = PromptStore.filterAndSort(prompts);
      expect(r.first.title, 'Intro');
      expect(r.last.title, 'Chiusura');
    });

    test('ordinamento per creazione recente', () {
      final r = PromptStore.filterAndSort(prompts, sort: PromptSort.createdDesc);
      expect(r.first.title, 'Chiusura');
    });

    test('query + tag combinati', () {
      final r = PromptStore.filterAndSort(prompts, query: 'grazie', tags: {'lavoro'});
      expect(r.map((p) => p.title), ['Chiusura']);
    });
  });
}
