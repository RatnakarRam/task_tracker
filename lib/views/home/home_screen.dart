import 'package:daily_tracker/core/constants/app_routing_constants.dart';
import 'package:daily_tracker/providers/task_provider.dart';
import 'package:daily_tracker/providers/alarm_provider.dart';
import 'package:daily_tracker/providers/search_provider.dart';
import 'package:daily_tracker/views/task_add/task_add_screen.dart';
import 'package:daily_tracker/views/alarm_add/alarm_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/task_model.dart';
import '../../models/alarm_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppProvider, TaskProvider, AlarmProvider>(
      builder: (context, appProvider, taskProvider, alarmProvider, child) {
        return FutureBuilder(
          future: Future.wait([
            taskProvider.getDailyProgress(_selectedDate),
            taskProvider.getTasksByCategory(_selectedDate),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final dailyProgress = snapshot.data![0] as double;
            final taskCategories = snapshot.data![1] as Map<String, List<Task>>;

            return Scaffold(
              appBar: AppBar(
                title: const Text('Daily Tracker'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _showSearchDialog(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await appProvider.logout();
                      // Navigate to login screen on logout
                      context.pushReplacement(AppRoutingConstants.loginRoute);
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, ${appProvider.userName ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                            });
                          },
                        ),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate.add(const Duration(days: 1));
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Daily progress bar
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Daily Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: dailyProgress,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('${(dailyProgress * 100).round()}% completed today'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tasks section
                    const Text(
                      'Tasks',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    // Carried Forward Tasks
                    if (taskCategories['carriedForward']!.isNotEmpty) ...[
                      const Text(
                        'Carried Forward',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      ...taskCategories['carriedForward']!.map((task) => _buildTaskItem(task, taskProvider)).toList(),
                      const SizedBox(height: 15),
                    ],

                    // Current Tasks (Today)
                    const Text(
                      'Current Tasks',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    if (taskCategories['currentToday']!.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No tasks for today',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...taskCategories['currentToday']!.map((task) => _buildTaskItem(task, taskProvider)).toList(),
                    const SizedBox(height: 15),

                    // Future Tasks
                    if (taskCategories['future']!.isNotEmpty) ...[
                      const Text(
                        'Future Tasks',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      ...taskCategories['future']!.map((task) => _buildTaskItem(task, taskProvider)).toList(),
                    ],
                  ],
                ),
              ),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'alarmFab',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AlarmAddScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.alarm),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'taskFab',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaskAddScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskItem(Task task, TaskProvider taskProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.isCompleted ? Colors.green : Colors.grey,
          child: task.isCompleted
              ? const Icon(Icons.check, color: Colors.white)
              : Text(task.title.substring(0, 1).toUpperCase()),
        ),
        title: Text(task.title),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(task.description!)
            : null,
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) async {
            if (value != null) {
              await taskProvider.toggleTaskCompletion(task.id);
            }
          },
        ),
        onLongPress: () {
          _showTaskOptions(context, task, taskProvider);
        },
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Task task, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement edit functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () async {
                  await taskProvider.deleteTask(task.id);
                  Navigator.pop(context);
                },
              ),
              if (!task.isCompleted && task.dueDate.isBefore(DateTime.now()))
                ListTile(
                  leading: const Icon(Icons.forward),
                  title: const Text('Carry Forward'),
                  onTap: () async {
                    await taskProvider.updateTask(task.id, isCarriedForward: true);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: Future.wait([taskProvider.getAllTags(), alarmProvider.getAllTags()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text('Search and Filter'),
                content: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Search and Filter'),
                content: Text('Error: ${snapshot.error}'),
              );
            }

            Set<String> allTags = <Set<String>>[
              snapshot.data![0] as Set<String>,
              snapshot.data![1] as Set<String>,
            ].expand((set) => set).toSet();

            String query = '';
            Set<String> selectedTags = <String>{};

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text('Search and Filter'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search tasks or alarms...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tags',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: allTags.map((tag) {
                          return ChoiceChip(
                            label: Text(tag),
                            selected: selectedTags.contains(tag),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (selectedTags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Selected Tags:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: selectedTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              onDeleted: () {
                                setState(() {
                                  selectedTags.remove(tag);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Perform the search
                        List<SearchResult> results = [];

                        if (query.isNotEmpty) {
                          final tasks = await taskProvider.searchTasks(query);
                          final alarms = await alarmProvider.searchAlarms(query);

                          // Convert to SearchResults
                          results.addAll(tasks.map((task) => SearchResult(type: 'task', item: task)));
                          results.addAll(alarms.map((alarm) => SearchResult(type: 'alarm', item: alarm)));
                        } else if (selectedTags.isNotEmpty) {
                          // If no query but tags are selected, search by tags
                          for (String tag in selectedTags) {
                            // Filter tasks by tag
                            final allTasks = await taskProvider.getAllTasks();
                            for (final task in allTasks) {
                              if (task.tags.contains(tag)) {
                                results.add(SearchResult(type: 'task', item: task));
                              }
                            }

                            // Filter alarms by tag
                            final allAlarms = await alarmProvider.getAllAlarms();
                            for (final alarm in allAlarms) {
                              if (alarm.tags.contains(tag)) {
                                results.add(SearchResult(type: 'alarm', item: alarm));
                              }
                            }
                          }
                          // Remove duplicates
                          results = results.toSet().toList();
                        } else {
                          // If neither query nor tags, return all items
                          final allTasks = await taskProvider.getAllTasks();
                          final allAlarms = await alarmProvider.getAllAlarms();

                          results.addAll(allTasks.map((task) => SearchResult(type: 'task', item: task)));
                          results.addAll(allAlarms.map((alarm) => SearchResult(type: 'alarm', item: alarm)));
                        }

                        Navigator.pop(context);
                        _showSearchResults(context, results);
                      },
                      child: const Text('Search'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSearchResults(BuildContext context, List<SearchResult> results) {
    if (results.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Search Results'),
            content: const Text('No matching tasks or alarms found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Results'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                final result = results[index];
                if (result.type == 'task') {
                  Task task = result.item;
                  return ListTile(
                    title: Text(task.title),
                    subtitle: task.description != null ? Text(task.description!) : null,
                    trailing: const Icon(Icons.check_circle, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context); // Close search results dialog
                      Navigator.pop(context); // Close search dialog
                    },
                  );
                } else if (result.type == 'alarm') {
                  Alarm alarm = result.item;
                  return ListTile(
                    title: Text(alarm.title),
                    subtitle: alarm.reason != null ? Text(alarm.reason!) : null,
                    trailing: const Icon(Icons.alarm, color: Colors.blue),
                    onTap: () {
                      Navigator.pop(context); // Close search results dialog
                      Navigator.pop(context); // Close search dialog
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
