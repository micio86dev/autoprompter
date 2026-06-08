import 'markdown_service.dart';

/// Reading statistics for a text: word count and estimated reading time at a
/// given speaking rate.
class ReadingStats {
  const ReadingStats({required this.wordCount, required this.duration});

  final int wordCount;
  final Duration duration;

  /// Default read-aloud speed (words per minute). A realistic value for
  /// speech/teleprompter is ~150 wpm.
  static const int defaultWordsPerMinute = 150;

  static final RegExp _wordPattern =
      RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);

  /// Counts the words in a plain text.
  static int countWords(String text) => _wordPattern.allMatches(text).length;

  /// Computes the statistics from plain text.
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

  /// Computes the statistics from the prompt's Markdown content.
  static ReadingStats fromMarkdown(
    String markdown, {
    int wordsPerMinute = defaultWordsPerMinute,
  }) {
    return fromPlainText(
      MarkdownService.markdownToPlainText(markdown),
      wordsPerMinute: wordsPerMinute,
    );
  }

  /// Reading time in compact form, e.g. `< 1 min`, `2 min`, `1 h 5 min`. The
  /// `min`/`h` abbreviations are locale-neutral; the word count is localized in
  /// the UI (see `readingStatsLabel`).
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
}
