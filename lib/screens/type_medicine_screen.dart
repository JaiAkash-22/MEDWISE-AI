import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/medicine.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

/// Lets the user type a medicine name instead of scanning a label —
/// a simple chat-style alternative entry point into the same
/// AI-explanation pipeline used by the camera scan.
class TypeMedicineScreen extends StatefulWidget {
  final String profileId;
  const TypeMedicineScreen({super.key, this.profileId = 'default'});

  @override
  State<TypeMedicineScreen> createState() => _TypeMedicineScreenState();
}

class _TypeMedicineScreenState extends State<TypeMedicineScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final aiService = AiService();
      final result = await aiService.explain(text);

      final medicine = Medicine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result.medicineName,
        rawOcrText: text,
        explanation: result.explanation,
        scannedAt: DateTime.now(),
        profileId: widget.profileId,
      );

      await DatabaseService().saveMedicine(medicine);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(medicine: medicine)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Type a Medicine Name')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.pine,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "No label handy? Just type the medicine's name and "
                    "I'll explain it the same way.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                hintText: 'e.g. Paracetamol, Crocin, Dolo 650',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.pineDark),
                      )
                    : const Text('Explain This Medicine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}