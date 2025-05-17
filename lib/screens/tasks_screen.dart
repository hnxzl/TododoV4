import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../models/task_model.dart';
import '../constants/colors.dart';
import '../screens/dashboard_screen.dart';
import 'dashboard_screen.dart' show CustomBottomNavBar;
import '../widgets/task_card.dart';
import '../screens/task_form_screen.dart';
import '../routes.dart';
import '../constants/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  String _filterTime = 'All';
  String _filterCategory = 'All';
  String _filterPriority = 'All';
  String? _expandedTaskId;
  bool _isLoading = true;
  bool _filterExpanded = false;
  String _searchKeyword = '';

  final List<String> _timeFilters = ['All', 'Today', 'This Week', 'This Month'];
  final List<String> _priorityFilters = ['All', 'High', 'Medium', 'Low'];
  List<String> _categoryFilters = ['All'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<File> _getTaskFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.json');
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final file = await _getTaskFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _tasks = jsonList.map((e) => TaskModel.fromJson(e)).toList();
      } else {
        _tasks = [];
      }
      _updateCategoryFilters();
      _applyFilters();
    } catch (e) {
      _tasks = [];
      _applyFilters();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveTasks() async {
    final file = await _getTaskFile();
    final jsonList = _tasks.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  void _updateCategoryFilters() {
    final categories = _tasks.map((e) => e.category).toSet().toList();
    _categoryFilters = ['All', ...categories];
  }

  void _applyFilters() {
    DateTime now = DateTime.now();
    _filteredTasks =
        _tasks.where((task) {
          // Filter waktu
          bool timeMatch = true;
          if (_filterTime == 'Today') {
            timeMatch =
                task.dueDate.year == now.year &&
                task.dueDate.month == now.month &&
                task.dueDate.day == now.day;
          } else if (_filterTime == 'This Week') {
            DateTime startOfWeek = now.subtract(
              Duration(days: now.weekday - 1),
            );
            DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
            timeMatch =
                task.dueDate.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                task.dueDate.isBefore(endOfWeek.add(const Duration(days: 1)));
          } else if (_filterTime == 'This Month') {
            timeMatch =
                task.dueDate.year == now.year &&
                task.dueDate.month == now.month;
          }

          // Filter kategori
          bool categoryMatch =
              _filterCategory == 'All' || task.category == _filterCategory;

          // Filter prioritas
          bool priorityMatch =
              _filterPriority == 'All' || task.priority == _filterPriority;

          // Filter keyword
          bool keywordMatch =
              _searchKeyword.isEmpty ||
              task.title.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
              (task.description?.toLowerCase().contains(
                    _searchKeyword.toLowerCase(),
                  ) ??
                  false);

          return timeMatch && categoryMatch && priorityMatch && keywordMatch;
        }).toList();

    if (mounted) setState(() {});
  }

  Future<void> _deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
    _applyFilters();
  }

  Future<void> _editTask(TaskModel task) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TaskFormScreen(task: task),
          ),
    );
    if (result != null) {
      final editedTask = result as TaskModel;
      final index = _tasks.indexWhere((t) => t.id == editedTask.id);
      if (index != -1) {
        _tasks[index] = editedTask;
        await _saveTasks();
        _applyFilters();
      }
    }
  }

  Future<void> _addTask() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TaskFormScreen(),
          ),
    );
    if (result != null) {
      final newTask = result as TaskModel;
      _tasks.add(newTask);
      await _saveTasks();
      _applyFilters();
    }
  }

  Future<void> _confirmDelete(TaskModel task) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Hapus Tugas?',
      desc: 'Tugas ini akan dihapus secara permanen.',
      btnCancelOnPress: () {},
      btnOkOnPress: () => _deleteTask(task.id),
      btnOkText: 'Hapus',
      btnCancelText: 'Batal',
      btnCancelColor: Colors.grey,
      btnOkColor: Colors.redAccent,
    ).show();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return kPriorityHighColor;
      case 'medium':
        return kPriorityMediumColor;
      case 'low':
        return kPriorityLowColor;
      default:
        return Colors.grey;
    }
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blueAccent;
      case 'study':
        return Colors.purpleAccent;
      case 'personal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'study':
        return Icons.school;
      case 'personal':
        return Icons.person;
      default:
        return Icons.label;
    }
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String getTimeLabel(DateTime date) {
    String jam = date.hour.toString().padLeft(2, '0');
    String menit = date.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final today = DateTime.now();
    final hari =
        [
          'Minggu',
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu',
        ][today.weekday % 7];
    final bulan =
        [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ][today.month - 1];
    final tanggalStr = '$hari, ${today.day} $bulan ${today.year}';
    final totalTask = _filteredTasks.length;
    final selesai = _filteredTasks.where((t) => t.isCompleted).length;
    final progress = totalTask == 0 ? 0.0 : selesai / totalTask;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null, // Tidak ada tombol kembali
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 3),
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header tanggal & tombol tambah
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Tasks',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tanggalStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Ringkasan progress
                      if (totalTask > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$selesai/$totalTask completed',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    backgroundColor:
                                        isDark
                                            ? Colors.white12
                                            : theme.dividerColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      // Search bar dan tombol filter
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari tugas...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchKeyword = val;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.filter_alt_rounded),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => _FilterModal(
                                      filterTime: _filterTime,
                                      filterCategory: _filterCategory,
                                      filterPriority: _filterPriority,
                                      categoryFilters: _categoryFilters,
                                      onApply: (time, category, priority) {
                                        setState(() {
                                          _filterTime = time;
                                          _filterCategory = category;
                                          _filterPriority = priority;
                                          _applyFilters();
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            _filteredTasks.isEmpty
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.task_alt,
                                      size: 64,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'Belum ada tugas',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.grey[700],
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan tugas baru untuk mengatur aktivitasmu!',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                isDark
                                                    ? Colors.white70
                                                    : Colors.grey[500],
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                                : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  itemCount: _filteredTasks.length,
                                  itemBuilder: (context, index) {
                                    final task = _filteredTasks[index];
                                    return Dismissible(
                                      key: Key(task.id),
                                      background: _buildSwipeAction(
                                        icon: Icons.edit,
                                        color: theme.colorScheme.primary,
                                        alignment: Alignment.centerLeft,
                                        text: 'Edit',
                                      ),
                                      secondaryBackground: _buildSwipeAction(
                                        icon: Icons.delete,
                                        color:
                                            isDark
                                                ? kDarkPriorityHigh
                                                : kLightPriorityHigh,
                                        alignment: Alignment.centerRight,
                                        text: 'Hapus',
                                      ),
                                      confirmDismiss: (direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          await _editTask(task);
                                          return false;
                                        } else if (direction ==
                                            DismissDirection.endToStart) {
                                          await _confirmDelete(task);
                                          return false;
                                        }
                                        return false;
                                      },
                                      child: Column(
                                        children: [
                                          TaskCard(
                                            title: task.title,
                                            dueDate: task.dueDate,
                                            priority: task.priority,
                                            category: task.category,
                                            isCompleted: task.isCompleted,
                                            description: task.description,
                                            onCheck: () async {
                                              final idx = _tasks.indexWhere(
                                                (t) => t.id == task.id,
                                              );
                                              if (idx != -1) {
                                                _tasks[idx] = TaskModel(
                                                  id: task.id,
                                                  title: task.title,
                                                  description: task.description,
                                                  dueDate: task.dueDate,
                                                  category: task.category,
                                                  priority: task.priority,
                                                  isCompleted:
                                                      !task.isCompleted,
                                                  subtasks: task.subtasks,
                                                  subtaskDone: task.subtaskDone,
                                                );
                                                await _saveTasks();
                                                _applyFilters();
                                              }
                                            },
                                            onTap: () {
                                              setState(() {
                                                _expandedTaskId =
                                                    _expandedTaskId == task.id
                                                        ? null
                                                        : task.id;
                                              });
                                            },
                                          ),
                                          if (_expandedTaskId == task.id &&
                                              task.subtasks.isNotEmpty)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 24,
                                                right: 4,
                                                bottom: 12,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isDark
                                                        ? Colors.white
                                                            .withOpacity(0.03)
                                                        : Colors.black
                                                            .withOpacity(0.03),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ...List.generate(task.subtasks.length, (
                                                    subIdx,
                                                  ) {
                                                    final done =
                                                        task
                                                                    .subtaskDone
                                                                    .length >
                                                                subIdx
                                                            ? task
                                                                .subtaskDone[subIdx]
                                                            : false;
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        final idx = _tasks
                                                            .indexWhere(
                                                              (t) =>
                                                                  t.id ==
                                                                  task.id,
                                                            );
                                                        if (idx != -1) {
                                                          final updatedSubtaskDone =
                                                              List<bool>.from(
                                                                _tasks[idx]
                                                                    .subtaskDone,
                                                              );
                                                          updatedSubtaskDone[subIdx] =
                                                              !updatedSubtaskDone[subIdx];
                                                          _tasks[idx] = TaskModel(
                                                            id: task.id,
                                                            title: task.title,
                                                            description:
                                                                task.description,
                                                            dueDate:
                                                                task.dueDate,
                                                            category:
                                                                task.category,
                                                            priority:
                                                                task.priority,
                                                            isCompleted:
                                                                task.isCompleted,
                                                            subtasks:
                                                                task.subtasks,
                                                            subtaskDone:
                                                                updatedSubtaskDone,
                                                          );
                                                          await _saveTasks();
                                                          _applyFilters();
                                                          setState(() {});
                                                        }
                                                      },
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              isDark
                                                                  ? Colors.white
                                                                      .withOpacity(
                                                                        0.04,
                                                                      )
                                                                  : Colors.black
                                                                      .withOpacity(
                                                                        0.04,
                                                                      ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              done
                                                                  ? Icons
                                                                      .check_circle_rounded
                                                                  : Icons
                                                                      .radio_button_unchecked,
                                                              color:
                                                                  done
                                                                      ? theme
                                                                          .colorScheme
                                                                          .primary
                                                                      : theme
                                                                          .dividerColor,
                                                              size: 22,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    task.subtasks[subIdx],
                                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                                      decoration:
                                                                          done
                                                                              ? TextDecoration.lineThrough
                                                                              : null,
                                                                      color:
                                                                          done
                                                                              ? theme.disabledColor
                                                                              : theme.textTheme.bodyMedium?.color,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  if (task.dueDate !=
                                                                      null)
                                                                    Text(
                                                                      'Due: ${task.dueDate.day}/${task.dueDate.month}',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodySmall
                                                                          ?.copyWith(
                                                                            color:
                                                                                theme.dividerColor,
                                                                          ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
        isDense: true,
      ),
    );
  }

  Widget _buildSwipeAction({
    required IconData icon,
    required Color color,
    required Alignment alignment,
    required String text,
  }) {
    return Container(
      alignment: alignment,
      color: color.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format: 12 Mei 2024 15:00
    final bulan =
        [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember',
        ][date.month - 1];
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${date.day} $bulan ${date.year} $jam:$menit';
  }

  void refreshTasks() {
    _loadTasks();
  }

  // Tambahkan method public agar bisa dipanggil dari luar
  void addTaskFromNav() {
    _addTask();
  }
}

class _FilterModal extends StatefulWidget {
  final String filterTime;
  final String filterCategory;
  final String filterPriority;
  final List<String> categoryFilters;
  final void Function(String, String, String) onApply;

  const _FilterModal({
    required this.filterTime,
    required this.filterCategory,
    required this.filterPriority,
    required this.categoryFilters,
    required this.onApply,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String _selectedTime;
  late String _selectedCategory;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.filterTime;
    _selectedCategory = widget.filterCategory;
    _selectedPriority = widget.filterPriority;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> _timeFilters = [
      'All',
      'Today',
      'This Week',
      'This Month',
    ];
    final List<String> _priorityFilters = ['All', 'High', 'Medium', 'Low'];
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Tugas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar di modal (opsional, bisa diaktifkan jika ingin search di filter)
            // TextField(
            //   decoration: InputDecoration(
            //     hintText: 'Cari tugas... (opsional)',
            //     prefixIcon: Icon(Icons.search),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(16),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 16),
            Text(
              'Kategori',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  widget.categoryFilters.where((e) => e != 'All').map((e) {
                    final selected = _selectedCategory == e;
                    return ChoiceChip(
                      label: Text(e),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = selected ? 'All' : e;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Prioritas',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _priorityFilters.where((p) => p != 'All').map((p) {
                    final selected = _selectedPriority == p;
                    return ChoiceChip(
                      label: Text(p),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedPriority = selected ? 'All' : p;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Waktu',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _timeFilters.where((t) => t != 'All').map((t) {
                    final selected = _selectedTime == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedTime = selected ? 'All' : t;
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _selectedTime,
                    _selectedCategory,
                    _selectedPriority,
                  );
                },
                child: Text('Terapkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
