import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/prompt_editor_screen.dart';
import 'package:autoprompter/state/prompt_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

Widget _app(PromptStore store, Prompt prompt) {
  return ChangeNotifierProvider<PromptStore>.value(
    value: store,
    child: MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it'), Locale('en')],
      home: PromptEditorScreen(prompt: prompt, speech: FakeSpeechService()),
    ),
  );
}

void main() {
  testWidgets('mostra titolo e statistiche di lettura', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(
      title: 'Mio titolo',
      contentMarkdown: '# Titolo\n\nUno due tre',
    );
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.text('Mio titolo'), findsOneWidget);
    expect(find.textContaining('parole'), findsOneWidget);
  });

  testWidgets('aggiunge un tag', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(title: 'T', contentMarkdown: 'x');
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'urgente,');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'urgente'), findsOneWidget);
  });

  testWidgets('mostra i tag esistenti del prompt', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt =
        Prompt.create(title: 'T', contentMarkdown: 'x', tags: ['demo']);
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'demo'), findsOneWidget);
  });

  testWidgets('il toggle anteprima mostra il sorgente Markdown',
      (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(title: 'T', contentMarkdown: 'ciao');
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.byType(SelectableText), findsNothing);
    await tester.tap(find.byTooltip('Anteprima Markdown'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
