import 'package:autoprompter/l10n/app_localizations.dart';
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
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PromptListScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the prompts saved in storage', (tester) async {
    final repo = FakePromptRepository([
      _p('Product intro', content: 'welcome'),
      _p('Thanks', content: 'thanks'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    expect(find.text('Product intro'), findsOneWidget);
    expect(find.text('Thanks'), findsOneWidget);
  });

  testWidgets('search filters the list', (tester) async {
    final repo = FakePromptRepository([
      _p('Product intro', content: 'welcome'),
      _p('Thanks', content: 'thanks'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'thank');
    await tester.pumpAndSettle();

    expect(find.text('Thanks'), findsOneWidget);
    expect(find.text('Product intro'), findsNothing);
  });

  testWidgets('the tag filter shows only the prompts with that tag',
      (tester) async {
    final repo = FakePromptRepository([
      _p('With tag', content: 'x', tags: ['work']),
      _p('Without tag', content: 'y'),
    ]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'work'));
    await tester.pumpAndSettle();

    expect(find.text('With tag'), findsOneWidget);
    expect(find.text('Without tag'), findsNothing);
  });

  testWidgets('duplicates a prompt from the actions menu', (tester) async {
    final repo = FakePromptRepository([_p('Original', content: 'text')]);
    final store = PromptStore(repo);
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duplicate'));
    await tester.pumpAndSettle();

    expect(store.prompts.length, 2);
    expect(find.text('Original (copy)'), findsOneWidget);
  });

  testWidgets('empty state when there are no prompts', (tester) async {
    final store = PromptStore(FakePromptRepository());
    await tester.pumpWidget(_app(store));
    await tester.pumpAndSettle();

    expect(find.text('No prompts'), findsOneWidget);
  });
}
