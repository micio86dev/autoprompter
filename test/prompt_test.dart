import 'package:autoprompter/models/prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Prompt tags', () {
    test('normalizza: trim, scarta vuoti, deduplica case-insensitive', () {
      final tags = Prompt.normalizeTags(['  Lavoro ', 'lavoro', '', 'Demo']);
      expect(tags, ['Lavoro', 'Demo']);
    });

    test('encode/decode round-trip via JSON', () {
      const tags = ['lavoro', 'intro, breve', 'çà'];
      final encoded = Prompt.encodeTags(tags);
      expect(Prompt.decodeTags(encoded), tags);
    });

    test('decode tollera null e stringa vuota', () {
      expect(Prompt.decodeTags(null), isEmpty);
      expect(Prompt.decodeTags(''), isEmpty);
      expect(Prompt.decodeTags('   '), isEmpty);
    });

    test('decode legacy CSV', () {
      expect(Prompt.decodeTags('uno, due ,tre'), ['uno', 'due', 'tre']);
    });

    test('toMap/fromMap preserva i tag', () {
      final p = Prompt.create(title: 'T', tags: ['a', 'b']);
      final restored = Prompt.fromMap(p.toMap());
      expect(restored.tags, ['a', 'b']);
      expect(restored.id, p.id);
      expect(restored.title, 'T');
    });

    test('fromMap senza colonna tags (riga legacy) -> lista vuota', () {
      final p = Prompt.fromMap({
        'id': 'x',
        'title': 'Vecchio',
        'content_markdown': 'ciao',
        'locale_id': 'it_IT',
        'created_at': 0,
        'updated_at': 0,
      });
      expect(p.tags, isEmpty);
    });
  });
}
