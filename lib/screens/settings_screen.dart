import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            icon: Icons.text_fields_rounded,
            title: 'Text Size',
            subtitle: 'Make text easier to read',
            child: Column(
              children: [
                Slider(
                  value: _settings.textScale,
                  min: 0.85,
                  max: 1.6,
                  divisions: 15,
                  label: '${(_settings.textScale * 100).round()}%',
                  activeColor: AppTheme.pine,
                  onChanged: (value) {
                    setState(() {});
                    _settings.setTextScale(value);
                  },
                ),
                Text(
                  'Sample text at this size',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Explanations and voice will use this language',
            child: Column(
              children: kSupportedLanguages.map((lang) {
                final selected = lang.code == _settings.languageCode;
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lang.label),
                  value: lang.code,
                  groupValue: _settings.languageCode,
                  activeColor: AppTheme.pine,
                  selected: selected,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {});
                      _settings.setLanguage(value);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionCard(
            icon: Icons.info_outline_rounded,
            title: 'About MedWise AI',
            subtitle: 'Educational tool — not a substitute for '
                'professional medical advice.',
            child: SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.pine),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}