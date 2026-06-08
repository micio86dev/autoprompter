import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/prompt.dart';
import '../services/markdown_service.dart';
import '../services/speech_service.dart';
import '../services/word_matcher.dart';
import '../widgets/teleprompter_text.dart';

/// Vista di lettura: mostra il prompt e fa autoscroll seguendo la voce oppure
/// a velocità costante. Supporta modalità specchio, riga di lettura regolabile
/// e tap su una parola per riposizionare il punto di lettura.
class TeleprompterScreen extends StatefulWidget {
  const TeleprompterScreen({
    super.key,
    required this.prompt,
    this.speech,
    this.initialFontSize = 32,
    this.initialScrollSpeed = 40,
    this.initialReadingLine = 0.35,
  });

  final Prompt prompt;

  /// Iniettabile nei test; di default usa il riconoscimento vocale reale.
  final SpeechService? speech;

  final double initialFontSize;
  final double initialScrollSpeed;
  final double initialReadingLine;

  @override
  State<TeleprompterScreen> createState() => _TeleprompterScreenState();
}

class _TeleprompterScreenState extends State<TeleprompterScreen>
    with SingleTickerProviderStateMixin {
  late final SpeechService _speech;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentWordKey = GlobalKey();

  late WordMatcher _matcher;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  int _currentIndex = -1;
  bool _listening = false;
  String? _message;

  late double _fontSize;
  late double _scrollSpeed; // px/s in autoscroll
  late double _readingLine; // 0..1, frazione dell'altezza visibile
  bool _autoScroll = false;
  bool _flipH = false;
  bool _flipV = false;

  @override
  void initState() {
    super.initState();
    _speech = widget.speech ?? SttSpeechService();
    _fontSize = widget.initialFontSize;
    _scrollSpeed = widget.initialScrollSpeed;
    _readingLine = widget.initialReadingLine;
    final plain = MarkdownService.markdownToPlainText(widget.prompt.contentMarkdown);
    _matcher = WordMatcher(plain);
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _speech.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- voce ---

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      return;
    }
    setState(() => _message = null);
    final ok = await _speech.start(
      localeId: widget.prompt.localeId,
      onWords: _onWords,
      onListeningChanged: (listening) {
        if (mounted) setState(() => _listening = listening);
      },
      onError: (msg) {
        if (mounted) setState(() => _message = msg);
      },
    );
    if (!ok && mounted) {
      setState(() => _listening = false);
    }
  }

  void _onWords(List<String> words) {
    final changed = _matcher.consume(words);
    if (changed && mounted) {
      setState(() => _currentIndex = _matcher.currentIndex);
      // In autoscroll lo scorrimento è guidato dal timer, non dalla voce.
      if (!_autoScroll) _scrollToCurrent();
    }
  }

  void _onWordTap(int index) {
    _matcher.setCurrentWordIndex(index);
    setState(() => _currentIndex = _matcher.currentIndex);
    _scrollToCurrent();
  }

  void _scrollToCurrent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentWordKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: _readingLine,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- autoscroll a velocità costante ---

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) return;
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = (_scrollController.offset + _scrollSpeed * dt).clamp(0.0, max);
    _scrollController.jumpTo(next);
    if (next >= max) {
      _ticker.stop();
      if (mounted) setState(() => _autoScroll = false);
    }
  }

  // --- controlli ---

  void _reset() {
    _matcher.reset();
    setState(() => _currentIndex = -1);
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _changeFont(double delta) {
    setState(() => _fontSize = (_fontSize + delta).clamp(18.0, 72.0));
  }

  void _openControls() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            void update(VoidCallback fn) {
              setSheet(fn);
              setState(fn);
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Impostazioni lettura',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Specchio orizzontale',
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text('Per il vetro del teleprompter',
                          style: TextStyle(color: Colors.white54)),
                      value: _flipH,
                      onChanged: (v) => update(() => _flipH = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Specchio verticale',
                          style: TextStyle(color: Colors.white)),
                      value: _flipV,
                      onChanged: (v) => update(() => _flipV = v),
                    ),
                    const Divider(color: Colors.white24),
                    _SliderTile(
                      label: 'Dimensione testo',
                      value: _fontSize,
                      min: 18,
                      max: 72,
                      display: _fontSize.round().toString(),
                      onChanged: (v) => update(() => _fontSize = v),
                    ),
                    _SliderTile(
                      label: 'Velocità autoscroll',
                      value: _scrollSpeed,
                      min: 10,
                      max: 200,
                      display: '${_scrollSpeed.round()} px/s',
                      onChanged: (v) => update(() => _scrollSpeed = v),
                    ),
                    _SliderTile(
                      label: 'Posizione riga di lettura',
                      value: _readingLine,
                      min: 0.1,
                      max: 0.6,
                      display: '${(_readingLine * 100).round()}%',
                      onChanged: (v) => update(() => _readingLine = v),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final empty = _matcher.wordCount == 0;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.prompt.title.isEmpty ? 'Senza titolo' : widget.prompt.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Riduci testo',
            icon: const Icon(Icons.text_decrease),
            onPressed: () => _changeFont(-2),
          ),
          IconButton(
            tooltip: 'Ingrandisci testo',
            icon: const Icon(Icons.text_increase),
            onPressed: () => _changeFont(2),
          ),
          IconButton(
            tooltip: 'Ricomincia',
            icon: const Icon(Icons.restart_alt),
            onPressed: _reset,
          ),
          IconButton(
            tooltip: 'Impostazioni lettura',
            icon: const Icon(Icons.tune),
            onPressed: _openControls,
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: empty ? 0 : _matcher.progress,
            backgroundColor: Colors.white12,
            color: const Color(0xFFFFC107),
            minHeight: 3,
          ),
          if (_message != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade900,
              padding: const EdgeInsets.all(12),
              child: Text(
                _message!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: empty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Questo prompt è vuoto. Modificalo per aggiungere del testo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  )
                : _buildReadingArea(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: empty ? null : _buildControls(),
    );
  }

  Widget _buildReadingArea() {
    final text = TeleprompterText(
      segments: _matcher.segments,
      currentIndex: _currentIndex,
      fontSize: _fontSize,
      currentWordKey: _currentWordKey,
      scrollController: _scrollController,
      onWordTap: _onWordTap,
    );
    final mirrored = (_flipH || _flipV)
        ? Transform.flip(flipX: _flipH, flipY: _flipV, child: text)
        : text;
    return Stack(
      children: [
        Positioned.fill(child: mirrored),
        // Guida orizzontale della riga di lettura (non specchiata).
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, c) => Stack(
                children: [
                  Positioned(
                    top: c.maxHeight * _readingLine,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: const Color(0x33FFC107),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'autoscroll',
          backgroundColor: _autoScroll ? Colors.red : Colors.white24,
          foregroundColor: Colors.white,
          onPressed: _toggleAutoScroll,
          child: Icon(_autoScroll ? Icons.pause : Icons.swipe_vertical),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'voice',
          backgroundColor: _listening ? Colors.red : const Color(0xFFFFC107),
          foregroundColor: Colors.black,
          onPressed: _toggleListening,
          icon: Icon(_listening ? Icons.stop : Icons.mic),
          label: Text(_listening ? 'Ferma' : 'Avvia lettura'),
        ),
      ],
    );
  }
}

/// Riga con etichetta, valore corrente e slider, in stile scuro.
class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text(display, style: const TextStyle(color: Colors.white54)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
