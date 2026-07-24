// lib/features/colleges/colleges_screen.dart

import 'package:flutter/material.dart';
import 'package:team_app/View/UserScreens/selectRoutePage.dart';

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
const List<_CollegeInfo> _colleges = [
  _CollegeInfo('كلية الهندسة المعلوماتية', Icons.computer_rounded, Color(0xFF0A8F6B)),
  _CollegeInfo('كلية الهندسة الميكانيكية', Icons.precision_manufacturing_rounded, Color(0xFF3B82F6)),
  _CollegeInfo('كلية الطب', Icons.local_hospital_rounded, Color(0xFFEC4899)),
  _CollegeInfo('كلية العمارة', Icons.architecture_rounded, Color(0xFFF59E0B)),
  _CollegeInfo('كلية الحقوق', Icons.gavel_rounded, Color(0xFF8B5CF6)),
  _CollegeInfo('كلية الاقتصاد', Icons.bar_chart_rounded, Color(0xFF06B6D4)),
  _CollegeInfo('كلية العلوم', Icons.science_rounded, Color(0xFF10B981)),
  _CollegeInfo('كلية الآداب', Icons.menu_book_rounded, Color(0xFFEF4444)),
];

class _CollegeInfo {
  final String name;
  final IconData icon;
  final Color color;
  const _CollegeInfo(this.name, this.icon, this.color);
}

// ─────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────
class CollegesScreen extends StatelessWidget {
  const CollegesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكليات',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'اختر الكلية للاطلاع على التفاصيل',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5A6B69),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
                itemCount: _colleges.length,
                itemBuilder: (context, index) => _CollegeCard(
                  college: _colleges[index],
                  index: index,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  COLLEGE CARD
// ─────────────────────────────────────────────
class _CollegeCard extends StatefulWidget {
  final _CollegeInfo college;
  final int index;

  const _CollegeCard({required this.college, required this.index});

  @override
  State<_CollegeCard> createState() => _CollegeCardState();
}

class _CollegeCardState extends State<_CollegeCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final college = widget.college;

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),

          // ───────────────────────────────────────────────
          //  🔥 التنقّل إلى صفحة المسارات
          // ───────────────────────────────────────────────
          onTap: () async {
            if (college.name == 'كلية الهندسة المعلوماتية') {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SelectRoutePage(),
                ),
              );
            }
          },
          // ───────────────────────────────────────────────

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: college.color.withValues(alpha: _pressed ? 0.18 : 0.10),
                  blurRadius: _pressed ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: college.color.withValues(alpha: _pressed ? 0.3 : 0.0),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: college.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(college.icon, color: college.color, size: 28),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        college.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0D1B1A),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: college.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'استكشف',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: college.color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: college.color, size: 13),
                          ],
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
  }
}
