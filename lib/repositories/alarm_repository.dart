import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmRepository {
  static final AlarmRepository _instance = AlarmRepository._internal();
  factory AlarmRepository() => _instance;
  AlarmRepository._internal();

  static const String _alarmsKey = 'alarms';

  // Get all alarms
  Future<List<Alarm>> getAllAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList(_alarmsKey) ?? [];

    return alarmsJson.map((json) => Alarm.fromJson(jsonDecode(json))).toList();
  }

  // Save all alarms
  Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList(_alarmsKey, alarmsJson);
  }

  // Create a new alarm
  Future<Alarm> createAlarm({
    required String id,
    required String title,
    String? reason,
    required TimeOfDay time,
    required List<bool> weekdays,
    String musicUri = '',
    List<String> tags = const [],
  }) async {
    final alarm = Alarm(
      id: id,
      title: title,
      reason: reason,
      hour: time.hour,
      minute: time.minute,
      monday: weekdays[0],
      tuesday: weekdays[1],
      wednesday: weekdays[2],
      thursday: weekdays[3],
      friday: weekdays[4],
      saturday: weekdays[5],
      sunday: weekdays[6],
      musicUri: musicUri,
      tags: tags,
      createdAt: DateTime.now(),
    );

    final alarms = await getAllAlarms();
    alarms.add(alarm);
    await saveAlarms(alarms);

    return alarm;
  }

  // Get active alarms
  Future<List<Alarm>> getActiveAlarms() async {
    final allAlarms = await getAllAlarms();
    return allAlarms.where((alarm) => alarm.isActive).toList();
  }

  // Update alarm
  Future<void> updateAlarm(String alarmId, {
    String? title,
    String? reason,
    TimeOfDay? time,
    List<bool>? weekdays,
    String? musicUri,
    bool? isActive,
    List<String>? tags,
  }) async {
    final alarms = await getAllAlarms();
    final alarmIndex = alarms.indexWhere((alarm) => alarm.id == alarmId);

    if (alarmIndex != -1) {
      final alarm = alarms[alarmIndex];
      final updatedAlarm = Alarm(
        id: alarm.id,
        title: title ?? alarm.title,
        reason: reason ?? alarm.reason,
        hour: time?.hour ?? alarm.hour,
        minute: time?.minute ?? alarm.minute,
        monday: weekdays != null && weekdays.length > 0 ? weekdays[0] : alarm.monday,
        tuesday: weekdays != null && weekdays.length > 1 ? weekdays[1] : alarm.tuesday,
        wednesday: weekdays != null && weekdays.length > 2 ? weekdays[2] : alarm.wednesday,
        thursday: weekdays != null && weekdays.length > 3 ? weekdays[3] : alarm.thursday,
        friday: weekdays != null && weekdays.length > 4 ? weekdays[4] : alarm.friday,
        saturday: weekdays != null && weekdays.length > 5 ? weekdays[5] : alarm.saturday,
        sunday: weekdays != null && weekdays.length > 6 ? weekdays[6] : alarm.sunday,
        musicUri: musicUri ?? alarm.musicUri,
        isActive: isActive ?? alarm.isActive,
        tags: tags ?? alarm.tags,
        createdAt: alarm.createdAt,
        updatedAt: DateTime.now(),
      );

      alarms[alarmIndex] = updatedAlarm;
      await saveAlarms(alarms);
    }
  }

  // Delete alarm
  Future<void> deleteAlarm(String alarmId) async {
    final alarms = await getAllAlarms();
    alarms.removeWhere((alarm) => alarm.id == alarmId);
    await saveAlarms(alarms);
  }

  // Check if alarm is scheduled for today
  bool isAlarmScheduledForDay(Alarm alarm, int dayOfWeek) {
    // dayOfWeek: 1 = Monday, 7 = Sunday (DateTime.weekday convention)
    switch (dayOfWeek) {
      case 1: return alarm.monday;
      case 2: return alarm.tuesday;
      case 3: return alarm.wednesday;
      case 4: return alarm.thursday;
      case 5: return alarm.friday;
      case 6: return alarm.saturday;
      case 7: return alarm.sunday;
      default: return false;
    }
  }

  // Get all unique tags from alarms
  Future<Set<String>> getAllAlarmTags() async {
    final allAlarms = await getAllAlarms();
    final tags = <String>{};

    for (final alarm in allAlarms) {
      tags.addAll(alarm.tags);
    }

    return tags;
  }
}