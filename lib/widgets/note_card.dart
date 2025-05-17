import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String content;
  final String tag;
  final dynamic color; // int (Color value) atau String (hex)
  final DateTime createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.content,
    required this.tag,
    required this.color,
    required this.createdAt,
    this.onTap,
    this.onLongPress,
  });

  Color getNoteColor() {
    if (color is int) {
      return Color(color);
    } else if (color is String) {
      // Jika hex string, misal "#FFEE58"
      String hex = color.toString().replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse('0x$hex'));
    }
    return Colors.yellow[200]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        color: getNoteColor(),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Konten note
              Text(
                content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (tag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    return '${date.day} $bulan ${date.year}';
  }
}
