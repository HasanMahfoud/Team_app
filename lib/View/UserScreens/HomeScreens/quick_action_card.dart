import 'package:flutter/material.dart';
import 'package:team_app/View/UserScreens/about_university_screen.dart';
import 'package:team_app/View/UserScreens/academic_calendar_screen.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class QuickActionCard extends StatefulWidget {
  final QuickAction action;

  const QuickActionCard({super.key, required this.action});

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        final label = widget.action.label;

        if (label == 'معلومات') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutUniversityScreen()),
          );
        }

        if (label == 'التقويم الجامعي') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AcademicCalendarScreen()),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_pressed ? 0.93 : 1.0),
        transformAlignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: widget.action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.action.color.withOpacity(0.15),
                ),
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.action.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}