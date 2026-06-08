import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/services/data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataService export markdown', () {
    test('aggiunge il titolo come H1', () {
      final p = Prompt.create(title: 'Saluto', contentMarkdown: 'Ciao a tutti');
      final out = DataService.promptToMarkdownFile(p);
      expect(out, '# Saluto\n\nCiao a tutti\n');
    });

    test('senza titolo esporta solo il corpo', () {
      final p = Prompt.create(title: '', contentMarkdown: 'Solo corpo');
      expect(DataService.promptToMarkdownFile(p), 'Solo corpo\n');
    });
  });

  group('DataService backup', () {
    test('round-trip encode/decode preserva i prompt e i tag', () {
      final prompts = [
        Prompt.create(title: 'A', contentMarkdown: '# A', tags: ['x', 'y']),
        Prompt.create(title: 'B', contentMarkdown: 'testo'),
      ];
      final json = DataService.encodeBackup(prompts);
      final restored = DataService.decodeBackup(json);
      expect(restored.length, 2);
      expect(restored[0].title, 'A');
      expect(restored[0].tags, ['x', 'y']);
      expect(restored[0].id, prompts[0].id);
      expect(restored[1].contentMarkdown, 'testo');
    });

    test('decodifica anche una semplice lista di prompt', () {
      final prompts = [Prompt.create(title: 'Solo')];
      final listJson = DataService.encodeBackup(prompts);
      // estrae l'array e lo passa da solo
      final restored = DataService.decodeBackup(listJson);
      expect(restored.single.title, 'Solo');
    });

    test('backup non valido solleva FormatException', () {
      expect(() => DataService.decodeBackup('{"foo": 1}'),
          throwsA(isA<FormatException>()));
    });
  });
}
