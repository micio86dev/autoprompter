import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/teleprompter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

Widget _app(Prompt prompt, FakeSpeechService speech) {
  return MaterialApp(home: TeleprompterScreen(prompt: prompt, speech: speech));
}

double _progress(WidgetTester tester) {
  final bar =
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
  return bar.value ?? 0;
}

void main() {
  testWidgets('seguendo la voce mockata avanza fino a fine testo',
      (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(
      title: 'Demo',
      contentMarkdown: 'uno due tre quattro',
    );
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    expect(find.text('Avvia lettura'), findsOneWidget);
    expect(_progress(tester), 0);

    await tester.tap(find.text('Avvia lettura'));
    await tester.pumpAndSettle();
    expect(find.text('Ferma'), findsOneWidget);
    expect(speech.lastLocaleId, 'it_IT');

    speech.emit(['uno', 'due', 'tre', 'quattro']);
    await tester.pumpAndSettle();

    expect(_progress(tester), 1.0); // 4/4 parole
  });

  testWidgets('avanzamento parziale aggiorna il progresso', (tester) async {
    final speech = FakeSpeechService();
    final prompt =
        Prompt.create(contentMarkdown: 'uno due tre quattro');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avvia lettura'));
    await tester.pumpAndSettle();

    speech.emit(['uno', 'due']);
    await tester.pumpAndSettle();
    expect(_progress(tester), closeTo(0.5, 0.0001)); // 2/4
  });

  testWidgets('prompt vuoto mostra il messaggio e nessun controllo',
      (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(contentMarkdown: '');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    expect(find.textContaining('Questo prompt è vuoto'), findsOneWidget);
    expect(find.text('Avvia lettura'), findsNothing);
  });

  testWidgets('il pannello impostazioni espone gli switch specchio',
      (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(contentMarkdown: 'uno due tre');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Specchio orizzontale'), findsOneWidget);
    expect(find.text('Velocità autoscroll'), findsOneWidget);
    expect(find.text('Posizione riga di lettura'), findsOneWidget);
  });
}
