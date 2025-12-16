import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../repositories/alarm_repository.dart';

class AlarmProvider with ChangeNotifier {
  final AlarmRepository _alarmRepository = AlarmRepository();

  List<Alarm> _allAlarms = [];
  List<Alarm> get allAlarms => _allAlarms;

  AlarmProvider() {
    loadAlarms();
  }

  void loadAlarms() async {
    final alarms = await _alarmRepository.getAllAlarms();
    _allAlarms = alarms;
    notifyListeners();
  }

  // Get all active alarms
  Future<List<Alarm>> getActiveAlarms() async {
    return await _alarmRepository.getActiveAlarms();
  }

  // Add a new alarm
  Future<void> addAlarm({
    required String title,
    String? reason,
    required TimeOfDay time,
    required List<bool> weekdays,
    String musicUri = '',
    List<String> tags = const [],
  }) async {
    await _alarmRepository.createAlarm(
      id: const Uuid().v4(),
      title: title,
      reason: reason,
      time: time,
      weekdays: weekdays,
      musicUri: musicUri,
      tags: tags,
    );
    loadAlarms(); // Refresh the list
  }

  // Update an alarm
  Future<void> updateAlarm(
    String alarmId, {
    String? title,
    String? reason,
    TimeOfDay? time,
    List<bool>? weekdays,
    String? musicUri,
    bool? isActive,
    List<String>? tags,
  }) async {
    await _alarmRepository.updateAlarm(
      alarmId,
      title: title,
      reason: reason,
      time: time,
      weekdays: weekdays,
      musicUri: musicUri,
      isActive: isActive,
      tags: tags,
    );
    loadAlarms(); // Refresh the list
  }

  // Toggle alarm active status
  Future<void> toggleAlarmStatus(String alarmId) async {
    final allAlarms = await _alarmRepository.getAllAlarms();
    final alarm = allAlarms.firstWhere((alarm) => alarm.id == alarmId);
    await updateAlarm(alarmId, isActive: !alarm.isActive);
  }

  // Delete an alarm
  Future<void> deleteAlarm(String alarmId) async {
    await _alarmRepository.deleteAlarm(alarmId);
    loadAlarms(); // Refresh the list
  }

  // Check if an alarm is scheduled for today
  bool isAlarmScheduledForToday(Alarm alarm) {
    final today = DateTime.now();
    final dayOfWeek = today.weekday; // 1 = Monday, 7 = Sunday
    return _alarmRepository.isAlarmScheduledForDay(alarm, dayOfWeek);
  }

  // Get all unique tags
  Future<Set<String>> getAllTags() async {
    return await _alarmRepository.getAllAlarmTags();
  }

  // Get all alarms
  Future<List<Alarm>> getAllAlarms() async {
    return await _alarmRepository.getAllAlarms();
  }

  // Search alarms by title, reason, or tags
  Future<List<Alarm>> searchAlarms(String query) async {
    final allAlarms = await getAllAlarms();
    if (query.isEmpty) return allAlarms;

    final lowerQuery = query.toLowerCase();
    return allAlarms.where((alarm) {
      // Search in title, reason, and tags
      final matchesTitle = alarm.title.toLowerCase().contains(lowerQuery);
      final matchesReason =
          alarm.reason?.toLowerCase().contains(lowerQuery) ?? false;
      final matchesTag = alarm.tags.any(
        (tag) => tag.toLowerCase().contains(lowerQuery),
      );

      return matchesTitle || matchesReason || matchesTag;
    }).toList();
  }
}
