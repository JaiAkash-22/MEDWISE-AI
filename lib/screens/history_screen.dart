import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/medicine.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dbService = DatabaseService();
  List<Medicine> _medicines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meds = await _dbService.getMedicines();
    setState(() {
      _medicines = meds.reversed.toList();
      _loading = false;
    });
  }

  Future<void> _confirmDelete(Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text('Remove "${medicine.name}" from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbService.deleteMedicine(medicine.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _medicines.isEmpty
              ? const Center(
                  child: Text('No medicines scanned yet.',
                      style: TextStyle(fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final m = _medicines[index];
                    return Dismissible(
                      key: Key(m.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete this entry?'),
                            content:
                                Text('Remove "${m.name}" from your history.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(color: AppTheme.danger)),
                              ),
                            ],
                          ),
                        );
                        return confirmed ?? false;
                      },
                      onDismissed: (_) async {
                        await _dbService.deleteMedicine(m.id);
                        _load();
                      },
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.medication_outlined,
                              color: AppTheme.pine),
                          title: Text(m.name, style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                              '${m.scannedAt.day}/${m.scannedAt.month}/${m.scannedAt.year}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(m),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ResultScreen(medicine: m)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}