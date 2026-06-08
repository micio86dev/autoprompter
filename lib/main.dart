import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'data/prompt_repository.dart';
import 'screens/prompt_list_screen.dart';
import 'state/prompt_store.dart';
import 'state/settings_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AutoprompterApp());
}

class AutoprompterApp extends StatelessWidget {
  const AutoprompterApp({super.key});

  static const Color _seed = Color(0xFFFFB300);

  ThemeData _theme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PromptStore(SqflitePromptRepository.instance),
        ),
        ChangeNotifierProvider(create: (_) => SettingsStore()..load()),
      ],
      child: Consumer<SettingsStore>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Autoprompter',
            debugShowCheckedModeBanner: false,
            locale: const Locale('it'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('it'),
              Locale('en'),
            ],
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            themeMode: settings.themeMode,
            home: const PromptListScreen(),
          );
        },
      ),
    );
  }
}
