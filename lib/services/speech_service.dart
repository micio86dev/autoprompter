import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Una lingua disponibile per il riconoscimento vocale.
class SpeechLocale {
  const SpeechLocale(this.id, this.name);
  final String id;
  final String name;
}

/// Contratto del servizio vocale, così il teleprompter può ricevere un'impl.
/// finta nei test al posto del riconoscimento reale.
abstract class SpeechService {
  bool get isAvailable;
  bool get isListening;

  /// Lingue disponibili sul dispositivo.
  Future<List<SpeechLocale>> locales();

  /// Avvia l'ascolto continuo. Ritorna false se non disponibile/negato.
  Future<bool> start({
    required String localeId,
    required void Function(List<String> newWords) onWords,
    void Function(bool listening)? onListeningChanged,
    void Function(String message)? onError,
  });

  /// Ferma l'ascolto.
  Future<void> stop();

  Future<void> dispose();
}

/// Implementazione reale basata su `speech_to_text`: ascolto continuo,
/// riavvio automatico delle sessioni ed emissione delle sole parole nuove.
class SttSpeechService implements SpeechService {
  final SpeechToText _stt = SpeechToText();

  bool _available = false;
  bool _wantListening = false;
  String _localeId = 'it_IT';

  /// Numero di parole già emesse per la sessione di ascolto corrente.
  int _emittedWordCount = 0;

  void Function(List<String> newWords)? _onWords;
  void Function(bool listening)? _onListeningChanged;
  void Function(String message)? _onError;

  @override
  bool get isAvailable => _available;
  @override
  bool get isListening => _stt.isListening;

  /// Inizializza il motore (richiede i permessi di microfono/riconoscimento).
  Future<bool> initialize() async {
    if (_available) return true;
    _available = await _stt.initialize(
      onStatus: _handleStatus,
      onError: (e) => _onError?.call(e.errorMsg),
      debugLogging: false,
    );
    return _available;
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
      _onError?.call('Riconoscimento vocale non disponibile su questo '
          'dispositivo o permesso microfono negato.');
      return false;
    }

    _wantListening = true;
    await _listen();
    return true;
  }

  @override
  Future<void> stop() async {
    _wantListening = false;
    await _stt.stop();
    _onListeningChanged?.call(false);
  }

  @override
  Future<void> dispose() async {
    _wantListening = false;
    await _stt.cancel();
  }

  Future<void> _listen() async {
    _emittedWordCount = 0;
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
  }

  void _handleResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    // Il riconoscitore a volte rivede l'ipotesi e accorcia il testo: in quel
    // caso è ripartito da capo, quindi riallineiamo il conteggio per non
    // perdere le parole successive.
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

    // Le sessioni native terminano dopo pause/timeout: riavvia se l'utente
    // vuole ancora ascoltare, così la dettatura è continua.
    final stopped = status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus;
    if (stopped && _wantListening) {
      _listen();
    }
  }
}
