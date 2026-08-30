import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';
import '../models/profile.dart';
import '../models/reminder.dart';

class DatabaseService {
  static const _medicinesKey = 'medwise_medicines';
  static const _profilesKey = 'medwise_profiles';
  static const _remindersKey = 'medwise_reminders';

  Future<List<Medicine>> getMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_medicinesKey) ?? [];
    return raw.map((s) => Medicine.fromJson(jsonDecode(s))).toList();
  }

  Future<List<Medicine>> getMedicinesForProfile(String profileId) async {
    final all = await getMedicines();
    return all.where((m) => m.profileId == profileId).toList();
  }

  Future<void> saveMedicine(Medicine medicine) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_medicinesKey) ?? [];
    raw.add(jsonEncode(medicine.toJson()));
    await prefs.setStringList(_medicinesKey, raw);
  }

  Future<List<Profile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey) ?? [];
    if (raw.isEmpty) {
      final defaultProfile = Profile(id: 'default', name: 'Me');
      await saveProfile(defaultProfile);
      return [defaultProfile];
    }
    return raw.map((s) => Profile.fromJson(jsonDecode(s))).toList();
  }

  Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey) ?? [];
    raw.add(jsonEncode(profile.toJson()));
    await prefs.setStringList(_profilesKey, raw);
  }

  Future<void> deleteProfile(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_profilesKey) ?? [];
    final updated = raw.where((s) {
      final p = Profile.fromJson(jsonDecode(s));
      return p.id != id;
    }).toList();
    await prefs.setStringList(_profilesKey, updated);
  }

  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_remindersKey) ?? [];
    return raw.map((s) => Reminder.fromJson(jsonDecode(s))).toList();
  }

  Future<List<Reminder>> getRemindersForProfile(String profileId) async {
    final all = await getReminders();
    return all.where((r) => r.profileId == profileId).toList();
  }

  Future<void> saveReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_remindersKey) ?? [];
    raw.add(jsonEncode(reminder.toJson()));
    await prefs.setStringList(_remindersKey, raw);
  }

  Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_remindersKey) ?? [];
    final updated = raw.where((s) {
      final r = Reminder.fromJson(jsonDecode(s));
      return r.id != id;
    }).toList();
    await prefs.setStringList(_remindersKey, updated);
  }
}