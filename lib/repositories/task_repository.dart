import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_model.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();
  factory TaskRepository() => _instance;
  TaskRepository._internal();

  static const String _tasksKey = 'tasks';

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];

    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  // Save all tasks
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }

  // Create a new task
  Future<Task> createTask({
    required String id,
    required String title,
    String? description,
    required DateTime dueDate,
    List<String> tags = const [],
  }) async {
    final task = Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      tags: tags,
      createdAt: DateTime.now(),
    );

    final tasks = await getAllTasks();
    tasks.add(task);
    await saveTasks(tasks);

    return task;
  }

  // Get tasks by date
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final allTasks = await getAllTasks();
    final startOfDay = DateTime(date.year, date.month, date.day);
    // final endOfDay = startOfDay.add(const Duration(days: 1));

    return allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(startOfDay);
    }).toList();
  }

  // Get tasks by date range (for carried forward, current, future)
  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool? isCompleted,
    bool? isCarriedForward,
  }) async {
    final allTasks = await getAllTasks();

    return allTasks.where((task) {
      final isWithinDateRange =
          task.dueDate.isAfter(startDate) &&
          task.dueDate.isBefore(endDate.add(const Duration(days: 1)));
      final matchesCompleted =
          isCompleted == null || task.isCompleted == isCompleted;
      final matchesCarriedForward =
          isCarriedForward == null || task.isCarriedForward == isCarriedForward;

      return isWithinDateRange && matchesCompleted && matchesCarriedForward;
    }).toList();
  }

  // Update task
  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? tags,
    bool? isCarriedForward,
  }) async {
    final tasks = await getAllTasks();
    final taskIndex = tasks.indexWhere((task) => task.id == taskId);

    if (taskIndex != -1) {
      final task = tasks[taskIndex];
      tasks[taskIndex] = Task(
        id: task.id,
        title: title ?? task.title,
        description: description ?? task.description,
        dueDate: dueDate ?? task.dueDate,
        isCompleted: isCompleted ?? task.isCompleted,
        tags: tags ?? task.tags,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
        isCarriedForward: isCarriedForward ?? task.isCarriedForward,
      );

      await saveTasks(tasks);
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final tasks = await getAllTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }

  // Get all unique tags from tasks
  Future<Set<String>> getAllTaskTags() async {
    final allTasks = await getAllTasks();
    final tags = <String>{};

    for (final task in allTasks) {
      tags.addAll(task.tags);
    }

    return tags;
  }
}
