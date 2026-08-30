import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final _dbService = DatabaseService();
  final _notificationService = NotificationService();
  List<Reminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await _dbService.getReminders();
    setState(() {
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _addReminder() async {
    final nameController = TextEditingController();
    TimeOfDay? pickedTime;

    final medicineName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Reminder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Medicine name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Next'),
          ),
        ],
      ),
    );

    if (medicineName == null || medicineName.isEmpty) return;
    if (!mounted) return;

    pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicineName: medicineName,
      hour: pickedTime.hour,
      minute: pickedTime.minute,
      profileId: 'default',
    );

    await _dbService.saveReminder(reminder);

    try {
      await _notificationService.scheduleDaily(
        id: reminder.id.hashCode,
        medicineName: reminder.medicineName,
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } catch (e) {
      print('Failed to schedule notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not schedule notification: $e')),
        );
      }
    }

    _loadReminders();
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    await _dbService.deleteReminder(reminder.id);
    await _notificationService.cancel(reminder.id.hashCode);
    _loadReminders();
  }

  Future<void> _testNotification() async {
    await _notificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Test notification now',
            onPressed: _testNotification,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add_alarm),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(
                  child: Text(
                    'No reminders yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final r = _reminders[index];
                    return ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text(r.medicineName,
                          style: const TextStyle(fontSize: 18)),
                      subtitle: Text(r.timeLabel),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteReminder(r),
                      ),
                    );
                  },
                ),
    );
  }
}