import 'package:flutter/material.dart';
import 'package:team_app/View/UserScreens/selectRoutePage.dart';

class CollegeCardData {
  final String name;
  final String asset;

  const CollegeCardData({required this.name, required this.asset});
}

class CollegeCard extends StatelessWidget {
  final CollegeCardData college;

  const CollegeCard({super.key, required this.college});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        width: 212,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: DecorationImage(
            image: AssetImage(college.asset),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.52), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              college.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}