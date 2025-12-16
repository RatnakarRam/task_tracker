import 'package:flutter/material.dart';

class Alarm {
  String id;
  String title;
  String? reason;
  int hour;
  int minute;
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  bool sunday;
  String musicUri;
  bool isActive;
  List<String> tags;
  DateTime createdAt;
  DateTime? updatedAt;

  Alarm({
    required this.id,
    required this.title,
    this.reason,
    required this.hour,
    required this.minute,
    this.monday = false,
    this.tuesday = false,
    this.wednesday = false,
    this.thursday = false,
    this.friday = false,
    this.saturday = false,
    this.sunday = false,
    this.musicUri = '',
    this.isActive = true,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  List<bool> get weekdayFlags => [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  set weekdayFlags(List<bool> flags) {
    if (flags.length >= 7) {
      monday = flags[0];
      tuesday = flags[1];
      wednesday = flags[2];
      thursday = flags[3];
      friday = flags[4];
      saturday = flags[5];
      sunday = flags[6];
    }
  }

  String getWeekdayString() {
    final days = <String>[];
    if (monday) days.add('Mon');
    if (tuesday) days.add('Tue');
    if (wednesday) days.add('Wed');
    if (thursday) days.add('Thu');
    if (friday) days.add('Fri');
    if (saturday) days.add('Sat');
    if (sunday) days.add('Sun');
    return days.join(', ');
  }

  Alarm.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        reason = json['reason'],
        hour = json['hour'],
        minute = json['minute'],
        monday = json['monday'] ?? false,
        tuesday = json['tuesday'] ?? false,
        wednesday = json['wednesday'] ?? false,
        thursday = json['thursday'] ?? false,
        friday = json['friday'] ?? false,
        saturday = json['saturday'] ?? false,
        sunday = json['sunday'] ?? false,
        musicUri = json['musicUri'] ?? '',
        isActive = json['isActive'] ?? true,
        tags = List<String>.from(json['tags'] ?? []),
        createdAt = DateTime.parse(json['createdAt']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'reason': reason,
        'hour': hour,
        'minute': minute,
        'monday': monday,
        'tuesday': tuesday,
        'wednesday': wednesday,
        'thursday': thursday,
        'friday': friday,
        'saturday': saturday,
        'sunday': sunday,
        'musicUri': musicUri,
        'isActive': isActive,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
