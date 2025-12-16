import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alarm_provider.dart';

class AlarmAddScreen extends StatefulWidget {
  const AlarmAddScreen({super.key});

  @override
  State<AlarmAddScreen> createState() => _AlarmAddScreenState();
}

class _AlarmAddScreenState extends State<AlarmAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _tagController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  String _selectedMusic = '';
  final Set<String> _tags = <String>{};

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(int index) {
    setState(() {
      _selectedDays[index] = !_selectedDays[index];
    });
  }

  void _addTagToList() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveAlarm() {
    if (_formKey.currentState!.validate()) {
      final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
      alarmProvider.addAlarm(
        title: _titleController.text.trim(),
        reason: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        time: _selectedTime,
        weekdays: _selectedDays,
        musicUri: _selectedMusic,
        tags: _tags.toList(),
      );

      Navigator.pop(context); // Go back to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAlarm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alarm Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Repeat Days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Mon'),
                    selected: _selectedDays[0],
                    onSelected: (selected) => _toggleDay(0),
                  ),
                  ChoiceChip(
                    label: const Text('Tue'),
                    selected: _selectedDays[1],
                    onSelected: (selected) => _toggleDay(1),
                  ),
                  ChoiceChip(
                    label: const Text('Wed'),
                    selected: _selectedDays[2],
                    onSelected: (selected) => _toggleDay(2),
                  ),
                  ChoiceChip(
                    label: const Text('Thu'),
                    selected: _selectedDays[3],
                    onSelected: (selected) => _toggleDay(3),
                  ),
                  ChoiceChip(
                    label: const Text('Fri'),
                    selected: _selectedDays[4],
                    onSelected: (selected) => _toggleDay(4),
                  ),
                  ChoiceChip(
                    label: const Text('Sat'),
                    selected: _selectedDays[5],
                    onSelected: (selected) => _toggleDay(5),
                  ),
                  ChoiceChip(
                    label: const Text('Sun'),
                    selected: _selectedDays[6],
                    onSelected: (selected) => _toggleDay(6),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Alarm Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter alarm title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Reason (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter reason for alarm (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Select Music (Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMusic.isEmpty ? null : _selectedMusic,
                decoration: const InputDecoration(
                  hintText: 'Select alarm sound',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'default', child: Text('Default')),
                  DropdownMenuItem(
                    value: 'ringtone1',
                    child: Text('Ringtone 1'),
                  ),
                  DropdownMenuItem(
                    value: 'ringtone2',
                    child: Text('Ringtone 2'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMusic = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Add Tags',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Enter a tag',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTagToList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addTagToList,
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Preview section
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alarm Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${_selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Days: ${_selectedDays.asMap().entries.where((entry) => entry.value).map((entry) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][entry.key]).join(', ') == '' ? 'None' : _selectedDays.asMap().entries.where((entry) => entry.value).map((entry) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][entry.key]).join(', ')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_tags.isNotEmpty)
                        Text(
                          'Tags: ${_tags.join(', ')}',
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAlarm,
        icon: const Icon(Icons.alarm_add),
        label: const Text('Set Alarm'),
      ),
    );
  }
}
