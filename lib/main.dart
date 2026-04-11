import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/View/OnBordingScreen.dart';
import 'package:team_app/View/loginScreen.dart';
import 'package:team_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  bool seen = prefs.getBool("onboarding_seen") ?? false;

  runApp(MyApp(seen: seen));
}

class MyApp extends StatelessWidget {
  final bool seen;
  const MyApp({super.key, required this.seen});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: seen ? LoginScreen() : OnboardingScreen(),
    );
  }
}
