import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/event_model.dart';
import '../screens/dashboard_screen.dart';
import 'dashboard_screen.dart' show CustomBottomNavBar;
import '../routes.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<File> _getEventsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/events.json');
  }

  Future<void> _loadEvents() async {
    try {
      final file = await _getEventsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _events = jsonList.map((e) => EventModel.fromJson(e)).toList();
      } else {
        _events = [];
      }
      _events =
          _events.where((e) => e.date.isAfter(DateTime.now())).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (mounted) setState(() {});
    } catch (e) {
      _events = [];
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveEvents() async {
    final file = await _getEventsFile();
    final jsonList = _events.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> _deleteEvent(String id) async {
    _events.removeWhere((event) => event.id == id);
    await _saveEvents();
    _loadEvents();
  }

  Future<void> _editEvent(EventModel event) async {
    // TODO: Navigasi ke halaman edit event, lalu refresh setelah kembali
    // Navigator.push(...);
    // Setelah kembali, panggil _loadEvents();
  }

  Future<void> _addEvent() async {
    // TODO: Navigasi ke halaman tambah event, lalu refresh setelah kembali
    // Navigator.push(...);
    // Setelah kembali, panggil _loadEvents();
  }

  Future<void> _confirmDelete(EventModel event) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Delete Event?',
      desc: 'Event "${event.title}" will be permanently deleted.',
      btnCancelOnPress: () {},
      btnOkOnPress: () => _deleteEvent(event.id),
      btnOkText: 'Delete',
      btnCancelText: 'Cancel',
    ).show();
  }

  Future<void> _openMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        child:
            _events.isEmpty
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event, size: 64, color: Colors.purple[200]),
                    const SizedBox(height: 18),
                    Text(
                      'Belum ada event',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan event baru untuk mengatur jadwalmu!',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Dismissible(
                      key: Key(event.id),
                      background: _buildSwipeAction(
                        icon: Icons.edit,
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        text: 'Edit',
                      ),
                      secondaryBackground: _buildSwipeAction(
                        icon: Icons.delete,
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        text: 'Hapus',
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _editEvent(event);
                          return false;
                        } else if (direction == DismissDirection.endToStart) {
                          await _confirmDelete(event);
                          return false;
                        }
                        return false;
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event,
                            color: Colors.deepPurple,
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(event.date),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _openMaps(event.location),
                                    child: Text(
                                      event.location,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing:
                              event.hasAlarm
                                  ? const Icon(
                                    Icons.alarm,
                                    color: Colors.orange,
                                  )
                                  : null,
                          onTap: () => _openMaps(event.location),
                        ),
                      ),
                    );
                  },
                ),
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
}
