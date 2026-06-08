import 'package:autoprompter/services/reading_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingStats', () {
    test('counts words ignoring punctuation', () {
      expect(ReadingStats.countWords('Hello, world! How are you?'), 5);
      expect(ReadingStats.countWords("the other day"), 3);
      expect(ReadingStats.countWords('   '), 0);
    });

    test('empty text: 0 words and zero duration', () {
      final s = ReadingStats.fromPlainText('');
      expect(s.wordCount, 0);
      expect(s.duration, Duration.zero);
      expect(s.durationLabel, '0 min');
    });

    test('estimated time at 150 wpm', () {
      final words = List.filled(150, 'word').join(' ');
      final s = ReadingStats.fromPlainText(words);
      expect(s.wordCount, 150);
      expect(s.duration.inSeconds, 60);
      expect(s.durationLabel, '1 min');
    });

    test('a few seconds -> "< 1 min"', () {
      final s = ReadingStats.fromPlainText('a handful of short words');
      expect(s.durationLabel, '< 1 min');
    });

    test('custom speed', () {
      final words = List.filled(60, 'x').join(' ');
      final s = ReadingStats.fromPlainText(words, wordsPerMinute: 60);
      expect(s.duration.inSeconds, 60);
    });

    test('exposes word count for a single word', () {
      final s = ReadingStats.fromPlainText('one');
      expect(s.wordCount, 1);
    });
  });
}
