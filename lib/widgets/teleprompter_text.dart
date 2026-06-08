import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/word_matcher.dart';

/// Rende il testo del prompt parola-per-parola con effetto "karaoke":
/// parole già lette attenuate, parola corrente evidenziata, parole successive
/// in chiaro. La parola corrente porta [currentWordKey] per lo scroll.
///
/// Toccando una parola si richiama [onWordTap], usato per riposizionare
/// manualmente il punto di lettura.
class TeleprompterText extends StatefulWidget {
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

  @override
  State<TeleprompterText> createState() => _TeleprompterTextState();
}

class _TeleprompterTextState extends State<TeleprompterText> {
  static const _readColor = Color(0x66FFFFFF); // letto: attenuato
  static const _upcomingColor = Color(0xFFFFFFFF); // da leggere
  static const _currentColor = Color(0xFF101010); // testo evidenziato
  static const _currentBg = Color(0xFFFFC107); // sfondo parola corrente

  /// Recognizer per il tap sulle parole; rigenerati a ogni build e ripuliti
  /// per evitare leak.
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizerFor(int wordIndex) {
    final r = TapGestureRecognizer()
      ..onTap = () => widget.onWordTap?.call(wordIndex);
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final baseStyle = TextStyle(
      fontSize: widget.fontSize,
      height: 1.5,
      color: _upcomingColor,
      fontWeight: FontWeight.w500,
    );

    final spans = <InlineSpan>[];
    for (final seg in widget.segments) {
      if (!seg.isWord) {
        spans.add(TextSpan(text: seg.text, style: baseStyle));
        continue;
      }
      if (seg.wordIndex == widget.currentIndex) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => widget.onWordTap?.call(seg.wordIndex),
              child: Container(
                key: widget.currentWordKey,
                decoration: BoxDecoration(
                  color: _currentBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  seg.text,
                  style: baseStyle.copyWith(
                    color: _currentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        final read = seg.wordIndex < widget.currentIndex;
        spans.add(TextSpan(
          text: seg.text,
          style: baseStyle.copyWith(
            color: read ? _readColor : _upcomingColor,
          ),
          recognizer:
              widget.onWordTap == null ? null : _recognizerFor(seg.wordIndex),
        ));
      }
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(20, 40, 20, widget.bottomPadding),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}
