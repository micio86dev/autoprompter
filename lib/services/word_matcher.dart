import 'dart:math' as math;

/// A text segment: either a word (highlightable) or a separator (spaces,
/// punctuation, line breaks) to render as-is.
class TextSegment {
  TextSegment({
    required this.text,
    required this.isWord,
    required this.wordIndex,
  });

  final String text;
  final bool isWord;

  /// Index of the word (0-based) among words only; -1 for separators.
  final int wordIndex;
}

/// A recognizable word, with its normalized form used for comparison.
class _Word {
  _Word(this.normalized);
  final String normalized;
}

/// Aligns the spoken words (from speech recognition) with the prompt text,
/// keeping a "current word" index up to date as the user reads.
///
/// It is designed to be robust to real, imperfect reading:
///  - **skipped** words in the script,
///  - **wrong or changed** words,
///  - **off-script** words (fillers, asides),
///  - **pauses** and restarts at a different point.
///
/// Strategy: it keeps a small buffer of the most recent spoken words and, on
/// each new word, looks for the text position best **confirmed by the recent
/// context** — first in a local window (forward and a little backward), then,
/// if nothing solid is found, with a **global** search that allows re-syncing
/// after a large jump or a pause.
class WordMatcher {
  WordMatcher(String text, {this.window = 30}) {
    _tokenize(text);
  }

  /// How many words **ahead** to search in the local window.
  final int window;

  /// How many words **behind** to tolerate locally (re-reads / false jumps).
  static const int _back = 6;

  /// How many recent words to use as "context" to confirm the position.
  static const int _context = 4;

  /// How many spoken words to keep in memory.
  static const int _recentCap = 8;

  final List<TextSegment> segments = [];
  final List<_Word> _words = [];

  /// Most recent spoken words (normalized), used to re-sync the position even
  /// after jumps or pauses.
  final List<String> _recent = [];

  /// Index of the last recognized word (-1 = nothing yet).
  int currentIndex = -1;

  int get wordCount => _words.length;

  /// Number of words already read.
  int get matchedCount => currentIndex + 1;

  /// Reading progress, from 0.0 to 1.0.
  double get progress =>
      _words.isEmpty ? 0 : (matchedCount / _words.length).clamp(0.0, 1.0);

  void reset() {
    currentIndex = -1;
    _recent.clear();
  }

  /// Manually sets the reading position (e.g. tapping a word). Clears the recent
  /// context so voice alignment resumes from here.
  void setCurrentWordIndex(int index) {
    if (_words.isEmpty) return;
    currentIndex = index.clamp(-1, _words.length - 1);
    _recent.clear();
  }

  /// Consumes the spoken words, re-syncing [currentIndex] to the most likely
  /// position in the text. Returns true if the index changed.
  bool consume(Iterable<String> spokenWords) {
    final before = currentIndex;
    for (final spoken in spokenWords) {
      final norm = _normalize(spoken);
      if (norm.isEmpty) continue;
      _recent.add(norm);
      if (_recent.length > _recentCap) {
        _recent.removeRange(0, _recent.length - _recentCap);
      }
      _advance();
    }
    return currentIndex != before;
  }

  // --- re-syncing ---

  /// How well the recent context aligns if the **last** spoken word matches the
  /// prompt word at index [i].
  ///
  /// Returns -1 if the last word does not match `i` at all; otherwise a score:
  /// 2 as a baseline, +1 for every earlier recent word found among the prompt
  /// words right before `i` (jump tolerance).
  int _score(int i) {
    if (i < 0 || i >= _words.length) return -1;
    if (!_matches(_recent.last, _words[i].normalized)) return -1;
    var score = 2; // the last spoken word matches `i`
    final lo = math.max(0, i - _context);
    final start = math.max(0, _recent.length - 1 - _context);
    for (var r = _recent.length - 2; r >= start; r--) {
      for (var p = lo; p < i; p++) {
        if (_matches(_recent[r], _words[p].normalized)) {
          score++;
          break;
        }
      }
    }
    return score;
  }

  /// Acceptance rules for a candidate, tuned to avoid jitter:
  ///  - close forward move (1..4 words): a plain match is enough;
  ///  - larger forward jump: at least one context confirmation is required;
  ///  - backward or far move: a strong context is required.
  bool _acceptable(int i, int score) {
    if (score < 2) return false;
    final step = i - currentIndex;
    if (step >= 1 && step <= 4) return true;
    if (step > 4 && step <= window) return score >= 3;
    return score >= 4;
  }

  void _advance() {
    if (_words.isEmpty) return;

    // 1) Local search: around the current position, forward and a little
    //    backward. On a score tie, prefer the closest forward position so we
    //    don't overshoot repeated phrases.
    final lo = math.max(0, currentIndex - _back);
    final hi = math.min(_words.length - 1, currentIndex + window);
    var bestI = -1;
    var bestScore = 0;
    for (var i = lo; i <= hi; i++) {
      final s = _score(i);
      if (s < 0) continue;
      if (s > bestScore ||
          (s == bestScore &&
              bestI >= 0 &&
              _forwardBias(i) < _forwardBias(bestI))) {
        bestScore = s;
        bestI = i;
      }
    }
    if (bestI >= 0 && _acceptable(bestI, bestScore)) {
      currentIndex = bestI;
      return;
    }

    // 2) Global re-sync: after a large jump or a pause, search everywhere for
    //    the position best confirmed by the recent context. The high threshold
    //    avoids random jumps on a single common word.
    bestI = -1;
    bestScore = 0;
    for (var i = 0; i < _words.length; i++) {
      final s = _score(i);
      if (s > bestScore) {
        bestScore = s;
        bestI = i;
      }
    }
    if (bestI >= 0 && bestScore >= 4) {
      currentIndex = bestI;
    }
  }

  /// Orders candidates with an equal score: forward and closer ones first.
  int _forwardBias(int i) {
    final step = i - currentIndex;
    return step >= 1 ? step : 1000 - step;
  }

  // --- internals ---

  static final RegExp _wordPattern =
      RegExp(r"[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*", unicode: true);

  void _tokenize(String text) {
    var last = 0;
    var wordIndex = 0;
    for (final match in _wordPattern.allMatches(text)) {
      if (match.start > last) {
        segments.add(TextSegment(
          text: text.substring(last, match.start),
          isWord: false,
          wordIndex: -1,
        ));
      }
      final raw = match.group(0)!;
      segments.add(TextSegment(text: raw, isWord: true, wordIndex: wordIndex));
      _words.add(_Word(_normalize(raw)));
      wordIndex++;
      last = match.end;
    }
    if (last < text.length) {
      segments.add(TextSegment(
        text: text.substring(last),
        isWord: false,
        wordIndex: -1,
      ));
    }
  }

  bool _matches(String spoken, String target) {
    if (spoken == target) return true;
    // Prefix match (useful with partial results).
    if (spoken.length >= 4 && target.startsWith(spoken)) return true;
    // Error tolerance for words long enough.
    if (spoken.length >= 4 && target.length >= 4) {
      final threshold = spoken.length >= 7 ? 2 : 1;
      if (_levenshtein(spoken, target) <= threshold) return true;
    }
    return false;
  }

  static const Map<String, String> _diacritics = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  static String _normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final ch = String.fromCharCode(rune);
      final replaced = _diacritics[ch] ?? ch;
      // Keep only letters and digits.
      if (RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(replaced)) {
        buffer.write(replaced);
      }
    }
    return buffer.toString();
  }

  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var prev = List<int>.generate(b.length + 1, (i) => i);
    var curr = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
        curr[j + 1] = math.min(
          math.min(curr[j] + 1, prev[j + 1] + 1),
          prev[j] + cost,
        );
      }
      final tmp = prev;
      prev = curr;
      curr = tmp;
    }
    return prev[b.length];
  }
}
