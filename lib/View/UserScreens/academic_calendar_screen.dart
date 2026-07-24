import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AcademicCalendarScreen extends StatelessWidget {
  const AcademicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التقويم الجامعي',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _CalendarItem(
            title: 'بداية الفصل الدراسي الأول',
            date: '10/10/2025',
            icon: Icons.play_circle_fill_rounded,
          ),
          _CalendarItem(
            title: 'امتحانات الفصل الأول',
            date: '5/1/2026',
            icon: Icons.edit_calendar_rounded,
          ),
          _CalendarItem(
            title: 'العطلة الانتصافية',
            date: '12/2/2026',
            icon: Icons.beach_access_rounded,
          ),
          _CalendarItem(
            title: 'بداية الفصل الدراسي الثاني',
            date: '25/2/2026',
            icon: Icons.play_circle_outline_rounded,
          ),
          _CalendarItem(
            title: 'امتحانات الفصل الثاني',
            date: '10/6/2026',
            icon: Icons.event_available_rounded,
          ),
        ],
      ),
    );
  }
}

class _CalendarItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;

  const _CalendarItem({
    required this.title,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
