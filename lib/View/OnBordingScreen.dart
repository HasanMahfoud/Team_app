import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/View/LoginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  int pageIndex = 0;

  List<Map<String, String>> pages = [
    {
      "title": "مرحبًا بك",
      "subtitle": "تطبيق رسمي يساعدك على الوصول إلى المعلومات والخدمات بسهولة وموثوقية."
    },
    {
      "title": "سهولة الاستخدام",
      "subtitle": "واجهة بسيطة وواضحة تمنحك أفضل تجربة ممكنة."
    },
    {
      "title": "ابدأ الآن",
      "subtitle": "سجّل دخولك وابدأ باستخدام خدمات التطبيق بكل سهولة."
    },
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("onboarding_seen", true);
    Get.off(() => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: controller,
        onPageChanged: (index) {
          setState(() => pageIndex = index);
        },
        itemCount: pages.length,
        itemBuilder: (_, index) {
          return Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // العنوان
                Text(
                  pages[index]["title"]!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003A8C),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // النص
                Text(
                  pages[index]["subtitle"]!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF005FCC),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // مؤشر الصفحات (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (dotIndex) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: pageIndex == dotIndex ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: pageIndex == dotIndex
                            ? Color(0xFF003A8C)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // زر Next أو Get Started
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF003A8C),
                        Color(0xFF005FCC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (index == pages.length - 1) {
                        finishOnboarding();
                      } else {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      index == pages.length - 1 ? "ابدأ الآن" : "التالي",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // زر Skip
                if (index != pages.length - 1)
                  TextButton(
                    onPressed: finishOnboarding,
                    child: const Text(
                      "تخطي",
                      style: TextStyle(
                        color: Color(0xFF003A8C),
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
