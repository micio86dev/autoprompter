import 'package:autoprompter/models/prompt.dart';
import 'package:autoprompter/screens/prompt_list_screen.dart';
import 'package:autoprompter/state/prompt_store.dart';
import 'package:autoprompter/state/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

Prompt _p(String title, {String content = '', List<String> tags = const []}) {
  return Prompt.create(title: title, contentMarkdown: content, tags: tags);
}

Widget _app(PromptStore store) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PromptStore>.value(value: store),
      ChangeNotifierProvider(create: (_) => SettingsStore()),
    ],
    child: const MaterialApp(home: PromptListScreen()),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('mostra i prompt salvati dallo storage', (tester) async {
    final repo = FakePromptRepository([
      _p('Intro al prodotto', content: 'benvenuti'),
      _p('Ringraziamenti', content: 'grazie'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    expect(find.text('Intro al prodotto'), findsOneWidget);
    expect(find.text('Ringraziamenti'), findsOneWidget);
  });

  testWidgets('la ricerca filtra la lista', (tester) async {
    final repo = FakePromptRepository([
      _p('Intro al prodotto', content: 'benvenuti'),
      _p('Ringraziamenti', content: 'grazie'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ringrazia');
    await tester.pumpAndSettle();

    expect(find.text('Ringraziamenti'), findsOneWidget);
    expect(find.text('Intro al prodotto'), findsNothing);
  });

  testWidgets('il filtro per tag mostra solo i prompt con quel tag',
      (tester) async {
    final repo = FakePromptRepository([
      _p('Con tag', content: 'x', tags: ['lavoro']),
      _p('Senza tag', content: 'y'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'lavoro'));
    await tester.pumpAndSettle();

    expect(find.text('Con tag'), findsOneWidget);
    expect(find.text('Senza tag'), findsNothing);
  });

  testWidgets('duplica un prompt dal menu azioni', (tester) async {
    final repo = FakePromptRepository([_p('Originale', content: 'testo')]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplica'));
    await tester.pumpAndSettle();

    expect(store.prompts.length, 2);
    expect(find.text('Originale (copia)'), findsOneWidget);
  });

  testWidgets('stato vuoto quando non ci sono prompt', (tester) async {
    final store = PromptStore(FakePromptRepository());
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    expect(find.text('Nessun prompt'), findsOneWidget);
  });
}
