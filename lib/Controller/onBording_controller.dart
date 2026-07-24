import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/View/AuthScreens/login_screen.dart';

class Onbordingcontroller {
    // ------------------ إنهاء الـ Onboarding ------------------
  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("onboarding_seen", true);
    Get.off(() => LoginScreen());
  }

}