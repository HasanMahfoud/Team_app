import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AboutUniversityScreen extends StatelessWidget {
  const AboutUniversityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'معلومات الجامعة',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoCard(
            icon: Icons.location_on_rounded,
            title: 'الموقع الجغرافي',
            subtitle: 'اللاذقية – سوريا\nطريق الجامعة – المدخل الرئيسي',
          ),
          _InfoCard(
            icon: Icons.school_rounded,
            title: 'عدد الكليات',
            subtitle: 'تضم الجامعة أكثر من 20 كلية ومعهداً.',
          ),
          _InfoCard(
            icon: Icons.people_alt_rounded,
            title: 'عدد الطلاب',
            subtitle: 'أكثر من 70,000 طالب وطالبة.',
          ),
          _InfoCard(
            icon: Icons.history_rounded,
            title: 'تاريخ التأسيس',
            subtitle: 'تأسست الجامعة عام 1971.',
          ),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'نبذة عن الجامعة',
            subtitle:
                'تعد الجامعة من أكبر المؤسسات التعليمية في سوريا، وتضم العديد من الكليات والمعاهد، وتوفر بيئة تعليمية متكاملة.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
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
