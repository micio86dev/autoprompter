import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../l10n/app_localizations.dart';
import '../models/prompt.dart';
import '../services/markdown_service.dart';
import '../services/permission_service.dart';
import '../services/speech_service.dart';
import '../services/word_matcher.dart';
import '../widgets/teleprompter_text.dart';

/// Reading view: shows the prompt and autoscrolls either following the voice or
/// at a constant speed. Supports mirror mode, an adjustable reading line and
/// tapping a word to reposition the reading point.
class TeleprompterScreen extends StatefulWidget {
  const TeleprompterScreen({
    super.key,
    required this.prompt,
    this.speech,
    this.permissions,
    this.initialFontSize = 32,
    this.initialScrollSpeed = 40,
    this.initialReadingLine = 0.35,
  });

  final Prompt prompt;

  /// Injectable in tests; defaults to the real speech recognizer.
  final SpeechService? speech;

  /// Injectable in tests; defaults to the real microphone permission handler.
  final MicPermissionService? permissions;

  final double initialFontSize;
  final double initialScrollSpeed;
  final double initialReadingLine;

  @override
  State<TeleprompterScreen> createState() => _TeleprompterScreenState();
}

class _TeleprompterScreenState extends State<TeleprompterScreen>
    with SingleTickerProviderStateMixin {
  late final SpeechService _speech;
  late final MicPermissionService _permissions;
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
  late double _readingLine; // 0..1, fraction of the visible height
  bool _autoScroll = false;
  bool _flipH = false;
  bool _flipV = false;

  @override
  void initState() {
    super.initState();
    _speech = widget.speech ?? SttSpeechService();
    _permissions = widget.permissions ?? const PermissionHandlerMicService();
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

  // --- voice ---

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      return;
    }
    final l10n = AppLocalizations.of(context);
    // Explain why we need the microphone (in the app's language) before the OS
    // permission prompt, and don't start listening unless it's granted.
    if (!await _ensureMicPermission(l10n)) return;
    if (!mounted) return;
    setState(() => _message = null);
    final ok = await _speech.start(
      localeId: widget.prompt.localeId,
      onWords: _onWords,
      onListeningChanged: (listening) {
        if (mounted) {
          setState(() {
            _listening = listening;
            // Clear any stale error banner once recognition is active again.
            if (listening) _message = null;
          });
        }
      },
      onError: (msg) {
        if (mounted) setState(() => _message = msg);
      },
    );
    if (!ok && mounted) {
      setState(() {
        _listening = false;
        _message = l10n.speechUnavailable;
      });
    }
  }

  /// Ensures the microphone permission is granted, showing a localized rationale
  /// before the OS prompt. Returns true only if listening may proceed.
  Future<bool> _ensureMicPermission(AppLocalizations l10n) async {
    if (await _permissions.status() == MicPermissionStatus.granted) return true;
    if (!mounted) return false;

    final proceed = await _showMicRationale(l10n);
    if (proceed != true) return false;

    final result = await _permissions.request();
    if (result == MicPermissionStatus.granted) return true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.micPermissionDenied),
          action: SnackBarAction(
            label: l10n.openSettings,
            onPressed: _permissions.openSettings,
          ),
        ),
      );
    }
    return false;
  }

  Future<bool?> _showMicRationale(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.mic),
        title: Text(l10n.micPermissionTitle),
        content: Text(l10n.micPermissionRationale),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
  }

  void _onWords(List<String> words) {
    final changed = _matcher.consume(words);
    if (changed && mounted) {
      setState(() => _currentIndex = _matcher.currentIndex);
      // In autoscroll, scrolling is driven by the timer, not by the voice.
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

  // --- constant-speed autoscroll ---

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

  // --- controls ---

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
    final l10n = AppLocalizations.of(context);
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
                    Text(l10n.readingSettings,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.mirrorHorizontal,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(l10n.mirrorHorizontalSubtitle,
                          style: const TextStyle(color: Colors.white54)),
                      value: _flipH,
                      onChanged: (v) => update(() => _flipH = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.mirrorVertical,
                          style: const TextStyle(color: Colors.white)),
                      value: _flipV,
                      onChanged: (v) => update(() => _flipV = v),
                    ),
                    const Divider(color: Colors.white24),
                    _SliderTile(
                      label: l10n.textSize,
                      value: _fontSize,
                      min: 18,
                      max: 72,
                      display: _fontSize.round().toString(),
                      onChanged: (v) => update(() => _fontSize = v),
                    ),
                    _SliderTile(
                      label: l10n.autoscrollSpeed,
                      value: _scrollSpeed,
                      min: 10,
                      max: 200,
                      display: '${_scrollSpeed.round()} px/s',
                      onChanged: (v) => update(() => _scrollSpeed = v),
                    ),
                    _SliderTile(
                      label: l10n.readingLinePosition,
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
    final l10n = AppLocalizations.of(context);
    final empty = _matcher.wordCount == 0;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.prompt.title.isEmpty ? l10n.untitled : widget.prompt.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: l10n.decreaseText,
            icon: const Icon(Icons.text_decrease),
            onPressed: () => _changeFont(-2),
          ),
          IconButton(
            tooltip: l10n.increaseText,
            icon: const Icon(Icons.text_increase),
            onPressed: () => _changeFont(2),
          ),
          IconButton(
            tooltip: l10n.restart,
            icon: const Icon(Icons.restart_alt),
            onPressed: _reset,
          ),
          IconButton(
            tooltip: l10n.readingSettings,
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
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.emptyPromptMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 18),
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
        // Horizontal guide for the reading line (not mirrored).
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
    final l10n = AppLocalizations.of(context);
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
          label: Text(_listening ? l10n.stop : l10n.startReading),
        ),
      ],
    );
  }
}

/// Row with a label, current value and slider, in a dark style.
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
