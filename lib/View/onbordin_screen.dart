import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/View/AuthScreens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  double currentPage = 0;

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.hasClients && controller.page != null) {
        setState(() {
          currentPage = controller.page!;
        });
      }
    });
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  final List<Map<String, dynamic>> pagesData = [
    {
      "text": "مرحباً بكم في دليل\nجامعة اللاذقية",
      "icon": Icons.waving_hand_rounded,
      "color": const Color(0xFFD1E9FF),
    },
    {
      "text":
          "يساعد التطبيق الطلاب وأعضاء الهيئة التدريسية في الوصول للمعلومات",
      "image": "assets/latakiaUNV.jpg",
      "color": const Color(0xFFE8F5E9),
    },
    {
      "text": "ابدأ باستخدام خدمات التطبيق للوصول السريع والسهل",
      "images": [
        "assets/picture1.jpg",
        "assets/picture2.jpg",
        "assets/picture3.jpg",
      ],
      "color": const Color(0xFFFFF3E0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentPage.round().clamp(0, pagesData.length - 1);

    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, pagesData[safeIndex]['color']],
              ),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: GeometricPainter(),
            ),
          ),

          // الصفحات
          PageView.builder(
            controller: controller,
            itemCount: pagesData.length,
            itemBuilder: (_, i) {
              double scale = (1 - (currentPage - i).abs() * 0.3).clamp(
                0.8,
                1.0,
              );

              return Opacity(
                opacity: (1 - (currentPage - i).abs()).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: buildPageContent(i),
                ),
              );
            },
          ),

          // التحكم السفلي + زر التخطي الجديد
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // المؤشرات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pagesData.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: safeIndex == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003A8C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // زر التالي / ابدأ الآن
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003A8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (safeIndex < pagesData.length - 1) {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        await finishOnboarding();
                      }
                    },
                    child: Text(
                      safeIndex == pagesData.length - 1
                          ? "ابدأ الآن"
                          : "التالي",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // زر التخطي الجديد تحت زر التالي
                TextButton(
                  onPressed: finishOnboarding,
                  child: const Text(
                    "تخطي",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF003A8C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // محتوى الصفحات
  Widget buildPageContent(int index) {
    final data = pagesData[index];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 100),

            if (index == 0) ...[
              const SizedBox(height: 50),
              const Icon(
                Icons.waving_hand_rounded,
                size: 100,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 40),
              Text(
                data['text'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003A8C),
                ),
              ),
            ],

            if (index == 1) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data['image'],
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                data['text'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003A8C),
                ),
              ),
            ],

            if (index == 2) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data['images'][0],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        data['images'][1],
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        data['images'][2],
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                data['text'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003A8C),
                ),
              ),
            ],

            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}

// الرسومات الخلفية
class GeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shapeColor = const Color(0xFF003A8C).withOpacity(0.1);

    final fillPaint = Paint()
      ..color = shapeColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = shapeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.1),
      100,
      fillPaint,
    );

    canvas.save();
    canvas.translate(size.width * 0.85, size.height * 0.35);
    canvas.rotate(0.6);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 90, 90), strokePaint);
    canvas.restore();

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.85),
      65,
      strokePaint,
    );

    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.8);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    path.close();
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
