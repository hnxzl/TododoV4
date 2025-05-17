import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final DateTime dueDate;
  final String priority; // 'tinggi', 'sedang', 'rendah'
  final String category;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onCheck;
  final String? description;

  const TaskCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.category,
    required this.isCompleted,
    this.onTap,
    this.onCheck,
    this.description,
  });

  String getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String getFormattedDate(DateTime date) {
    return '${date.day} ${getMonthShort(date.month)} ${date.year}';
  }

  String getFormattedTime(DateTime date) {
    int hour = date.hour;
    String ampm = 'AM';
    if (hour >= 12) {
      ampm = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color getPriorityColor() {
      switch (priority.toLowerCase()) {
        case 'high':
          return isDark ? kDarkPriorityHigh : kLightPriorityHigh;
        case 'medium':
          return isDark ? kDarkPriorityMedium : kLightPriorityMedium;
        case 'low':
          return isDark ? kDarkPriorityLow : kLightPriorityLow;
        default:
          return theme.colorScheme.primary.withOpacity(0.3);
      }
    }

    Color getCategoryColor() {
      switch (category.toLowerCase()) {
        case 'work':
          return const Color(0xFF8AB4F8); // biru soft
        case 'personal':
          return const Color(0xFF81C784); // hijau soft
        case 'home':
          return const Color(0xFFFFD180); // kuning soft
        case 'shopping':
          return const Color(0xFFFF8A65); // oranye soft
        case 'study':
          return const Color(0xFFB39DDB); // ungu soft
        default:
          return theme.colorScheme.primary.withOpacity(0.18);
      }
    }

    IconData getCategoryIcon() {
      switch (category.toLowerCase()) {
        case 'work':
          return Icons.work_outline;
        case 'personal':
          return Icons.person_outline;
        case 'home':
          return Icons.home_outlined;
        case 'shopping':
          return Icons.shopping_bag_outlined;
        case 'study':
          return Icons.menu_book_rounded;
        default:
          return Icons.label_outline;
      }
    }

    String getPriorityLabel() {
      switch (priority.toLowerCase()) {
        case 'high':
          return 'High';
        case 'medium':
          return 'Medium';
        case 'low':
          return 'Low';
        default:
          return '';
      }
    }

    IconData getPriorityIcon() {
      switch (priority.toLowerCase()) {
        case 'high':
          return Icons.flag_rounded;
        case 'medium':
          return Icons.flag_rounded;
        case 'low':
          return Icons.flag_outlined;
        default:
          return Icons.flag_outlined;
      }
    }

    Color getCategoryIconColor() {
      switch (category.toLowerCase()) {
        case 'work':
          return const Color(0xFF4285F4); // biru
        case 'personal':
          return const Color(0xFF26A69A); // teal
        case 'home':
          return const Color(0xFF90CAF9); // biru muda
        case 'shopping':
          return const Color(0xFFFFB74D); // oranye pastel
        case 'study':
          return const Color(0xFF9575CD); // ungu
        default:
          return Colors.grey;
      }
    }

    Color getPriorityIconColor() {
      switch (priority.toLowerCase()) {
        case 'high':
          return const Color(0xFFFF5252); // merah pastel
        case 'medium':
          return const Color(0xFFFFD54F); // kuning pastel
        case 'low':
          return const Color(0xFF66BB6A); // hijau pastel
        default:
          return Colors.grey;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.cardColor.withOpacity(0.18),
              width: 1.0,
            ),
          ),
          color: isDark ? const Color(0xFF23222A) : const Color(0xFFF7F6FB),
          shadowColor: theme.colorScheme.primary.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Stack icon kategori & badge prioritas (diperbesar dan diposisikan tengah kiri)
                Container(
                  height: 56, // agar stack tetap di tengah vertikal
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Icon kategori (lebih besar)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: getCategoryIconColor(),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            getCategoryIcon(),
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Badge prioritas (setengah di dalam, setengah di luar lingkaran kategori, border putih tipis + shadow)
                      Positioned(
                        bottom: -5, // geser ke bawah agar setengah keluar
                        right: -5, // geser ke kanan agar setengah keluar
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1, // border putih tipis
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: getPriorityIconColor(),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  getPriorityIcon(),
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                // Judul, deskripsi, dan waktu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color:
                              isCompleted
                                  ? theme.disabledColor
                                  : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      if (description != null &&
                          description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.dividerColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getFormattedTime(dueDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.dividerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.dividerColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getFormattedDate(dueDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.dividerColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onCheck != null)
                  IconButton(
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isCompleted
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                    ),
                    onPressed: onCheck,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
