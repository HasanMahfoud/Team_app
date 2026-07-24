import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/UserController/AuthController/auth_login_controller.dart';
import 'package:team_app/View/AdminScreens/admin_dashboard_page.dart';
import 'package:team_app/View/appLancher.dart';

import '../../core/theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AuthController _authController;

  late AnimationController _animationController;
  late Animation<double> fadeIn;
  late Animation<Offset> slideIn;

  @override
  void initState() {
    super.initState();
    // إسناد الـ Controller باستخدام Get.put
    _authController = Get.put(AuthController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fadeIn =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    slideIn = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    _authController.login(
      onSuccess: (targetRole) {
        if (targetRole == 'admin') {
          Get.offAll(() => const AdminDashboard());
        } else {
          Get.offAll(() => const AppLauncher());
        }
      },
      onError: (errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainBlue = AppColors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: fadeIn,
            child: SlideTransition(
              position: slideIn,
              child: Form(
                key: _authController.formKey,
                child: Column(
                  children: [
                    Text(
                      "مرحباً بك 👋",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: mainBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "سجّل دخولك للوصول إلى القاعات",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // حقل البريد الإلكتروني
                    TextFormField(
                      controller: _authController.emailController,
                      decoration: InputDecoration(
                        labelText: "الإيميل",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _authController.validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // حقل كلمة السر
                    TextFormField(
                      controller: _authController.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "كلمة السر",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _authController.validatePassword,
                    ),
                    const SizedBox(height: 20),

                    // اختيار الدور (مستخدم أم مسؤول)
                    Obx(
                      () => ToggleButtons(
                        isSelected: [
                          _authController.selectedRole.value == "user",
                          _authController.selectedRole.value == "admin",
                        ],
                        borderRadius: BorderRadius.circular(16),
                        selectedColor: Colors.white,
                        fillColor: mainBlue,
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("مستخدم عادي"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("مسؤول"),
                          ),
                        ],
                        onPressed: (index) {
                          _authController
                              .setRole(index == 0 ? "user" : "admin");
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    // زر تسجيل الدخول
                    Obx(
                      () => _authController.isLoading.value
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainBlue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 6,
                              ),
                              onPressed: _handleLogin,
                              child: const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // رابط إنشاء حساب جديد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("ليس لديك حساب؟"),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const SignUpScreen());
                          },
                          child: const Text(
                            "إنشاء حساب جديد",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
