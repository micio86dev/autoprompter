import 'package:autoprompter/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _l10n(String code) =>
    AppLocalizations.delegate.load(Locale(code));

void main() {
  test('all expected world languages are supported', () {
    final codes =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    for (final c in [
      'en', 'it', 'es', 'fr', 'de', 'pt', 'ru', 'zh', 'ja', 'ar', 'hi', 'id',
      'bn',
    ]) {
      expect(codes.contains(c), isTrue, reason: 'missing locale: $c');
    }
  });

  test('basic strings are actually translated per locale', () async {
    expect((await _l10n('en')).startReading, 'Start reading');
    expect((await _l10n('it')).startReading, 'Avvia lettura');
    expect((await _l10n('es')).startReading, 'Iniciar lectura');
    expect((await _l10n('fr')).startReading, 'Démarrer la lecture');
    expect((await _l10n('de')).startReading, 'Lesen starten');
    expect((await _l10n('pt')).save, 'Salvar');
    expect((await _l10n('ja')).save, '保存');
    expect((await _l10n('zh')).save, '保存');
    expect((await _l10n('ar')).save, 'حفظ');
  });

  test('placeholder substitution works', () async {
    final en = await _l10n('en');
    expect(en.deletePromptMessage('My note'), contains('My note'));
    expect(en.shareFailed('boom'), contains('boom'));
  });

  test('pluralization works (English and Russian one/few/many)', () async {
    final en = await _l10n('en');
    expect(en.readingStatsLabel(1, '2 min'), '1 word · ~2 min');
    expect(en.readingStatsLabel(5, '2 min'), '5 words · ~2 min');

    final ru = await _l10n('ru');
    expect(ru.readingStatsLabel(1, '2 мин'), '1 слово · ~2 мин'); // one
    expect(ru.readingStatsLabel(3, '2 мин'), '3 слова · ~2 мин'); // few
    expect(ru.readingStatsLabel(5, '2 мин'), '5 слов · ~2 мин'); // many
  });
}
