import 'markdown_service.dart';

/// Statistiche di lettura di un testo: numero di parole e tempo di lettura
/// stimato a una certa velocità di eloquio.
class ReadingStats {
  const ReadingStats({required this.wordCount, required this.duration});

  final int wordCount;
  final Duration duration;

  /// Velocità di lettura ad alta voce predefinita (parole al minuto). Un valore
  /// realistico per il parlato/teleprompter è ~150 wpm.
  static const int defaultWordsPerMinute = 150;

  static final RegExp _wordPattern =
      RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);

  /// Conta le parole in un testo semplice.
  static int countWords(String text) => _wordPattern.allMatches(text).length;

  /// Calcola le statistiche a partire dal testo semplice.
  static ReadingStats fromPlainText(
    String text, {
    int wordsPerMinute = defaultWordsPerMinute,
  }) {
    final words = countWords(text);
    final wpm = wordsPerMinute <= 0 ? defaultWordsPerMinute : wordsPerMinute;
    final seconds = words == 0 ? 0 : (words / wpm * 60).round();
    return ReadingStats(
      wordCount: words,
      duration: Duration(seconds: seconds),
    );
  }

  /// Calcola le statistiche a partire dal contenuto Markdown del prompt.
  static ReadingStats fromMarkdown(
    String markdown, {
    int wordsPerMinute = defaultWordsPerMinute,
  }) {
    return fromPlainText(
      MarkdownService.markdownToPlainText(markdown),
      wordsPerMinute: wordsPerMinute,
    );
  }

  /// Tempo di lettura in forma compatta, es. `< 1 min`, `2 min`, `1 h 5 min`.
  String get durationLabel {
    final totalMinutes = duration.inSeconds / 60;
    if (duration.inSeconds == 0) return '0 min';
    if (totalMinutes < 1) return '< 1 min';
    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    return rem == 0 ? '$hours h' : '$hours h $rem min';
  }

  /// Etichetta combinata, es. `120 parole · ~1 min`.
  String get label {
    final plural = wordCount == 1 ? 'parola' : 'parole';
    return '$wordCount $plural · ~$durationLabel';
  }
}
