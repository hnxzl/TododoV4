import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String location;
  final bool hasAlarm;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.hasAlarm,
    this.onTap,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isToday ? Colors.blue[50] : Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.event,
                color: isToday ? Colors.blue : Colors.deepPurple,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 15,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (hasAlarm)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.alarm, color: Colors.orange, size: 22),
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
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${date.day} $bulan ${date.year} $jam:$menit';
  }
}
