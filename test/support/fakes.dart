import 'package:autoprompter/data/prompt_repository.dart';
import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/services/speech_service.dart';

/// Repository in memoria per i test (sostituisce sqflite).
class FakePromptRepository implements PromptRepository {
  FakePromptRepository([List<Prompt> seed = const []]) {
    for (final p in seed) {
      _store[p.id] = p;
    }
  }

  final Map<String, Prompt> _store = {};

  @override
  Future<List<Prompt>> getAll() async {
    final list = _store.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<Prompt?> getById(String id) async => _store[id];

  @override
  Future<void> upsert(Prompt prompt) async => _store[prompt.id] = prompt;

  @override
  Future<void> delete(String id) async => _store.remove(id);
}

/// Servizio vocale finto: cattura le callback e permette ai test di "dettare"
/// parole con [emit], senza toccare i canali della piattaforma.
class FakeSpeechService implements SpeechService {
  void Function(List<String>)? _onWords;
  void Function(bool)? _onListeningChanged;
  bool _listening = false;
  bool startResult = true;
  String? lastLocaleId;

  @override
  bool get isAvailable => true;
  @override
  bool get isListening => _listening;

  @override
  Future<List<SpeechLocale>> locales() async =>
      const [SpeechLocale('it_IT', 'Italiano (Italia)')];

  @override
  Future<bool> start({
    required String localeId,
    required void Function(List<String> newWords) onWords,
    void Function(bool listening)? onListeningChanged,
    void Function(String message)? onError,
  }) async {
    lastLocaleId = localeId;
    if (!startResult) {
      onError?.call('non disponibile');
      return false;
    }
    _onWords = onWords;
    _onListeningChanged = onListeningChanged;
    _listening = true;
    onListeningChanged?.call(true);
    return true;
  }

  @override
  Future<void> stop() async {
    _listening = false;
    _onListeningChanged?.call(false);
  }

  @override
  Future<void> dispose() async {
    _listening = false;
  }

  /// Simula il riconoscimento di nuove parole.
  void emit(List<String> words) => _onWords?.call(words);
}
