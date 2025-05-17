import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/study_model.dart';
import '../screens/dashboard_screen.dart' show CustomBottomNavBar;
import '../routes.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  List<StudySessionModel> _sessions = [];
  bool _isStudying = false;
  bool _isBreak = false;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _focusMode = false; // Placeholder DND

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<File> _getSessionFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/study_sessions.json');
  }

  Future<void> _loadSessions() async {
    try {
      final file = await _getSessionFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _sessions = jsonList.map((e) => StudySessionModel.fromJson(e)).toList();
      } else {
        _sessions = [];
      }
      setState(() {});
    } catch (e) {
      _sessions = [];
      setState(() {});
    }
  }

  Future<void> _saveSessions() async {
    final file = await _getSessionFile();
    final jsonList = _sessions.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  void _startStudy() {
    setState(() {
      _isStudying = true;
      _isBreak = false;
      _startTime = DateTime.now();
      _elapsedSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _endStudy() async {
    _timer?.cancel();
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!).inMinutes;
    final session = StudySessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _startTime!,
      endTime: endTime,
      durationInMinutes: duration,
      isFocused: _focusMode,
    );
    _sessions.add(session);
    await _saveSessions();
    if (!mounted) return;
    setState(() {
      _isStudying = false;
      _isBreak = true;
    });
    _loadSessions();
    // Otomatis mulai break 5 menit (dummy, bisa diubah)
    Future.delayed(const Duration(minutes: 5), () {
      if (!mounted) return;
      setState(() {
        _isBreak = false;
      });
    });
  }

  void _cancelStudy() {
    _timer?.cancel();
    setState(() {
      _isStudying = false;
      _isBreak = false;
      _elapsedSeconds = 0;
    });
  }

  // Statistik
  int get _totalMinutesThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _sessions
        .where((s) => s.startTime.isAfter(startOfWeek))
        .fold(0, (sum, s) => sum + s.durationInMinutes);
  }

  int get _totalMinutesThisMonth {
    final now = DateTime.now();
    return _sessions
        .where(
          (s) => s.startTime.year == now.year && s.startTime.month == now.month,
        )
        .fold(0, (sum, s) => sum + s.durationInMinutes);
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
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }
    return bars;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Belajar'),
        actions: [
          Row(
            children: [
              const Text('Fokus'),
              Switch(
                value: _focusMode,
                onChanged: (val) {
                  setState(() {
                    _focusMode = val;
                  });
                  // TODO: Integrasi DND jika ingin
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // Statistik total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCard(
                  label: 'Minggu ini',
                  value:
                      '${(_totalMinutesThisWeek / 60).toStringAsFixed(1)} jam',
                  icon: Icons.bar_chart,
                  color: Colors.blue,
                ),
                _StatCard(
                  label: 'Bulan ini',
                  value:
                      '${(_totalMinutesThisMonth / 60).toStringAsFixed(1)} jam',
                  icon: Icons.calendar_month,
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Grafik mingguan
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      _weeklyBarData
                          .map((e) => e.barRods.first.toY)
                          .fold(0.0, (a, b) => a > b ? a : b) +
                      10,
                  barGroups: _weeklyBarData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt() % 7]),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Timer belajar
            if (_isStudying)
              Column(
                children: [
                  const Text(
                    'Belajar sedang berlangsung...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDuration(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _endStudy,
                    icon: const Icon(Icons.stop),
                    label: const Text('Selesai Belajar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  TextButton(
                    onPressed: _cancelStudy,
                    child: const Text('Batalkan'),
                  ),
                ],
              )
            else if (_isBreak)
              Column(
                children: [
                  const Text('Waktu istirahat!'),
                  const SizedBox(height: 8),
                  const Icon(Icons.coffee, size: 48, color: Colors.brown),
                  const SizedBox(height: 8),
                  const Text(
                    'Ambil waktu istirahat 5 menit sebelum lanjut belajar.',
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _startStudy,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Belajar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
