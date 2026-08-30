import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

class ProfileDetailScreen extends StatefulWidget {
  final Profile profile;
  const ProfileDetailScreen({super.key, required this.profile});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _dbService = DatabaseService();
  final _notificationService = NotificationService();
  List<Medicine> _medicines = [];
  List<Reminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meds = await _dbService.getMedicinesForProfile(widget.profile.id);
    final reminders = await _dbService.getRemindersForProfile(widget.profile.id);
    setState(() {
      _medicines = meds.reversed.toList();
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _addReminderForThisProfile() async {
    final nameController = TextEditingController();

    final medicineName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Reminder for ${widget.profile.name}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Medicine name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Next'),
          ),
        ],
      ),
    );

    if (medicineName == null || medicineName.isEmpty) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineName: medicineName,
      hour: pickedTime.hour,
      minute: pickedTime.minute,
      profileId: widget.profile.id,
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

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.profile.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminderForThisProfile,
        icon: const Icon(Icons.add_alarm),
        label: const Text('Add Reminder'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.profile.notes != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.pine),
                          const SizedBox(width: 12),
                          Expanded(child: Text(widget.profile.notes!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ScanScreen(profileId: widget.profile.id)),
                    ),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text('Scan Medicine for ${widget.profile.name}'),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Reminders', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (_reminders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No reminders yet.'),
                  )
                else
                  ..._reminders.map((r) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.alarm, color: AppTheme.pine),
                          title: Text(r.medicineName),
                          subtitle: Text(r.timeLabel),
                        ),
                      )),
                const SizedBox(height: 24),
                Text('Medicines', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (_medicines.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No medicines scanned yet.'),
                  )
                else
                  ..._medicines.map((m) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.medication_outlined,
                              color: AppTheme.pine),
                          title: Text(m.name),
                          subtitle: Text(
                              '${m.scannedAt.day}/${m.scannedAt.month}/${m.scannedAt.year}'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ResultScreen(medicine: m)),
                          ),
                        ),
                      )),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}