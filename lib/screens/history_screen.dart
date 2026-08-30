import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/medicine.dart';
import 'result_screen.dart';

/// List of previously scanned medicines (Part 7).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: FutureBuilder<List<Medicine>>(
        future: DatabaseService().getMedicines(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final medicines = snapshot.data!.reversed.toList();
          if (medicines.isEmpty) {
            return const Center(
              child: Text('No medicines scanned yet.',
                  style: TextStyle(fontSize: 16)),
            );
          }
          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final m = medicines[index];
              return ListTile(
                leading: const Icon(Icons.medication_outlined),
                title: Text(m.name, style: const TextStyle(fontSize: 18)),
                subtitle: Text(
                    '${m.scannedAt.day}/${m.scannedAt.month}/${m.scannedAt.year}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResultScreen(medicine: m)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
