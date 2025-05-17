import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class JsonIOService {
  // Nama file default
  static const String tasksFile = 'tasks.json';
  static const String notesFile = 'notes.json';
  static const String eventsFile = 'events.json';
  static const String studiesFile = 'studies.json';

  // Mendapatkan direktori aplikasi
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Membaca list model dari file JSON
  static Future<List<T>> readJsonList<T>(
    String filename,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final dir = await getAppDirectory();
      final file = File('${dir.path}/$filename');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('Error reading $filename: $e\n$st');
      return [];
    }
  }

  // Menulis list model ke file JSON
  static Future<void> writeJsonList<T>(
    String filename,
    List<T> list,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final dir = await getAppDirectory();
      final file = File('${dir.path}/$filename');
      final jsonList = list.map((e) => toJson(e)).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e, st) {
      debugPrint('Error writing $filename: $e\n$st');
    }
  }
}
