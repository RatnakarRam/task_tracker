import 'package:flutter/foundation.dart';
import '../providers/task_provider.dart';
import '../providers/alarm_provider.dart';

// Combined search result type
class SearchResult {
  final String type; // 'task' or 'alarm'
  final dynamic item; // Task or Alarm object

  SearchResult({required this.type, required this.item});
}

class SearchProvider with ChangeNotifier {
  Set<String> _allTags = <String>{};

  Future<void> updateTags(
    TaskProvider taskProvider,
    AlarmProvider alarmProvider,
  ) async {
    final taskTags = await taskProvider.getAllTags();
    final alarmTags = await alarmProvider.getAllTags();
    _allTags = taskTags.union(alarmTags);
    notifyListeners();
  }

  Future<Set<String>> getAllTags(
    TaskProvider taskProvider,
    AlarmProvider alarmProvider,
  ) async {
    final taskTags = await taskProvider.getAllTags();
    final alarmTags = await alarmProvider.getAllTags();
    return taskTags.union(alarmTags);
  }

  Future<List<SearchResult>> searchAll(
    String query,
    TaskProvider taskProvider,
    AlarmProvider alarmProvider,
  ) async {
    if (query.isEmpty) {
      return await getAllResults(taskProvider, alarmProvider);
    }

    final results = <SearchResult>[];

    // Search in tasks
    final matchingTasks = await taskProvider.searchTasks(query);
    for (final task in matchingTasks) {
      results.add(SearchResult(type: 'task', item: task));
    }

    // Search in alarms
    final matchingAlarms = await alarmProvider.searchAlarms(query);
    for (final alarm in matchingAlarms) {
      results.add(SearchResult(type: 'alarm', item: alarm));
    }

    return results;
  }

  Future<List<SearchResult>> getAllResults(
    TaskProvider taskProvider,
    AlarmProvider alarmProvider,
  ) async {
    final results = <SearchResult>[];

    // Add all tasks
    final allTasks = await taskProvider.getAllTasks();
    for (final task in allTasks) {
      results.add(SearchResult(type: 'task', item: task));
    }

    // Add all alarms
    final allAlarms = await alarmProvider.getAllAlarms();
    for (final alarm in allAlarms) {
      results.add(SearchResult(type: 'alarm', item: alarm));
    }

    return results;
  }

  Future<List<SearchResult>> searchByTag(
    String tag,
    TaskProvider taskProvider,
    AlarmProvider alarmProvider,
  ) async {
    final results = <SearchResult>[];

    // Search tasks with the tag
    final allTasks = await taskProvider.getAllTasks();
    for (final task in allTasks) {
      if (task.tags.contains(tag)) {
        results.add(SearchResult(type: 'task', item: task));
      }
    }

    // Search alarms with the tag
    final allAlarms = await alarmProvider.getAllAlarms();
    for (final alarm in allAlarms) {
      if (alarm.tags.contains(tag)) {
        results.add(SearchResult(type: 'alarm', item: alarm));
      }
    }

    return results;
  }
}
