import 'dart:math' as math;

/// Un segmento di testo: una parola (evidenziabile) oppure un separatore
/// (spazi, punteggiatura, ritorni a capo) da rendere così com'è.
class TextSegment {
  TextSegment({
    required this.text,
    required this.isWord,
    required this.wordIndex,
  });

  final String text;
  final bool isWord;

  /// Indice della parola (0-based) tra le sole parole; -1 per i separatori.
  final int wordIndex;
}

/// Una parola riconoscibile, con la sua forma normalizzata per il confronto.
class _Word {
  _Word(this.normalized);
  final String normalized;
}

/// Allinea le parole pronunciate (dal riconoscimento vocale) al testo del
/// prompt, mantenendo aggiornato un indice "parola corrente" man mano che si
/// legge.
///
/// È pensato per essere robusto alla lettura reale, non perfetta:
///  - parole **saltate** nel copione,
///  - parole **sbagliate o cambiate**,
///  - parole **fuori copione** (intercalari, commenti),
///  - **pause** e ripartenze in un punto diverso.
///
/// Strategia: tiene un piccolo buffer delle ultime parole pronunciate e, a ogni
/// nuova parola, cerca la posizione del testo meglio **confermata dal contesto
/// recente** — prima in una finestra locale (in avanti e un po' all'indietro),
/// poi, se non trova nulla di solido, con una ricerca **globale** che permette
/// di riagganciarsi sempre dopo un salto ampio o una pausa.
class WordMatcher {
  WordMatcher(String text, {this.window = 30}) {
    _tokenize(text);
  }

  /// Quante parole **avanti** cercare nella finestra locale.
  final int window;

  /// Quante parole **indietro** tollerare localmente (riletture / falsi salti).
  static const int _back = 6;

  /// Quante parole recenti usare come "contesto" per confermare la posizione.
  static const int _context = 4;

  /// Quante parole pronunciate tenere in memoria.
  static const int _recentCap = 8;

  final List<TextSegment> segments = [];
  final List<_Word> _words = [];

  /// Ultime parole pronunciate (normalizzate), usate per riagganciare la
  /// posizione anche dopo salti o pause.
  final List<String> _recent = [];

  /// Indice dell'ultima parola riconosciuta (-1 = niente ancora).
  int currentIndex = -1;

  int get wordCount => _words.length;

  /// Numero di parole già lette.
  int get matchedCount => currentIndex + 1;

  /// Avanzamento nella lettura, da 0.0 a 1.0.
  double get progress =>
      _words.isEmpty ? 0 : (matchedCount / _words.length).clamp(0.0, 1.0);

  void reset() {
    currentIndex = -1;
    _recent.clear();
  }

  /// Imposta manualmente la posizione di lettura (es. tap su una parola).
  /// Azzera il contesto recente, così l'allineamento vocale riprende da qui.
  void setCurrentWordIndex(int index) {
    if (_words.isEmpty) return;
    currentIndex = index.clamp(-1, _words.length - 1);
    _recent.clear();
  }

  /// Consuma le parole pronunciate, riagganciando [currentIndex] alla posizione
  /// più probabile nel testo. Ritorna true se l'indice è cambiato.
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

  // --- riaggancio ---

  /// Quanto bene il contesto recente si allinea se l'**ultima** parola
  /// pronunciata corrisponde alla parola del prompt all'indice [i].
  ///
  /// Ritorna -1 se l'ultima parola non corrisponde affatto a `i`; altrimenti un
  /// punteggio: 2 di base, +1 per ogni parola recente precedente ritrovata tra
  /// le parole del prompt subito prima di `i` (tolleranza ai salti).
  int _score(int i) {
    if (i < 0 || i >= _words.length) return -1;
    if (!_matches(_recent.last, _words[i].normalized)) return -1;
    var score = 2; // l'ultima parola pronunciata corrisponde a `i`
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

  /// Regole di accettazione di un candidato, calibrate per evitare scatti:
  ///  - avanzamento ravvicinato (1..4 parole): basta la corrispondenza;
  ///  - salto in avanti più ampio: serve almeno una conferma dal contesto;
  ///  - movimento all'indietro o lontano: serve un contesto forte.
  bool _acceptable(int i, int score) {
    if (score < 2) return false;
    final step = i - currentIndex;
    if (step >= 1 && step <= 4) return true;
    if (step > 4 && step <= window) return score >= 3;
    return score >= 4;
  }

  void _advance() {
    if (_words.isEmpty) return;

    // 1) Ricerca locale: attorno alla posizione corrente, in avanti e un po'
    //    all'indietro. A parità di punteggio si preferisce la posizione più
    //    vicina in avanti, per non scavalcare frasi ripetute.
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

    // 2) Riaggancio globale: dopo un salto ampio o una pausa, cerca ovunque la
    //    posizione meglio confermata dal contesto recente. La soglia alta evita
    //    salti casuali su una singola parola comune.
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

  /// Ordina i candidati a pari punteggio: prima quelli in avanti e più vicini.
  int _forwardBias(int i) {
    final step = i - currentIndex;
    return step >= 1 ? step : 1000 - step;
  }

  // --- interni ---

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
    // Corrispondenza per prefisso (utile con risultati parziali).
    if (spoken.length >= 4 && target.startsWith(spoken)) return true;
    // Tolleranza agli errori per parole abbastanza lunghe.
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
      // Tiene solo lettere e cifre.
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
