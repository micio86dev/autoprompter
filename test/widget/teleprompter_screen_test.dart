import 'package:autoprompter/l10n/app_localizations.dart';
import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/teleprompter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

Widget _app(Prompt prompt, FakeSpeechService speech) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: TeleprompterScreen(prompt: prompt, speech: speech),
  );
}

double _progress(WidgetTester tester) {
  final bar =
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
  return bar.value ?? 0;
}

void main() {
  testWidgets('following the mocked voice advances to the end of the text',
      (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(
      title: 'Demo',
      contentMarkdown: 'one two three four',
    );
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    expect(find.text('Start reading'), findsOneWidget);
    expect(_progress(tester), 0);

    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();
    expect(find.text('Stop'), findsOneWidget);
    expect(speech.lastLocaleId, 'it_IT');

    speech.emit(['one', 'two', 'three', 'four']);
    await tester.pumpAndSettle();

    expect(_progress(tester), 1.0); // 4/4 words
  });

  testWidgets('partial progress updates the progress bar', (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(contentMarkdown: 'one two three four');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();

    speech.emit(['one', 'two']);
    await tester.pumpAndSettle();
    expect(_progress(tester), closeTo(0.5, 0.0001)); // 2/4
  });

  testWidgets('an empty prompt shows the message and no controls',
      (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(contentMarkdown: '');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    expect(find.textContaining('This prompt is empty'), findsOneWidget);
    expect(find.text('Start reading'), findsNothing);
  });

  testWidgets('the settings panel exposes the mirror switches', (tester) async {
    final speech = FakeSpeechService();
    final prompt = Prompt.create(contentMarkdown: 'one two three');
    await tester.pumpWidget(_app(prompt, speech));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Horizontal mirror'), findsOneWidget);
    expect(find.text('Autoscroll speed'), findsOneWidget);
    expect(find.text('Reading line position'), findsOneWidget);
  });
}
