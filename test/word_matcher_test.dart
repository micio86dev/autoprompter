import 'package:autoprompter/services/word_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordMatcher tokenization', () {
    test('counts words correctly', () {
      final m = WordMatcher('Hello world, how are you?');
      expect(m.wordCount, 5); // Hello, world, how, are, you
    });

    test('keeps the separators in the segments', () {
      final m = WordMatcher('a b');
      final rebuilt = m.segments.map((s) => s.text).join();
      expect(rebuilt, 'a b');
      expect(m.segments.where((s) => s.isWord).length, 2);
    });

    test('treats words with an apostrophe as a single token', () {
      final m = WordMatcher("the other's day");
      expect(m.wordCount, 3);
    });
  });

  group('WordMatcher advancing', () {
    test('starts at -1', () {
      final m = WordMatcher('one two three');
      expect(m.currentIndex, -1);
      expect(m.matchedCount, 0);
    });

    test('advances on exact words in sequence', () {
      final m = WordMatcher('one two three four');
      m.consume(['one']);
      expect(m.currentIndex, 0);
      m.consume(['two', 'three']);
      expect(m.currentIndex, 2);
    });

    test('skips a word within the window', () {
      final m = WordMatcher('alpha beta gamma delta');
      m.consume(['alpha']);
      // Skips "beta" and says "gamma" directly.
      m.consume(['gamma']);
      expect(m.currentIndex, 2);
    });

    test('ignores absent words without going backward', () {
      final m = WordMatcher('one two three');
      m.consume(['one']);
      m.consume(['xyzqwerty']);
      expect(m.currentIndex, 0);
    });

    test('tolerates small recognition errors (Levenshtein)', () {
      final m = WordMatcher('welcome teleprompter');
      // "telepromter" -> "teleprompter" (1 character difference)
      m.consume(['welcome', 'telepromter']);
      expect(m.currentIndex, 1);
    });

    test('is insensitive to accents and case', () {
      final m = WordMatcher('Café résumé');
      m.consume(['cafe', 'resume']);
      expect(m.currentIndex, 1);
    });

    test('prefix match (partial results)', () {
      final m = WordMatcher('registration completed');
      m.consume(['regist']);
      expect(m.currentIndex, 0);
    });

    test('progress and reset', () {
      final m = WordMatcher('one two three four');
      m.consume(['one', 'two']);
      expect(m.progress, closeTo(0.5, 0.0001));
      m.reset();
      expect(m.currentIndex, -1);
      expect(m.progress, 0);
    });

    test('does not go past the end of the text', () {
      final m = WordMatcher('one two');
      m.consume(['one', 'two', 'three', 'four']);
      expect(m.currentIndex, 1);
    });

    test('setCurrentWordIndex repositions and then continues from there', () {
      final m = WordMatcher('one two three four five');
      m.setCurrentWordIndex(2); // tap on "three"
      expect(m.currentIndex, 2);
      m.consume(['four']);
      expect(m.currentIndex, 3);
    });

    test('setCurrentWordIndex clamps to the bounds', () {
      final m = WordMatcher('one two three');
      m.setCurrentWordIndex(99);
      expect(m.currentIndex, 2);
      m.setCurrentWordIndex(-5);
      expect(m.currentIndex, -1);
    });
  });

  group('WordMatcher robustness (imperfect reading)', () {
    // 40 distinct words (no Levenshtein collisions).
    // Indices: 0 apple ... 20 crimson ... 30 monday ... 35 saturday ... 39 march
    const text =
        'apple banana cherry strawberry orange lemon peach grape kiwi melon '
        'dog cat horse rabbit turtle dolphin eagle hawk wolf squirrel '
        'crimson olive azure amber violet maroon teal silver beige indigo '
        'monday tuesday wednesday thursday friday saturday sunday january february march';

    test('recovers after a jump beyond the window (global search)', () {
      final m = WordMatcher(text);
      m.consume(['apple', 'banana', 'cherry']);
      expect(m.currentIndex, 2);
      // Jumps ahead by more than 30 words and reads from there: it re-syncs.
      m.consume(['thursday', 'friday', 'saturday']);
      expect(m.currentIndex, 35);
    });

    test('restarts after a pause at a different point', () {
      final m = WordMatcher(text);
      m.consume(['apple', 'banana']);
      m.consume(['crimson', 'olive', 'azure']);
      expect(m.currentIndex, 22);
    });

    test('off-script words do not block or move the cursor', () {
      final m = WordMatcher(text);
      m.consume(['apple', 'banana']);
      m.consume(['um', 'wait', 'so']); // fillers absent from the text
      expect(m.currentIndex, 1);
      m.consume(['cherry']); // resumes normally
      expect(m.currentIndex, 2);
    });

    test('continues despite a changed word', () {
      final m = WordMatcher(text);
      m.consume(['apple', 'banana']);
      m.consume(['foobar']); // should have been "cherry"
      m.consume(['strawberry', 'orange']);
      expect(m.currentIndex, 4);
    });

    test('recovers if the cursor had jumped too far ahead', () {
      final m = WordMatcher(text);
      // Cursor pushed ahead by mistake.
      m.consume(['monday', 'tuesday', 'wednesday']);
      expect(m.currentIndex, 32);
      // The reader was actually at the start: it must go back.
      m.consume(['apple', 'banana', 'cherry']);
      expect(m.currentIndex, 2);
    });
  });
}
