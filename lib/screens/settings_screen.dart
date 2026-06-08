import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/settings_store.dart';

/// Impostazioni dell'app: tema e valori predefiniti del teleprompter.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        children: [
          const _SectionHeader('Aspetto'),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(settings.themeMode)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('Sistema'),
                    icon: Icon(Icons.brightness_auto)),
                ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Chiaro'),
                    icon: Icon(Icons.light_mode)),
                ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Scuro'),
                    icon: Icon(Icons.dark_mode)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => settings.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const _SectionHeader('Teleprompter (valori predefiniti)'),
          _SettingSlider(
            label: 'Dimensione testo',
            value: settings.defaultFontSize,
            min: 18,
            max: 72,
            display: settings.defaultFontSize.round().toString(),
            onChanged: settings.setDefaultFontSize,
          ),
          _SettingSlider(
            label: 'Velocità autoscroll',
            value: settings.defaultScrollSpeed,
            min: 10,
            max: 200,
            display: '${settings.defaultScrollSpeed.round()} px/s',
            onChanged: settings.setDefaultScrollSpeed,
          ),
          _SettingSlider(
            label: 'Posizione riga di lettura',
            value: settings.defaultReadingLine,
            min: 0.1,
            max: 0.6,
            display: '${(settings.defaultReadingLine * 100).round()}%',
            onChanged: settings.setDefaultReadingLine,
          ),
        ],
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Segui il sistema',
        ThemeMode.light => 'Chiaro',
        ThemeMode.dark => 'Scuro',
      };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  const _SettingSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(display,
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
