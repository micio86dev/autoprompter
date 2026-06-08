import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// A language available for speech recognition.
class SpeechLocale {
  const SpeechLocale(this.id, this.name);
  final String id;
  final String name;
}

/// Speech service contract, so the teleprompter can receive a fake
/// implementation in tests instead of the real recognizer.
abstract class SpeechService {
  bool get isAvailable;
  bool get isListening;

  /// Languages available on the device.
  Future<List<SpeechLocale>> locales();

  /// Starts continuous listening. Returns false if unavailable/denied.
  Future<bool> start({
    required String localeId,
    required void Function(List<String> newWords) onWords,
    void Function(bool listening)? onListeningChanged,
    void Function(String message)? onError,
  });

  /// Stops listening.
  Future<void> stop();

  Future<void> dispose();
}

/// Real implementation backed by `speech_to_text`: continuous listening,
/// automatic session restart and emission of only the new words.
class SttSpeechService implements SpeechService {
  final SpeechToText _stt = SpeechToText();

  bool _available = false;
  bool _wantListening = false;
  bool _restarting = false;
  String _localeId = 'it_IT';

  /// Delay before re-listening, to let the native engine release the previous
  /// session (restarting immediately often fails with a "busy" error).
  static const Duration _restartDelay = Duration(milliseconds: 400);

  /// Number of words already emitted for the current listening session.
  int _emittedWordCount = 0;

  void Function(List<String> newWords)? _onWords;
  void Function(bool listening)? _onListeningChanged;
  void Function(String message)? _onError;

  @override
  bool get isAvailable => _available;
  @override
  bool get isListening => _stt.isListening;

  /// Initializes the engine (requires microphone/recognition permissions).
  Future<bool> initialize() async {
    if (_available) return true;
    _available = await _stt.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
      debugLogging: false,
    );
    return _available;
  }

  /// Speech errors are either transient or permanent. Transient ones
  /// (e.g. `error_no_match`, `error_speech_timeout`) are routine during
  /// continuous dictation — we must NOT surface them as a UI error. Instead we
  /// schedule a restart, because an error can leave the engine stopped without
  /// a following `done`/`notListening` status (which is what made it freeze
  /// until the user manually stopped and resumed). Only permanent errors
  /// (e.g. permission denied, recognizer unavailable) are reported and stop us.
  void _handleError(SpeechRecognitionError error) {
    if (error.permanent) {
      _onError?.call(error.errorMsg);
      return;
    }
    if (_wantListening) _scheduleRestart();
  }

  @override
  Future<List<SpeechLocale>> locales() async {
    if (!_available) {
      final ok = await initialize();
      if (!ok) return [];
    }
    final list = await _stt.locales();
    final result = list.map((l) => SpeechLocale(l.localeId, l.name)).toList();
    result.sort((a, b) => a.name.compareTo(b.name));
    return result;
  }

  @override
  Future<bool> start({
    required String localeId,
    required void Function(List<String> newWords) onWords,
    void Function(bool listening)? onListeningChanged,
    void Function(String message)? onError,
  }) async {
    _onWords = onWords;
    _onListeningChanged = onListeningChanged;
    _onError = onError;
    _localeId = localeId;

    final ok = await initialize();
    if (!ok) {
      // The caller (teleprompter) shows a localized "unavailable" message.
      return false;
    }

    _wantListening = true;
    _restarting = false;
    await _listen();
    return true;
  }

  @override
  Future<void> stop() async {
    _wantListening = false;
    _restarting = false;
    await _stt.stop();
    _onListeningChanged?.call(false);
  }

  @override
  Future<void> dispose() async {
    _wantListening = false;
    await _stt.cancel();
  }

  Future<void> _listen() async {
    // Don't stack a second session on top of an active one.
    if (!_wantListening || _stt.isListening) return;
    _emittedWordCount = 0;
    try {
      await _stt.listen(
        onResult: _handleResult,
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 30),
        ),
      );
      _onListeningChanged?.call(true);
    } catch (_) {
      // The engine wasn't ready (e.g. still tearing down the previous session).
      // Retry shortly so listening recovers on its own.
      _scheduleRestart();
    }
  }

  /// Schedules a single delayed restart, de-duplicated via [_restarting] so
  /// overlapping triggers (status + error) collapse into one re-listen.
  void _scheduleRestart() {
    if (!_wantListening || _restarting) return;
    _restarting = true;
    Future.delayed(_restartDelay, () {
      _restarting = false;
      if (_wantListening && !_stt.isListening) _listen();
    });
  }

  void _handleResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    // The recognizer sometimes revises its hypothesis and shortens the text: in
    // that case it has restarted, so we realign the count to avoid losing the
    // following words.
    if (words.length < _emittedWordCount) {
      _emittedWordCount = 0;
    }
    if (words.length > _emittedWordCount) {
      final fresh = words.sublist(_emittedWordCount);
      _emittedWordCount = words.length;
      _onWords?.call(fresh);
    }
  }

  void _handleStatus(String status) {
    final listening = status == SpeechToText.listeningStatus;
    _onListeningChanged?.call(listening);

    // Native sessions end after pauses/timeouts: restart (with a small delay)
    // if the user still wants to listen, so dictation stays continuous.
    final stopped = status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus;
    if (stopped && _wantListening) {
      _scheduleRestart();
    }
  }
}
