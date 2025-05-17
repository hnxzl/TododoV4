import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/note_model.dart';
import '../widgets/note_card.dart';
import '../screens/dashboard_screen.dart';
import '../routes.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<NoteModel> _notes = [];
  List<NoteModel> _filteredNotes = [];
  String _filterTag = 'Semua';
  List<String> _tagFilters = ['Semua'];
  String _searchKeyword = '';

  // Untuk tambah/edit note
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  Color _selectedColor = Colors.yellow[200]!;
  String? _editingNoteId;

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

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<File> _getNotesFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes.json');
  }

  Future<void> _loadNotes() async {
    try {
      final file = await _getNotesFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        if (!mounted) return;
        setState(() {
          _notes = jsonList.map((e) => NoteModel.fromJson(e)).toList();
          _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _updateTagFilters();
          _applyFilters();
        });
      } else {
        if (!mounted) return;
        setState(() {
          _notes = [];
          _applyFilters();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notes = [];
        _applyFilters();
      });
    }
  }

  Future<void> _saveNotes() async {
    final file = await _getNotesFile();
    final jsonList = _notes.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  void _updateTagFilters() {
    final tags = _notes.map((e) => e.tag).toSet().toList();
    _tagFilters = ['Semua', ...tags.where((t) => t.isNotEmpty)];
  }

  void _applyFilters() {
    List<NoteModel> filtered =
        _filterTag == 'Semua'
            ? List.from(_notes)
            : _notes.where((note) => note.tag == _filterTag).toList();
    // Filter by keyword
    if (_searchKeyword.isNotEmpty) {
      filtered =
          filtered
              .where(
                (note) =>
                    note.content.toLowerCase().contains(
                      _searchKeyword.toLowerCase(),
                    ) ||
                    note.tag.toLowerCase().contains(
                      _searchKeyword.toLowerCase(),
                    ),
              )
              .toList();
    }
    _filteredNotes = filtered;
    if (mounted) setState(() {});
  }

  void _showNoteModal({NoteModel? note}) {
    Color editingColor;
    if (note != null) {
      _editingNoteId = note.id;
      _contentController.text = note.content;
      _tagController.text = note.tag;
      if (note.color is int) {
        editingColor = Color(note.color);
      } else if (note.color is String) {
        String hex = note.color.toString().replaceAll('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        editingColor = Color(int.parse('0x$hex'));
      } else if (note.color is Color) {
        editingColor = note.color;
      } else {
        editingColor = Colors.yellow[200]!;
      }
      _selectedColor = editingColor;
    } else {
      _editingNoteId = null;
      _contentController.clear();
      _tagController.clear();
      editingColor = Colors.yellow[200]!;
      _selectedColor = editingColor;
    }
    List<Color> colorOptions = List<Color>.from(_colorChoices);
    if (!colorOptions.any((c) => c.value == editingColor.value)) {
      colorOptions.insert(0, editingColor);
    }
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
                note == null ? 'Tambah Catatan' : 'Edit Catatan',
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
                maxLength: 16,
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
                  counterText: '', // Hide the character counter
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
                      colorOptions.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    _selectedColor.value == color.value
                                        ? Colors.black
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child:
                                  _selectedColor.value == color.value
                                      ? Icon(
                                        Icons.check,
                                        key: ValueKey(color.value),
                                        size: 18,
                                        color: Colors.black,
                                      )
                                      : SizedBox.shrink(),
                            ),
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
                        if (_contentController.text.trim().isEmpty) return;
                        if (_editingNoteId == null) {
                          final note = NoteModel(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            content: _contentController.text.trim(),
                            tag: _tagController.text.trim(),
                            color: _selectedColor.value,
                            createdAt: DateTime.now(),
                          );
                          _notes.insert(0, note);
                        } else {
                          final idx = _notes.indexWhere(
                            (n) => n.id == _editingNoteId,
                          );
                          if (idx != -1) {
                            _notes[idx] = NoteModel(
                              id: _editingNoteId!,
                              content: _contentController.text.trim(),
                              tag: _tagController.text.trim(),
                              color: _selectedColor.value,
                              createdAt: _notes[idx].createdAt,
                            );
                          }
                        }
                        await _saveNotes();
                        _updateTagFilters();
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text(note == null ? 'Tambah' : 'Simpan'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(NoteModel note) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Hapus Catatan?',
      desc: 'Catatan ini akan dihapus secara permanen.',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        _notes.removeWhere((n) => n.id == note.id);
        await _saveNotes();
        _updateTagFilters();
        _applyFilters();
      },
      btnOkText: 'Hapus',
      btnCancelText: 'Batal',
      btnCancelColor: Colors.grey,
      btnOkColor: Colors.redAccent,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari catatan...',
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
            const SizedBox(height: 12),
            // Filter Tag (max 7 + 'Lainnya' jika lebih dari 8)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._tagFilters.take(8).map((tag) {
                    if (_tagFilters.length > 8 &&
                        _tagFilters.indexOf(tag) == 7) {
                      // Chip 'Lainnya'
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Pilih Tag'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children:
                                          _tagFilters
                                              .skip(8)
                                              .map(
                                                (t) => ListTile(
                                                  title: Text(t),
                                                  onTap:
                                                      () => Navigator.pop(
                                                        context,
                                                        t,
                                                      ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                );
                              },
                            );
                            if (selected != null) {
                              setState(() {
                                _filterTag = selected;
                              });
                              _applyFilters();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1C6F5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD1C6F5,
                                  ).withOpacity(0.13),
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              'Lainnya',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      final selected = tag == _filterTag;
                      final color = const Color(0xFFD1C6F5);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _filterTag = tag;
                            });
                            _applyFilters();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: selected ? color : color.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow:
                                  selected
                                      ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.13),
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  _filteredNotes.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sticky_note_2,
                            size: 64,
                            color: Colors.amber[200],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Belum ada catatan',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Catat ide, tugas, atau inspirasi harianmu di sini!',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                      : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          final Color bgColor =
                              note.color is int
                                  ? Color(note.color)
                                  : Colors.yellow[200]!;
                          final Color fontColor =
                              bgColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white;
                          return AnimatedScale(
                            scale: 1.0,
                            duration: Duration(milliseconds: 350),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    bgColor.withOpacity(0.95),
                                    bgColor.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _showNoteModal(note: note),
                                  onLongPress: () => _confirmDelete(note),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.content.split('\n').first,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: fontColor,
                                          ),
                                        ),
                                        if (note.content.split('\n').length > 1)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              note.content
                                                  .split('\n')
                                                  .skip(1)
                                                  .join(' '),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.nunito(
                                                fontSize: 14,
                                                color: fontColor.withOpacity(
                                                  0.85,
                                                ),
                                              ),
                                            ),
                                          ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 13,
                                                  color: fontColor.withOpacity(
                                                    0.7,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  _formatDate(note.createdAt),
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 11,
                                                    color: fontColor
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (note.tag.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: fontColor
                                                        .withOpacity(0.13),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.local_offer,
                                                        size: 14,
                                                        color: fontColor
                                                            .withOpacity(0.7),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Flexible(
                                                        child: Text(
                                                          note.tag,
                                                          style:
                                                              GoogleFonts.nunito(
                                                                fontSize: 12,
                                                                color: fontColor
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format: 12 Mei 2024
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
    return '${date.day} $bulan ${date.year}';
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
