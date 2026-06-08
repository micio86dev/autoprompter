import 'package:autoprompter/l10n/app_localizations.dart';
import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/prompt_editor_screen.dart';
import 'package:autoprompter/state/prompt_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

Widget _app(PromptStore store, Prompt prompt) {
  return ChangeNotifierProvider<PromptStore>.value(
    value: store,
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: PromptEditorScreen(prompt: prompt, speech: FakeSpeechService()),
    ),
  );
}

void main() {
  testWidgets('shows the title and reading statistics', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(
      title: 'My title',
      contentMarkdown: '# Title\n\nOne two three',
    );
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.text('My title'), findsOneWidget);
    expect(find.textContaining('words'), findsOneWidget);
  });

  testWidgets('adds a tag', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(title: 'T', contentMarkdown: 'x');
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'urgent,');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'urgent'), findsOneWidget);
  });

  testWidgets('shows the existing tags of the prompt', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt =
        Prompt.create(title: 'T', contentMarkdown: 'x', tags: ['demo']);
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'demo'), findsOneWidget);
  });

  testWidgets('the preview toggle shows the Markdown source', (tester) async {
    final store = PromptStore(FakePromptRepository());
    final prompt = Prompt.create(title: 'T', contentMarkdown: 'hi');
    await tester.pumpWidget(_app(store, prompt));
    await tester.pumpAndSettle();

    expect(find.byType(SelectableText), findsNothing);
    await tester.tap(find.byTooltip('Markdown preview'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
