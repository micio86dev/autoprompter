import 'package:autoprompter/services/markdown_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarkdownService', () {
    test('extracts plain text stripping the formatting', () {
      final plain = MarkdownService.markdownToPlainText(
          '# Title\n\nA **text** in _italic_.');
      expect(plain.contains('Title'), isTrue);
      expect(plain.contains('A text in italic.'), isTrue);
      expect(plain.contains('**'), isFalse);
      expect(plain.contains('#'), isFalse);
    });

    test('round-trip Markdown -> Delta -> Markdown keeps the text', () {
      const md = '# Title\n\nFirst paragraph with **bold**.';
      final delta = MarkdownService.markdownToDelta(md);
      final back = MarkdownService.deltaToMarkdown(delta);
      // The visible text survives the round-trip.
      final plain = MarkdownService.markdownToPlainText(back);
      expect(plain.contains('Title'), isTrue);
      expect(plain.contains('First paragraph with bold.'), isTrue);
      // The bold and heading markers are still present.
      expect(back.contains('#'), isTrue);
      expect(back.contains('*'), isTrue);
    });

    test('handles bullet lists', () {
      const md = '- one\n- two\n- three';
      final delta = MarkdownService.markdownToDelta(md);
      final back = MarkdownService.deltaToMarkdown(delta);
      final plain = MarkdownService.markdownToPlainText(back);
      expect(plain.contains('one'), isTrue);
      expect(plain.contains('two'), isTrue);
      expect(plain.contains('three'), isTrue);
    });

    test('empty content produces empty text', () {
      expect(MarkdownService.markdownToPlainText(''), '');
      expect(MarkdownService.markdownToPlainText('   '), '');
    });

    test('keeps links in the round-trip', () {
      const md = 'Go to [the site](https://example.com) now.';
      final back =
          MarkdownService.deltaToMarkdown(MarkdownService.markdownToDelta(md));
      expect(back.contains('https://example.com'), isTrue);
      expect(back.contains('the site'), isTrue);
      expect(back.contains(']('), isTrue);
    });

    test('keeps inline code in the round-trip', () {
      const md = 'Use the `flutter run` command now.';
      final back =
          MarkdownService.deltaToMarkdown(MarkdownService.markdownToDelta(md));
      expect(back.contains('`flutter run`'), isTrue);
    });
  });
}
