import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/services/data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataService export markdown', () {
    test('adds the title as H1', () {
      final p =
          Prompt.create(title: 'Greeting', contentMarkdown: 'Hello everyone');
      final out = DataService.promptToMarkdownFile(p);
      expect(out, '# Greeting\n\nHello everyone\n');
    });

    test('without a title exports only the body', () {
      final p = Prompt.create(title: '', contentMarkdown: 'Body only');
      expect(DataService.promptToMarkdownFile(p), 'Body only\n');
    });
  });

  group('DataService backup', () {
    test('encode/decode round-trip preserves the prompts and tags', () {
      final prompts = [
        Prompt.create(title: 'A', contentMarkdown: '# A', tags: ['x', 'y']),
        Prompt.create(title: 'B', contentMarkdown: 'text'),
      ];
      final json = DataService.encodeBackup(prompts);
      final restored = DataService.decodeBackup(json);
      expect(restored.length, 2);
      expect(restored[0].title, 'A');
      expect(restored[0].tags, ['x', 'y']);
      expect(restored[0].id, prompts[0].id);
      expect(restored[1].contentMarkdown, 'text');
    });

    test('also decodes a plain list of prompts', () {
      final prompts = [Prompt.create(title: 'Only')];
      final listJson = DataService.encodeBackup(prompts);
      // extracts the array and passes it on its own
      final restored = DataService.decodeBackup(listJson);
      expect(restored.single.title, 'Only');
    });

    test('an invalid backup throws FormatException', () {
      expect(() => DataService.decodeBackup('{"foo": 1}'),
          throwsA(isA<FormatException>()));
    });
  });
}
