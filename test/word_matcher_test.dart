import 'package:autoprompter/services/word_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WordMatcher tokenization', () {
    test('conta correttamente le parole', () {
      final m = WordMatcher('Ciao mondo, come va?');
      expect(m.wordCount, 4); // Ciao, mondo, come, va
    });

    test('conserva i separatori nei segmenti', () {
      final m = WordMatcher('a b');
      final rebuilt = m.segments.map((s) => s.text).join();
      expect(rebuilt, 'a b');
      expect(m.segments.where((s) => s.isWord).length, 2);
    });

    test('gestisce le parole con apostrofo come un unico token', () {
      final m = WordMatcher("l'altro giorno");
      expect(m.wordCount, 2);
    });
  });

  group('WordMatcher avanzamento', () {
    test('parte da -1', () {
      final m = WordMatcher('uno due tre');
      expect(m.currentIndex, -1);
      expect(m.matchedCount, 0);
    });

    test('avanza con parole esatte in sequenza', () {
      final m = WordMatcher('uno due tre quattro');
      m.consume(['uno']);
      expect(m.currentIndex, 0);
      m.consume(['due', 'tre']);
      expect(m.currentIndex, 2);
    });

    test('salta una parola entro la finestra', () {
      final m = WordMatcher('alfa beta gamma delta');
      m.consume(['alfa']);
      // Salta "beta" e dice direttamente "gamma".
      m.consume(['gamma']);
      expect(m.currentIndex, 2);
    });

    test('ignora parole non presenti senza arretrare', () {
      final m = WordMatcher('uno due tre');
      m.consume(['uno']);
      m.consume(['xyzqwerty']);
      expect(m.currentIndex, 0);
    });

    test('tollera piccoli errori di riconoscimento (Levenshtein)', () {
      final m = WordMatcher('benvenuto teleprompter');
      // "telepromter" -> "teleprompter" (1 carattere di differenza)
      m.consume(['benvenuto', 'telepromter']);
      expect(m.currentIndex, 1);
    });

    test('è insensibile ad accenti e maiuscole', () {
      final m = WordMatcher('Perché però');
      m.consume(['perche', 'pero']);
      expect(m.currentIndex, 1);
    });

    test('corrispondenza per prefisso (risultati parziali)', () {
      final m = WordMatcher('registrazione completata');
      m.consume(['regist']);
      expect(m.currentIndex, 0);
    });

    test('progress e reset', () {
      final m = WordMatcher('uno due tre quattro');
      m.consume(['uno', 'due']);
      expect(m.progress, closeTo(0.5, 0.0001));
      m.reset();
      expect(m.currentIndex, -1);
      expect(m.progress, 0);
    });

    test('non supera la fine del testo', () {
      final m = WordMatcher('uno due');
      m.consume(['uno', 'due', 'tre', 'quattro']);
      expect(m.currentIndex, 1);
    });

    test('setCurrentWordIndex riposiziona e poi prosegue da lì', () {
      final m = WordMatcher('uno due tre quattro cinque');
      m.setCurrentWordIndex(2); // tap su "tre"
      expect(m.currentIndex, 2);
      m.consume(['quattro']);
      expect(m.currentIndex, 3);
    });

    test('setCurrentWordIndex limita ai bordi', () {
      final m = WordMatcher('uno due tre');
      m.setCurrentWordIndex(99);
      expect(m.currentIndex, 2);
      m.setCurrentWordIndex(-5);
      expect(m.currentIndex, -1);
    });
  });

  group('WordMatcher robustezza (lettura imperfetta)', () {
    // 40 parole distinte (niente collisioni di Levenshtein).
    // Indici: 0 mela ... 20 rosso ... 30 lunedi ... 35 sabato ... 39 marzo
    const text =
        'mela banana ciliegia fragola arancia limone pesca uva kiwi melone '
        'cane gatto cavallo coniglio tartaruga delfino aquila falco lupo volpe '
        'rosso verde blu giallo viola arancione marrone grigio celeste indaco '
        'lunedi martedi mercoledi giovedi venerdi sabato domenica gennaio febbraio marzo';

    test('recupera dopo un salto oltre la finestra (ricerca globale)', () {
      final m = WordMatcher(text);
      m.consume(['mela', 'banana', 'ciliegia']);
      expect(m.currentIndex, 2);
      // Salta avanti di oltre 30 parole e legge da lì: si riaggancia.
      m.consume(['giovedi', 'venerdi', 'sabato']);
      expect(m.currentIndex, 35);
    });

    test('riparte dopo una pausa in un punto diverso', () {
      final m = WordMatcher(text);
      m.consume(['mela', 'banana']);
      m.consume(['rosso', 'verde', 'blu']);
      expect(m.currentIndex, 22);
    });

    test('le parole fuori copione non bloccano né spostano il cursore', () {
      final m = WordMatcher(text);
      m.consume(['mela', 'banana']);
      m.consume(['ehm', 'aspetta', 'dunque']); // intercalari assenti dal testo
      expect(m.currentIndex, 1);
      m.consume(['ciliegia']); // riprende normalmente
      expect(m.currentIndex, 2);
    });

    test('continua nonostante una parola cambiata', () {
      final m = WordMatcher(text);
      m.consume(['mela', 'banana']);
      m.consume(['pippo']); // doveva essere "ciliegia"
      m.consume(['fragola', 'arancia']);
      expect(m.currentIndex, 4);
    });

    test('recupera se il cursore era finito troppo avanti', () {
      final m = WordMatcher(text);
      // Cursore spinto avanti per errore.
      m.consume(['lunedi', 'martedi', 'mercoledi']);
      expect(m.currentIndex, 32);
      // In realtà si stava leggendo dall'inizio: deve tornare indietro.
      m.consume(['mela', 'banana', 'ciliegia']);
      expect(m.currentIndex, 2);
    });
  });
}
