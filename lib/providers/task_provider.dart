import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  List<Task> _allTasks = [];
  List<Task> get allTasks => _allTasks;

  TaskProvider() {
    loadTasks();
  }

  void loadTasks() async {
    final tasks = await _taskRepository.getAllTasks();
    _allTasks = tasks;
    notifyListeners();
  }

  // Get tasks for a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    return await _taskRepository.getTasksByDate(date);
  }

  // Get tasks categorized by date
  Future<Map<String, List<Task>>> getTasksByCategory(DateTime selectedDate) async {
    final todayStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    final allTasks = await _taskRepository.getAllTasks();

    final Map<String, List<Task>> categories = {
      'carriedForward': [], // Past incomplete tasks
      'currentToday': [],   // Today's tasks
      'future': [],         // Future tasks
    };

    // Get all tasks
    for (final task in allTasks) {
      if (task.dueDate.isBefore(todayStart)) {
        // Carried forward tasks are past tasks that are not completed
        if (!task.isCompleted) {
          categories['carriedForward']!.add(task);
        }
      } else if (task.dueDate.isBefore(todayEnd)) {
        // Today's tasks
        categories['currentToday']!.add(task);
      } else {
        // Future tasks
        categories['future']!.add(task);
      }
    }

    return categories;
  }

  // Calculate daily progress
  Future<double> getDailyProgress(DateTime date) async {
    final tasksForDate = await getTasksForDate(date);
    if (tasksForDate.isEmpty) return 0.0;

    final completedCount = tasksForDate.where((task) => task.isCompleted).length;
    return completedCount / tasksForDate.length;
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    String? description,
    required DateTime dueDate,
    List<String> tags = const [],
  }) async {
    await _taskRepository.createTask(
      id: const Uuid().v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      tags: tags,
    );
    loadTasks(); // Refresh the list
  }

  // Add multiple tasks
  Future<void> addMultipleTasks(List<Map<String, dynamic>> taskData) async {
    for (final taskMap in taskData) {
      await addTask(
        title: taskMap['title'],
        description: taskMap['description'],
        dueDate: taskMap['dueDate'],
        tags: List<String>.from(taskMap['tags'] ?? []),
      );
    }
  }

  // Update a task
  Future<void> updateTask(String taskId, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    List<String>? tags,
    bool? isCarriedForward,
  }) async {
    await _taskRepository.updateTask(
      taskId,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted,
      tags: tags,
      isCarriedForward: isCarriedForward,
    );
    loadTasks(); // Refresh the list
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final allTasks = await _taskRepository.getAllTasks();
    final task = allTasks.firstWhere((task) => task.id == taskId);
    await updateTask(taskId, isCompleted: !task.isCompleted);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
    loadTasks(); // Refresh the list
  }

  // Get all unique tags
  Future<Set<String>> getAllTags() async {
    return await _taskRepository.getAllTaskTags();
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    return await _taskRepository.getAllTasks();
  }

  // Search tasks by title, description, or tags
  Future<List<Task>> searchTasks(String query) async {
    final allTasks = await getAllTasks();
    if (query.isEmpty) return allTasks;

    final lowerQuery = query.toLowerCase();
    return allTasks.where((task) {
      // Search in title, description, and tags
      final matchesTitle = task.title.toLowerCase().contains(lowerQuery);
      final matchesDescription = task.description?.toLowerCase().contains(lowerQuery) ?? false;
      final matchesTag = task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      return matchesTitle || matchesDescription || matchesTag;
    }).toList();
  }
}