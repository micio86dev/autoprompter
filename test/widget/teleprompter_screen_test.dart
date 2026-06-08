import 'package:autoprompter/l10n/app_localizations.dart';
import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/teleprompter_screen.dart';
import 'package:autoprompter/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

Widget _app(
  Prompt prompt,
  FakeSpeechService speech, {
  MicPermissionService? permissions,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: TeleprompterScreen(
      prompt: prompt,
      speech: speech,
      permissions: permissions ?? FakeMicPermissionService(),
    ),
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

  testWidgets('shows a localized mic rationale, then starts after granting',
      (tester) async {
    final speech = FakeSpeechService();
    final perms = FakeMicPermissionService(
      initial: MicPermissionStatus.denied,
      afterRequest: MicPermissionStatus.granted,
    );
    final prompt = Prompt.create(contentMarkdown: 'one two three');
    await tester.pumpWidget(_app(prompt, speech, permissions: perms));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();

    // Rationale dialog shown before any OS request; not started yet.
    expect(find.text('Microphone access'), findsOneWidget);
    expect(perms.requestCount, 0);
    expect(speech.lastLocaleId, isNull);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(perms.requestCount, 1);
    expect(find.text('Stop'), findsOneWidget);
    expect(speech.lastLocaleId, 'it_IT');
  });

  testWidgets('canceling the mic rationale does not start listening',
      (tester) async {
    final speech = FakeSpeechService();
    final perms =
        FakeMicPermissionService(initial: MicPermissionStatus.denied);
    final prompt = Prompt.create(contentMarkdown: 'one two three');
    await tester.pumpWidget(_app(prompt, speech, permissions: perms));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start reading'));
    await tester.pumpAndSettle();
    expect(find.text('Microphone access'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(perms.requestCount, 0);
    expect(speech.lastLocaleId, isNull);
    expect(find.text('Start reading'), findsOneWidget);
  });
}
