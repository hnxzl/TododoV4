import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _username = '';
  bool _isDark = false;
  bool _notifOn = true;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _usernameController.text = _username;
      _isDark = prefs.getBool('isDark') ?? false;
      _notifOn = prefs.getBool('notifOn') ?? true;
    });
  }

  Future<void> _saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text.trim());
    setState(() {
      _username = _usernameController.text.trim();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username berhasil disimpan!')),
    );
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', value);
    setState(() {
      _isDark = value;
    });
    // Untuk produksi, trigger Provider/Bloc/ThemeMode di sini
  }

  Future<void> _toggleNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifOn', value);
    setState(() {
      _notifOn = value;
    });
  }

  Future<void> _exportData() async {
    final dir = await getApplicationDocumentsDirectory();
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList();
    Map<String, dynamic> allData = {};
    for (var file in files) {
      final name = file.uri.pathSegments.last;
      final content = await file.readAsString();
      allData[name] = jsonDecode(content);
    }
    final exportFile = File('${dir.path}/tododo_export.json');
    await exportFile.writeAsString(jsonEncode(allData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data diekspor ke ${exportFile.path}')),
    );
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      final importFile = File(result.files.single.path!);
      final dir = await getApplicationDocumentsDirectory();
      final content = await importFile.readAsString();
      final Map<String, dynamic> allData = jsonDecode(content);
      for (var entry in allData.entries) {
        final file = File('${dir.path}/${entry.key}');
        await file.writeAsString(jsonEncode(entry.value));
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil diimpor!')));
      _loadPrefs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Username'),
            subtitle: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter username',
                border: InputBorder.none,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUsername,
              tooltip: 'Save Username',
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Appearance & Notification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _isDark,
            onChanged: _toggleTheme,
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('Notification'),
            value: _notifOn,
            onChanged: _toggleNotif,
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export Data'),
            subtitle: const Text('Export all app data to JSON file'),
            onTap: _exportData,
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Data'),
            subtitle: const Text('Import app data from JSON file'),
            onTap: _importData,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Tododo v1.0\nby ezra ben'),
          ),
        ],
      ),
    );
  }
}
