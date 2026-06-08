import 'package:flutter/material.dart';

import '../services/word_matcher.dart';

/// Renders the prompt text word-by-word with a "karaoke" effect: already-read
/// words dimmed, the current word highlighted, upcoming words bright. The
/// current word carries [currentWordKey] for scrolling.
///
/// Every word is laid out inside an identically-sized padded box (transparent
/// for non-current words, filled for the current one) and shares the same font
/// weight. This keeps each word's footprint constant regardless of highlight
/// state, so the surrounding text never shifts as the highlight advances.
///
/// Tapping a word calls [onWordTap], used to manually reposition the reading
/// point.
class TeleprompterText extends StatelessWidget {
  const TeleprompterText({
    super.key,
    required this.segments,
    required this.currentIndex,
    required this.fontSize,
    required this.currentWordKey,
    this.scrollController,
    this.onWordTap,
    this.bottomPadding = 400,
  });

  final List<TextSegment> segments;
  final int currentIndex;
  final double fontSize;
  final GlobalKey currentWordKey;
  final ScrollController? scrollController;
  final ValueChanged<int>? onWordTap;
  final double bottomPadding;

  static const _readColor = Color(0x66FFFFFF); // read: dimmed
  static const _upcomingColor = Color(0xFFFFFFFF); // upcoming
  static const _currentColor = Color(0xFF101010); // highlighted text
  static const _currentBg = Color(0xFFFFC107); // current word background

  // Horizontal padding applied to EVERY word box so widths stay constant
  // whether or not a word is the highlighted one.
  static const EdgeInsets _wordPadding = EdgeInsets.symmetric(horizontal: 2);

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      height: 1.5,
      color: _upcomingColor,
      // Constant weight across states: changing weight per word would alter its
      // width and shift the surrounding text as the highlight moves.
      fontWeight: FontWeight.w600,
    );

    final spans = <InlineSpan>[];
    for (final seg in segments) {
      if (!seg.isWord) {
        spans.add(TextSpan(text: seg.text, style: baseStyle));
        continue;
      }
      final isCurrent = seg.wordIndex == currentIndex;
      final read = seg.wordIndex < currentIndex;
      final color =
          isCurrent ? _currentColor : (read ? _readColor : _upcomingColor);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: onWordTap == null ? null : () => onWordTap!(seg.wordIndex),
            child: Container(
              key: isCurrent ? currentWordKey : null,
              padding: _wordPadding,
              decoration: BoxDecoration(
                color: isCurrent ? _currentBg : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(seg.text, style: baseStyle.copyWith(color: color)),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(20, 40, 20, bottomPadding),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}
