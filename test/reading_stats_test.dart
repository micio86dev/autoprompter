import 'package:autoprompter/services/reading_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingStats', () {
    test('conta le parole ignorando la punteggiatura', () {
      expect(ReadingStats.countWords('Ciao, mondo! Come va?'), 4);
      expect(ReadingStats.countWords("l'altro giorno"), 2);
      expect(ReadingStats.countWords('   '), 0);
    });

    test('testo vuoto: 0 parole e durata zero', () {
      final s = ReadingStats.fromPlainText('');
      expect(s.wordCount, 0);
      expect(s.duration, Duration.zero);
      expect(s.durationLabel, '0 min');
    });

    test('tempo stimato a 150 wpm', () {
      final words = List.filled(150, 'parola').join(' ');
      final s = ReadingStats.fromPlainText(words);
      expect(s.wordCount, 150);
      expect(s.duration.inSeconds, 60);
      expect(s.durationLabel, '1 min');
    });

    test('pochi secondi -> "< 1 min"', () {
      final s = ReadingStats.fromPlainText('una manciata di parole brevi');
      expect(s.durationLabel, '< 1 min');
    });

    test('velocità personalizzata', () {
      final words = List.filled(60, 'x').join(' ');
      final s = ReadingStats.fromPlainText(words, wordsPerMinute: 60);
      expect(s.duration.inSeconds, 60);
    });

    test('label combinata coerente', () {
      final s = ReadingStats.fromPlainText('una');
      expect(s.label.startsWith('1 parola'), isTrue);
    });
  });
}
