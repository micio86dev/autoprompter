import 'package:autoprompter/models/prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Prompt tags', () {
    test('normalizes: trim, drop empties, de-duplicate case-insensitively', () {
      final tags = Prompt.normalizeTags(['  Work ', 'work', '', 'Demo']);
      expect(tags, ['Work', 'Demo']);
    });

    test('encode/decode round-trip via JSON', () {
      const tags = ['work', 'intro, brief', 'çà'];
      final encoded = Prompt.encodeTags(tags);
      expect(Prompt.decodeTags(encoded), tags);
    });

    test('decode tolerates null and empty string', () {
      expect(Prompt.decodeTags(null), isEmpty);
      expect(Prompt.decodeTags(''), isEmpty);
      expect(Prompt.decodeTags('   '), isEmpty);
    });

    test('decode legacy CSV', () {
      expect(Prompt.decodeTags('one, two ,three'), ['one', 'two', 'three']);
    });

    test('toMap/fromMap preserves the tags', () {
      final p = Prompt.create(title: 'T', tags: ['a', 'b']);
      final restored = Prompt.fromMap(p.toMap());
      expect(restored.tags, ['a', 'b']);
      expect(restored.id, p.id);
      expect(restored.title, 'T');
    });

    test('fromMap without a tags column (legacy row) -> empty list', () {
      final p = Prompt.fromMap({
        'id': 'x',
        'title': 'Old',
        'content_markdown': 'hi',
        'locale_id': 'en_US',
        'created_at': 0,
        'updated_at': 0,
      });
      expect(p.tags, isEmpty);
    });
  });
}
