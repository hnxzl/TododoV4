import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task; // null untuk add, ada nilai untuk edit

  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late String _priority;
  late String _category;
  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _categories = ['work', 'study', 'personal', 'other'];
  List<TextEditingController> _subtaskControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _dueTime = TimeOfDay.fromDateTime(widget.task?.dueDate ?? DateTime.now());
    _priority = widget.task?.priority ?? 'Medium';
    _category = widget.task?.category.toLowerCase() ?? 'work';
    _subtaskControllers =
        (widget.task?.subtasks ?? [])
            .map((s) => TextEditingController(text: s))
            .toList();
    if (_subtaskControllers.isEmpty) {
      _subtaskControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );
      final subtasks =
          _subtaskControllers
              .map((c) => c.text.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      final task = TaskModel(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: dueDateTime,
        priority: _priority,
        category: _category,
        isCompleted: widget.task?.isCompleted ?? false,
        subtasks: subtasks,
      );
      Navigator.pop(context, task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Enter task title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter task description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Subtasks',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 8),
          ..._subtaskControllers.asMap().entries.map((entry) {
            final idx = entry.key;
            final controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Subtask ${idx + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed:
                      _subtaskControllers.length > 1
                          ? () {
                            setState(() {
                              _subtaskControllers.removeAt(idx);
                            });
                          }
                          : null,
                ),
              ],
            );
          }).toList(),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: Icon(
                Icons.add,
                color: isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
              ),
              label: Text('Add Subtask'),
              onPressed: () {
                setState(() {
                  _subtaskControllers.add(TextEditingController());
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(Icons.access_time),
                  label: Text(_dueTime.format(context)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items:
                _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _priority = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items:
                _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _category = newValue.toLowerCase();
                });
                print('Category changed to: $_category');
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
                      width: 2,
                    ),
                    foregroundColor:
                        isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor:
                        isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
