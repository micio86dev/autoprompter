import 'package:autoprompter/services/markdown_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownService', () {
    test('estrae testo semplice rimuovendo la formattazione', () {
      final plain = MarkdownService.markdownToPlainText(
          '# Titolo\n\nUn **testo** in _corsivo_.');
      expect(plain.contains('Titolo'), isTrue);
      expect(plain.contains('Un testo in corsivo.'), isTrue);
      expect(plain.contains('**'), isFalse);
      expect(plain.contains('#'), isFalse);
    });

    test('round-trip Markdown -> Delta -> Markdown conserva il testo', () {
      const md = '# Titolo\n\nPrimo paragrafo con **grassetto**.';
      final delta = MarkdownService.markdownToDelta(md);
      final back = MarkdownService.deltaToMarkdown(delta);
      // Il testo visibile sopravvive al round-trip.
      final plain = MarkdownService.markdownToPlainText(back);
      expect(plain.contains('Titolo'), isTrue);
      expect(plain.contains('Primo paragrafo con grassetto.'), isTrue);
      // I marcatori di grassetto e titolo sono ancora presenti.
      expect(back.contains('#'), isTrue);
      expect(back.contains('*'), isTrue);
    });

    test('gestisce gli elenchi puntati', () {
      const md = '- uno\n- due\n- tre';
      final delta = MarkdownService.markdownToDelta(md);
      final back = MarkdownService.deltaToMarkdown(delta);
      final plain = MarkdownService.markdownToPlainText(back);
      expect(plain.contains('uno'), isTrue);
      expect(plain.contains('due'), isTrue);
      expect(plain.contains('tre'), isTrue);
    });

    test('contenuto vuoto produce testo vuoto', () {
      expect(MarkdownService.markdownToPlainText(''), '');
      expect(MarkdownService.markdownToPlainText('   '), '');
    });

    test('conserva i link nel round-trip', () {
      const md = 'Vai su [il sito](https://example.com) ora.';
      final back =
          MarkdownService.deltaToMarkdown(MarkdownService.markdownToDelta(md));
      expect(back.contains('https://example.com'), isTrue);
      expect(back.contains('il sito'), isTrue);
      expect(back.contains(']('), isTrue);
    });

    test('conserva il codice inline nel round-trip', () {
      const md = 'Usa il comando `flutter run` adesso.';
      final back =
          MarkdownService.deltaToMarkdown(MarkdownService.markdownToDelta(md));
      expect(back.contains('`flutter run`'), isTrue);
    });
  });
}
