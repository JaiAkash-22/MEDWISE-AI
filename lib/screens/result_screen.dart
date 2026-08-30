import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';
import '../services/settings_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Common drug names that Android's TTS engine mispronounces on its own
/// (often reading them syllable-by-syllable oddly). Respelling them
/// phonetically with hyphens gives the engine natural pause points and
/// noticeably improves pronunciation. This ONLY affects what's spoken —
/// the on-screen text is untouched.
const Map<String, String> _phoneticRespellings = {
  'paracetamol': 'para-see-tuh-mol',
  'acetaminophen': 'uh-see-tuh-min-oh-fen',
  'ibuprofen': 'eye-byoo-pro-fen',
  'amoxicillin': 'uh-mox-ih-sil-in',
  'azithromycin': 'az-ith-roh-my-sin',
  'cetirizine': 'seh-teer-ih-zeen',
  'metformin': 'met-for-min',
  'omeprazole': 'oh-mep-ruh-zohl',
  'atorvastatin': 'uh-tor-vuh-stat-in',
  'dolo': 'doh-loh',
  'crocin': 'kroh-sin',
  'diclofenac': 'dy-kloh-fen-ak',
  'pantoprazole': 'pan-toh-pruh-zohl',
  'levocetirizine': 'lee-voh-seh-teer-ih-zeen',
};

class ResultScreen extends StatefulWidget {
  final Medicine medicine;
  const ResultScreen({super.key, required this.medicine});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts _tts = FlutterTts();
  final _dbService = DatabaseService();
  final _notificationService = NotificationService();
  bool _isSpeaking = false;
  bool _ttsReady = false;
  bool _reminderSet = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    final languageCode = SettingsService().languageCode;
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    try {
      final engines = await _tts.getEngines as List<dynamic>?;
      if (engines != null && engines.contains('com.google.android.tts')) {
        await _tts.setEngine('com.google.android.tts');
      }
    } catch (_) {}

    final available = await _tts.isLanguageAvailable(languageCode);
    await _tts.setLanguage(available == true ? languageCode : 'en-US');

    try {
      final voices = await _tts.getVoices as List<dynamic>?;
      if (voices != null) {
        final match = voices.cast<Map>().firstWhere(
              (v) => (v['locale'] as String?)
                      ?.startsWith(languageCode.split('-').first) ==
                  true,
              orElse: () => {},
            );
        if (match.isNotEmpty) {
          await _tts.setVoice({
            'name': match['name'].toString(),
            'locale': match['locale'].toString(),
          });
        }
      }
    } catch (_) {}

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    setState(() => _ttsReady = true);
  }

  /// Fixes text before it's spoken (not before it's displayed):
  /// - breaks up accidental ALL-CAPS runs (Android TTS spells these
  ///   out letter-by-letter, thinking they're acronyms)
  /// - swaps known drug names for a phonetic respelling
  String _prepareForSpeech(String text) {
    var result = text.replaceAllMapped(
      RegExp(r'\b[A-Z]{4,}\b'),
      (m) {
        final w = m[0]!;
        return w[0] + w.substring(1).toLowerCase();
      },
    );

    _phoneticRespellings.forEach((drug, phonetic) {
      final pattern = RegExp(r'\b' + RegExp.escape(drug) + r'\b',
          caseSensitive: false);
      result = result.replaceAll(pattern, phonetic);
    });

    return result;
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final spokenName = _prepareForSpeech(widget.medicine.name);
      final spokenExplanation = _prepareForSpeech(widget.medicine.explanation);
      await _tts.speak('$spokenName. $spokenExplanation');
    }
  }

  Future<void> _setReminder() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineName: widget.medicine.name,
      hour: pickedTime.hour,
      minute: pickedTime.minute,
      profileId: widget.medicine.profileId,
    );

    await _dbService.saveReminder(reminder);
    try {
      await _notificationService.scheduleDaily(
        id: reminder.id.hashCode,
        medicineName: reminder.medicineName,
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _reminderSet = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${reminder.timeLabel}')),
      );
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explanation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicine.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  color: AppTheme.pine.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      widget.medicine.explanation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _ttsReady ? _toggleSpeak : null,
                        icon: Icon(_isSpeaking
                            ? Icons.stop_rounded
                            : Icons.volume_up_rounded),
                        label: Text(_isSpeaking ? 'Stop' : 'Read Aloud'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _reminderSet ? null : _setReminder,
                        icon: Icon(_reminderSet
                            ? Icons.check_rounded
                            : Icons.add_alarm_rounded),
                        label: Text(_reminderSet ? 'Reminder Set' : 'Set Reminder'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'This is educational information only. Always confirm with a '
                  'doctor or pharmacist before starting, stopping, or changing '
                  'any medicine.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    ),
                    child: const Text('Done — Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}