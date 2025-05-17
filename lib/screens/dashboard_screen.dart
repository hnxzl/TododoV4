import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../routes.dart';
import '../services/local_storage_service.dart';
import '../services/json_io_service.dart';
import '../models/task_model.dart';
import '../models/event_model.dart';
import '../models/study_model.dart';
import '../models/note_model.dart';
import '../utils/notifier_helper.dart';
import '../screens/tasks_screen.dart';
import '../screens/events_screen.dart';
import '../screens/settings_screens.dart';
import '../screens/notes_screen.dart';
import '../screens/tracker_screen.dart';
import '../screens/task_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode>? themeNotifier;
  const DashboardScreen({super.key, this.themeNotifier});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  String? _username;
  bool _hasNewNotif = true;
  bool _isPageLoading = false;

  List<TaskModel> todayTasks = [];
  List<EventModel> upcomingEvents = [];
  List<StudySessionModel> _sessions = [];
  List<NoteModel> notes = [];

  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool isAddMenuOpen = false;

  void refreshData() {
    _loadData();
  }

  Future<void> _loadData() async {
    final allTasks = await JsonIOService.readJsonList<TaskModel>(
      JsonIOService.tasksFile,
      (json) => TaskModel.fromJson(json),
    );
    final now = DateTime.now();
    todayTasks =
        allTasks.where((t) => !t.isCompleted).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final allEvents = await JsonIOService.readJsonList<EventModel>(
      JsonIOService.eventsFile,
      (json) => EventModel.fromJson(json),
    );
    upcomingEvents =
        allEvents.where((e) => e.date.isAfter(now)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final trackerSessions = await JsonIOService.readJsonList<StudySessionModel>(
      'study_sessions.json',
      (json) => StudySessionModel.fromJson(json),
    );
    _sessions = trackerSessions;

    final allNotes = await JsonIOService.readJsonList<NoteModel>(
      JsonIOService.notesFile,
      (json) => NoteModel.fromJson(json),
    );
    notes =
        allNotes
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
          ..take(2).toList();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    NotifierHelper.initializeNotificationPlugin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _showNotificationDemo() async {
    setState(() {
      _hasNewNotif = false;
    });
    await NotifierHelper.showNotification(
      1001,
      'Contoh Notifikasi',
      'Ini adalah notifikasi dari Tododo!',
      DateTime.now().add(const Duration(seconds: 3)),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi akan muncul dalam 3 detik!')),
    );
  }

  void _openMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Data untuk grafik bar chart mingguan
  List<BarChartGroupData> get _weeklyBarData {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<BarChartGroupData> bars = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final total = _sessions
          .where(
            (s) =>
                s.startTime.year == day.year &&
                s.startTime.month == day.month &&
                s.startTime.day == day.day,
          )
          .fold(0, (sum, s) => sum + s.durationInMinutes);
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total.toDouble(),
              color: Colors.blueAccent,
              width: 22,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  // Helper for card gradient
  LinearGradient getCardGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        colors: [
          Color(0xFF23243A), // dark base
          Color(0xFF2B3A67), // deep blue
          Color(0xFF46A0FC).withOpacity(0.18), // moon blue
          Colors.white.withOpacity(0.07), // soft white
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [
          Color(0xFFB2EBF2), // light blue (beach)
          Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  // Helper for card gradient accent (behind card)
  Widget cardGradientAccent(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                isDark
                    ? LinearGradient(
                      colors: [
                        Color(0xFF23243A),
                        Color(0xFF46A0FC).withOpacity(0.18),
                        Colors.white.withOpacity(0.07),
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    )
                    : LinearGradient(
                      colors: [
                        Color(0xFFB2EBF2).withOpacity(0.35),
                        Colors.white.withOpacity(0.0),
                      ],
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                    ),
          ),
        ),
      ),
    );
  }

  // Helper for bottom gradient accent (blurred, wide, and soft like reference)
  Widget cardBottomGlowAccent(bool isDark) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: -8,
      height: 32,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        Color(0xFF46A0FC).withOpacity(0.28),
                        Color(0xFF6D5FFD).withOpacity(0.18),
                        Colors.transparent,
                      ]
                      : [
                        Color(0xFFB2EBF2).withOpacity(0.22),
                        Color(0xFF6D5FFD).withOpacity(0.13),
                        Colors.transparent,
                      ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return;
    if (isAddMenuOpen) setState(() => isAddMenuOpen = false);
    setState(() {
      _isPageLoading = true;
    });
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (mounted) {
            setState(() {
              _currentIndex = index;
              _isPageLoading = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181A20) : const Color(0xFFF7F8FA);
    final cardColor = isDark ? const Color(0xFF23243A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final double fabDiameter = 64;
    final double fabRadius = fabDiameter / 2;
    final double menuRadius = 120;
    final double navBarHeight = 70;
    final double fabYOffset = navBarHeight / 2 + -18;
    final double fabX = MediaQuery.of(context).size.width / 2;
    final List<_CircularAddButton> menuButtons = [
      _CircularAddButton(
        icon: Icons.check_circle,
        label: 'Task',
        color: Colors.redAccent,
        onTap: () {
          setState(() => isAddMenuOpen = false);
          _showTaskFormDialog(context);
        },
      ),
      _CircularAddButton(
        icon: Icons.event,
        label: 'Event',
        color: Colors.purpleAccent,
        onTap: () {
          setState(() => isAddMenuOpen = false);
          Navigator.pushNamed(context, AppRoutes.events);
        },
      ),
      _CircularAddButton(
        icon: Icons.note,
        label: 'Note',
        color: Colors.blueAccent,
        onTap: () {
          setState(() => isAddMenuOpen = false);
          _showNoteModal(context);
        },
      ),
      _CircularAddButton(
        icon: Icons.track_changes_rounded,
        label: 'Tracker',
        color: Colors.green,
        onTap: () {
          setState(() => isAddMenuOpen = false);
        },
      ),
    ];
    final int n = menuButtons.length;
    final double startAngle = 5 * math.pi / 6;
    final double endAngle = math.pi / 6;
    final double angleStep = (endAngle - startAngle) / (n - 1);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    if (isAddMenuOpen) isAddMenuOpen = false;
                  });
                },
                children: [
                  DashboardHomeContent(
                    isDark: isDark,
                    todayTasks: todayTasks,
                    upcomingEvents: upcomingEvents,
                    sessions: _sessions,
                    username: _username,
                    onShowNotificationDemo: _showNotificationDemo,
                    weeklyBarData: _weeklyBarData,
                    weeklyHoursString: _getWeeklyHoursString(),
                    onNotesLongPress: () => _onNavBarTap(3),
                    onTrackerLongPress: () => _onNavBarTap(4),
                    notes: notes,
                  ),
                  const TasksScreen(),
                  const EventsScreen(),
                  const NotesScreen(),
                  const TrackerScreen(),
                  const SettingsScreen(),
                ],
              ),
            ),
          ),
          // Loading overlay with fade animation
          if (_isPageLoading)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: _isPageLoading ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
                    ),
                  ),
                ),
              ),
            ),
          // Overlay sunburst/menu radial (hanya saat menu open)
          if (_currentIndex == 0 && isAddMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => isAddMenuOpen = false),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: CustomPaint(
                    painter: SunburstPainter(
                      center: Offset(
                        fabX,
                        MediaQuery.of(context).size.height - fabYOffset,
                      ),
                      radius: menuRadius + 60,
                      isDark: isDark,
                      isHalf: true,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentIndex == 0)
            ...List.generate(n, (i) {
              final angle = startAngle + i * angleStep;
              return AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left:
                    fabX +
                    (isAddMenuOpen ? menuRadius * math.cos(angle) : 0) -
                    fabRadius,
                bottom:
                    fabYOffset +
                    (isAddMenuOpen ? menuRadius * math.sin(angle) : 0) -
                    fabRadius,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: isAddMenuOpen ? 1 : 0,
                  child: menuButtons[i],
                ),
              );
            }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: _onNavBarTap,
          onFabPressed: () {
            if (_currentIndex == 0) {
              setState(() => isAddMenuOpen = !isAddMenuOpen);
            } else if (_currentIndex == 1) {
              _showTaskFormDialog(context);
            } else if (_currentIndex == 2) {
              Navigator.pushNamed(context, AppRoutes.events);
            } else if (_currentIndex == 3) {
              // Notes: langsung add note
              _showNoteModal(context);
            } else if (_currentIndex == 4) {
              // Tracker: aksi tracker
              // TODO: Tambahkan aksi sesuai kebutuhan
            } else if (_currentIndex == 5) {
              // Settings: tidak ada aksi khusus
            }
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  String _formatDate(DateTime date) {
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

  int _getWeeklyTaskCount() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return todayTasks
        .where(
          (t) =>
              t.dueDate.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              t.dueDate.isBefore(endOfWeek.add(const Duration(days: 1))),
        )
        .length;
  }

  String _getWeeklyHoursString() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    final totalMinutes = _sessions
        .where(
          (s) =>
              s.startTime.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              s.startTime.isBefore(endOfWeek.add(const Duration(days: 1))),
        )
        .fold(0, (sum, s) => sum + s.durationInMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _formatShortDateTime(DateTime date) {
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final d = date.day;
    final m = bulan[date.month - 1];
    final jam = date.hour.toString();
    final menit = date.minute.toString().padLeft(2, '0');
    return '$d/$m $jam.$menit';
  }

  void _showNoteModal(BuildContext context) {
    final TextEditingController _contentController = TextEditingController();
    final TextEditingController _tagController = TextEditingController();
    Color _selectedColor = Colors.yellow[200]!;
    final List<Color> _colorChoices = [
      Colors.yellow,
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.amberAccent,
      Colors.blueGrey[100]!,
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder:
              (context, setModalState) => Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Color(0xFF23243A)
                          : Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Tambah Catatan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Isi Catatan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor:
                            theme.brightness == Brightness.dark
                                ? Color(0xFF23243A)
                                : Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: 'Tag (opsional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor:
                            theme.brightness == Brightness.dark
                                ? Color(0xFF23243A)
                                : Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Warna Catatan',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            _colorChoices.map((color) {
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedColor = color;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          _selectedColor == color
                                              ? Colors.black
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      _selectedColor == color
                                          ? Icon(
                                            Icons.check,
                                            size: 18,
                                            color: Colors.black,
                                          )
                                          : null,
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Batal'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              foregroundColor:
                                  theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_contentController.text.trim().isEmpty)
                                return;
                              final note = NoteModel(
                                id:
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                content: _contentController.text.trim(),
                                tag: _tagController.text.trim(),
                                color: _selectedColor.value,
                                createdAt: DateTime.now(),
                              );
                              final allNotes =
                                  await JsonIOService.readJsonList<NoteModel>(
                                    JsonIOService.notesFile,
                                    (json) => NoteModel.fromJson(json),
                                  );
                              allNotes.insert(0, note);
                              await JsonIOService.writeJsonList(
                                JsonIOService.notesFile,
                                allNotes,
                                (n) => n.toJson(),
                              );
                              if (mounted) _loadData();
                              Navigator.pop(context);
                            },
                            child: Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _showTaskFormDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Form add task
              TaskFormScreen(),
            ],
          ),
        );
      },
    ).then((result) async {
      if (result != null) {
        final newTask = result as TaskModel;
        final allTasks = await JsonIOService.readJsonList<TaskModel>(
          JsonIOService.tasksFile,
          (json) => TaskModel.fromJson(json),
        );
        allTasks.add(newTask);
        await JsonIOService.writeJsonList(
          JsonIOService.tasksFile,
          allTasks,
          (task) => task.toJson(),
        );
        // Refresh data untuk update dashboard
        _loadData();
      }
    });
  }
}

class DashboardHomeContent extends StatelessWidget {
  final bool isDark;
  final List<TaskModel> todayTasks;
  final List<EventModel> upcomingEvents;
  final List<StudySessionModel> sessions;
  final String? username;
  final VoidCallback onShowNotificationDemo;
  final List<BarChartGroupData> weeklyBarData;
  final String weeklyHoursString;
  final VoidCallback onNotesLongPress;
  final VoidCallback onTrackerLongPress;
  final List<NoteModel> notes;
  const DashboardHomeContent({
    required this.isDark,
    required this.todayTasks,
    required this.upcomingEvents,
    required this.sessions,
    required this.username,
    required this.onShowNotificationDemo,
    required this.weeklyBarData,
    required this.weeklyHoursString,
    required this.onNotesLongPress,
    required this.onTrackerLongPress,
    required this.notes,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.grey[600];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      children: [
        // HEADER: Tododo (gradient) + toggle dark/light mode
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Tododo: minimalis di light mode, gradient di dark mode
            isDark
                ? ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Color(0xFF46A0FC), Color(0xFF6D5FFD)],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Tododo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.white, // akan di-mask oleh gradient
                      letterSpacing: 1.2,
                    ),
                  ),
                )
                : Text(
                  'Tododo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
            // Tombol notifikasi (bell)
            IconButton(
              icon: Icon(
                Icons.notifications_rounded,
                color: isDark ? Colors.white : Colors.deepPurple,
                size: 28,
              ),
              onPressed: onShowNotificationDemo,
              tooltip: 'Notifications',
            ),
          ],
        ),
        // Sapaan user
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 2, bottom: 18),
          child: Text(
            'Hello, ${username ?? ''}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: subTextColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // TASKS CARD dengan long press
        Stack(
          children: [
            _AnimatedSectionCard(
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(minHeight: 110),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient:
                          isDark
                              ? LinearGradient(
                                colors: [
                                  Color(0xFF23243A),
                                  Color(0xFF2B3A67),
                                  Color(0xFF46A0FC).withOpacity(0.18),
                                  Colors.white.withOpacity(0.07),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : LinearGradient(
                                colors: [Color(0xFFB2EBF2), Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isDark
                                  ? Color(0xFF46A0FC).withOpacity(0.13)
                                  : Color(0xFF6D5FFD).withOpacity(0.13),
                          blurRadius: 38,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tasks',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (todayTasks.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'No tasks for today.',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ...todayTasks
                            .take(2)
                            .map(
                              (task) =>
                                  _TaskListCard(task: task, isDark: isDark),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (todayTasks.length > 2)
              Positioned(
                top: 10,
                right: 18,
                child: _RedBadge(count: todayTasks.length - 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // DASHBOARD CARD (bisa juga dihold untuk tracker)
        Stack(
          children: [
            _AnimatedSectionCard(
              child: Container(
                constraints: BoxConstraints(minHeight: 90),
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient:
                      isDark
                          ? LinearGradient(
                            colors: [
                              Color(0xFF23243A),
                              Color(0xFF2B3A67),
                              Color(0xFF46A0FC).withOpacity(0.18),
                              Colors.white.withOpacity(0.07),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : LinearGradient(
                            colors: [Color(0xFFB2EBF2), Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
                              ? Color(0xFF46A0FC).withOpacity(0.13)
                              : Color(0xFF6D5FFD).withOpacity(0.13),
                      blurRadius: 38,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tracker',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ];
                                  if (value < 0 || value > 6)
                                    return SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      days[value.toInt()],
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white54
                                                : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                                interval: 1,
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY:
                              weeklyBarData
                                  .map((e) => e.barRods.first.toY)
                                  .fold(0.0, (a, b) => a > b ? a : b) +
                              10,
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                7,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  weeklyBarData[i].barRods.first.toY,
                                ),
                              ),
                              isCurved: true,
                              color: null,
                              gradient: LinearGradient(
                                colors:
                                    isDark
                                        ? [Color(0xFF46A0FC), Color(0xFF6D5FFD)]
                                        : [
                                          Color(0xFF6D5FFD),
                                          Color(0xFF46A0FC),
                                        ],
                              ),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                          minX: 0,
                          maxX: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Color(0xFF23243A).withOpacity(0.85)
                                      : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Color(0xFF46A0FC).withOpacity(0.13)
                                          : Color(0xFF6D5FFD).withOpacity(0.13),
                                  blurRadius: 16,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${sessions.length} Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isDark
                                            ? Color(0xFF46A0FC)
                                            : Color(0xFF6D5FFD),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'This week',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white54
                                            : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Color(0xFF23243A).withOpacity(0.85)
                                      : Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Color(0xFF46A0FC).withOpacity(0.13)
                                          : Color(0xFF6D5FFD).withOpacity(0.13),
                                  blurRadius: 16,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  weeklyHoursString,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isDark
                                            ? Color(0xFF46A0FC)
                                            : Color(0xFF6D5FFD),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hours',
                                  style: TextStyle(
                                    color:
                                        isDark
                                            ? Colors.white54
                                            : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              onLongPress: onTrackerLongPress,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // NOTES & EVENT CARD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        _AnimatedSectionCard(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 90),
                            margin: const EdgeInsets.only(right: 0, bottom: 18),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient:
                                  isDark
                                      ? LinearGradient(
                                        colors: [
                                          Color(0xFF23243A),
                                          Color(0xFF2B3A67),
                                          Color(0xFF46A0FC).withOpacity(0.18),
                                          Colors.white.withOpacity(0.07),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : LinearGradient(
                                        colors: [
                                          Color(0xFFB2EBF2),
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Color(0xFF46A0FC).withOpacity(0.13)
                                          : Color(0xFF6D5FFD).withOpacity(0.13),
                                  blurRadius: 38,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child:
                                notes.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No notes yet.',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white54
                                                  : Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.sticky_note_2,
                                              color:
                                                  isDark
                                                      ? Colors.blue[200]
                                                      : Colors.blue[700],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              'Notes',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ...notes.map(
                                          (n) => Text(
                                            n.content,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                          onLongPress: onNotesLongPress,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Stack(
                      children: [
                        _AnimatedSectionCard(
                          child: Container(
                            constraints: BoxConstraints(minHeight: 90),
                            margin: const EdgeInsets.only(left: 0, bottom: 18),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient:
                                  isDark
                                      ? LinearGradient(
                                        colors: [
                                          Color(0xFF23243A),
                                          Color(0xFF2B3A67),
                                          Color(0xFF46A0FC).withOpacity(0.18),
                                          Colors.white.withOpacity(0.07),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                      : LinearGradient(
                                        colors: [
                                          Color(0xFFB2EBF2),
                                          Colors.white,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDark
                                          ? Color(0xFF46A0FC).withOpacity(0.13)
                                          : Color(0xFF6D5FFD).withOpacity(0.13),
                                  blurRadius: 38,
                                  offset: Offset(0, 12),
                                ),
                              ],
                            ),
                            child:
                                upcomingEvents.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No event for today.',
                                        style: TextStyle(
                                          color:
                                              isDark
                                                  ? Colors.white54
                                                  : Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.event_note,
                                              color:
                                                  isDark
                                                      ? Colors.purple[200]
                                                      : Colors.purple[700],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              'Event',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        ...upcomingEvents.map(
                                          (e) => Text(
                                            e.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                          // Tidak ada long press untuk event
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedSectionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLongPress;
  const _AnimatedSectionCard({required this.child, this.onLongPress});

  @override
  State<_AnimatedSectionCard> createState() => _AnimatedSectionCardState();
}

class _AnimatedSectionCardState extends State<_AnimatedSectionCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardRadius = BorderRadius.circular(28);
    Widget cardContent = Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF23243A) : Colors.white,
            borderRadius: cardRadius,
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.10)
                        : Colors.blueGrey.withOpacity(0.07),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: widget.child,
        ),
        AnimatedOpacity(
          opacity: 0.08,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Color(0xFF46A0FC).withOpacity(0.12),
                            Color(0xFF181A20).withOpacity(0.18),
                          ]
                          : [
                            Color(0xFF6D5FFD).withOpacity(0.10),
                            Colors.white.withOpacity(0.18),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    // Wrap with ClipRRect to keep shadow/gradient inside
    cardContent = ClipRRect(borderRadius: cardRadius, child: cardContent);
    return GestureDetector(onLongPress: widget.onLongPress, child: cardContent);
  }
}

class _TaskListCard extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  const _TaskListCard({required this.task, required this.isDark});

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blueAccent;
      case 'study':
        return Colors.purpleAccent;
      case 'personal':
        return Colors.green;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Color(0xFFFF5252);
      case 'medium':
        return Color(0xFFFFA726);
      case 'low':
        return Color(0xFF66BB6A);
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
    String jam = date.hour.toString().padLeft(2, '0');
    String menit = date.minute.toString().padLeft(2, '0');
    String timeStr = '$jam:$menit';
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

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF23243A) : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.10)
                    : Colors.grey.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon kategori
          CircleAvatar(
            backgroundColor: getCategoryColor(task.category).withOpacity(0.18),
            child: Icon(
              getCategoryIcon(task.category),
              color: getCategoryColor(task.category),
            ),
          ),
          const SizedBox(width: 12),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: isDark ? Colors.white : Colors.black87,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[700],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      getDateLabel(task.dueDate),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate.hour.toString().padLeft(2, '0')}:${task.dueDate.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: getPriorityColor(task.priority),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      task.priority[0].toUpperCase() +
                          task.priority.substring(1),
                      style: TextStyle(
                        fontSize: 13,
                        color: getPriorityColor(task.priority),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final VoidCallback onPin;
  final Color cardColor;
  final Color textColor;

  const _EventCard({
    required this.title,
    required this.location,
    required this.time,
    required this.onPin,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Colors.deepPurple, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      time,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pin_drop, color: Colors.redAccent),
            onPressed: onPin,
            tooltip: 'Pin to Google Maps',
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onFabPressed;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double fabDiameter = 64;
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181A20) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.10)
                          : Colors.grey.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.check_circle_rounded,
                    label: 'Task',
                    isSelected: currentIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                ),
                SizedBox(width: fabDiameter),
                Expanded(
                  child: _NavItem(
                    icon: Icons.event_rounded,
                    label: 'Event',
                    isSelected: currentIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: currentIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                ),
              ],
            ),
          ),
          // FAB di tengah
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: onFabPressed,
              child: Container(
                width: fabDiameter,
                height: fabDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD),
                      isDark ? Color(0xFF6D5FFD) : Color(0xFF46A0FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Color(0xFF46A0FC) : Color(0xFF6D5FFD))
                          .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 0
                      ? Icons.add
                      : currentIndex == 1
                      ? Icons.task_alt
                      : currentIndex == 2
                      ? Icons.event
                      : Icons.add,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isSelected
            ? Colors.blueAccent
            : (isDark ? Colors.white70 : Colors.grey[600]);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AddOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 28,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

// Helper widget for red badge
class _RedBadge extends StatelessWidget {
  final int count;
  const _RedBadge({required this.count});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count > 0 ? '+${count}' : '0',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.blue[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SunburstPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final bool isDark;
  final bool isHalf;

  SunburstPainter({
    required this.center,
    required this.radius,
    required this.isDark,
    this.isHalf = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..shader = RadialGradient(
            colors:
                isDark
                    ? [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ]
                    : [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.05),
                      Colors.transparent,
                    ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));

    if (isHalf) {
      // Setengah lingkaran (atas)
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, size.width, center.dy));
      canvas.drawCircle(center, radius * 1.5, paint);
      canvas.restore();
    } else {
      canvas.drawCircle(center, radius * 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CircularAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
