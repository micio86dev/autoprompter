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
    localeId: 'en_US',
    createdAt: DateTime.fromMillisecondsSinceEpoch(created),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updated),
    tags: tags,
  );
}

void main() {
  final prompts = [
    _p(title: 'Intro', content: 'welcome to the demo', tags: ['work'], updated: 300, created: 100),
    _p(title: 'Closing', content: 'thanks everyone', tags: ['work', 'demo'], updated: 100, created: 300),
    _p(title: 'Notes', content: 'shopping list', tags: ['personal'], updated: 200, created: 200),
  ];

  group('PromptStore.filterAndSort', () {
    test('searches in the title (case-insensitive)', () {
      final r = PromptStore.filterAndSort(prompts, query: 'intro');
      expect(r.map((p) => p.title), ['Intro']);
    });

    test('searches in the content', () {
      final r = PromptStore.filterAndSort(prompts, query: 'shopping');
      expect(r.map((p) => p.title), ['Notes']);
    });

    test('searches in the tags', () {
      final r = PromptStore.filterAndSort(prompts, query: 'personal');
      expect(r.map((p) => p.title), ['Notes']);
    });

    test('tag filter requires all tags', () {
      final r = PromptStore.filterAndSort(prompts, tags: {'work', 'demo'});
      expect(r.map((p) => p.title), ['Closing']);
    });

    test('sort by title A→Z', () {
      final r = PromptStore.filterAndSort(prompts, sort: PromptSort.titleAsc);
      expect(r.map((p) => p.title), ['Closing', 'Intro', 'Notes']);
    });

    test('sort by recently updated (default)', () {
      final r = PromptStore.filterAndSort(prompts);
      expect(r.first.title, 'Intro');
      expect(r.last.title, 'Closing');
    });

    test('sort by recently created', () {
      final r = PromptStore.filterAndSort(prompts, sort: PromptSort.createdDesc);
      expect(r.first.title, 'Closing');
    });

    test('query + tag combined', () {
      final r = PromptStore.filterAndSort(prompts, query: 'thanks', tags: {'work'});
      expect(r.map((p) => p.title), ['Closing']);
    });
  });
}
