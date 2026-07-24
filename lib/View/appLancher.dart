import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/UserController/user_notification_controller.dart';
import 'package:team_app/Model/User%20Model.dart';
import 'package:team_app/View/AdminScreens/admin_dashboard_page.dart';
import 'package:team_app/View/AuthScreens/login_screen.dart';
import 'package:team_app/View/onbordin_screen.dart';
import 'package:team_app/View/shell_screen.dart';
import 'package:team_app/main.dart'; 

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startApp();
    });
  }

  Future<AppUser> getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 4));

    return AppUser.fromMap(doc.data()!);
  }

  Future<void> _startApp() async {
    try {
      await firebaseInitialization.timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint("⏳ تم تخطي تهيئة الفايربيز لحماية الواجهة من التعليق");
      });

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!mounted) return;

      if (!onboardingDone) {
        Get.offAll(() => const OnboardingScreen());
        return;
      }

      if (!isLoggedIn) {
        Get.offAll(() => const LoginScreen());
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.offAll(() => const LoginScreen());
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .timeout(const Duration(seconds: 4), onTimeout: () {
            return FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get(const GetOptions(source: Source.cache));
          });

      final role = doc.data()?['role'] ?? 'user';

      if (role == 'admin') {
        Get.offAll(() => const AdminDashboard());
        return;
      }

      AppUser userData;
      try {
        userData = await getUserData(currentUser.uid);
      } catch (e) {
        userData = AppUser(
          name: "مستخدم محلي",
          email: currentUser.email ?? "",
          studentId: currentUser.uid, 
          college: "غير محدد",
          studyYear: "1",
          joinYear: "2026",
          role: "user",
        ); 
      }

      // 🎯 التعديل الجوهري: نفتح الـ ShellScreen ونحقن الـ Controller الخاص بها فوراً في نفس اللحظة
      Get.offAll(
        () => ShellScreen(user: userData),
        binding: BindingsBuilder(() {
          Get.put(UserNotificationController(), permanent: true);
        }),
      );

    } catch (e) {
      debugPrint("⚠️ حدث خطأ أثناء فحص حالة التطبيق: $e");
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}