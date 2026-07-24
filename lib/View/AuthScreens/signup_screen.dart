import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/UserController/AuthController/auth_signup_controller.dart';
import '../../core/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late final SignUpController _signUpController;

  late AnimationController _controller;
  late Animation<double> fadeIn;
  late Animation<Offset> slideIn;

  @override
  void initState() {
    super.initState();
    _signUpController = Get.put(SignUpController());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    slideIn = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    _signUpController.signUp(
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إنشاء الحساب بنجاح")),
        );
        Get.back();
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
                key: _signUpController.formKey,
                child: Column(
                  children: [
                    Text(
                      "إنشاء حساب جديد ✨",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: mainBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "املأ البيانات للانضمام إلى التطبيق",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // الاسم الكامل
                    TextFormField(
                      controller: _signUpController.nameController,
                      decoration: InputDecoration(
                        labelText: "الاسم الكامل",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _signUpController.validateName,
                    ),
                    const SizedBox(height: 16),

                    // الرقم الجامعي
                    TextFormField(
                      controller: _signUpController.idController,
                      decoration: InputDecoration(
                        labelText: "الرقم الجامعي (اختياري)",
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // الكلية
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "الكلية",
                        prefixIcon: const Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: _signUpController.colleges
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          _signUpController.selectedCollege.value = v,
                      validator: (v) => v == null ? "اختر الكلية" : null,
                    ),
                    const SizedBox(height: 16),

                    // السنة الدراسية
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "السنة الدراسية",
                        prefixIcon: const Icon(Icons.timeline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: _signUpController.studyYears
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          _signUpController.selectedStudyYear.value = v,
                      validator: (v) =>
                          v == null ? "اختر السنة الدراسية" : null,
                    ),
                    const SizedBox(height: 16),

                    // سنة الالتحاق
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "سنة الالتحاق",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      items: _signUpController.joinYears
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          _signUpController.selectedJoinYear.value = v,
                      validator: (v) => v == null ? "اختر سنة الالتحاق" : null,
                    ),
                    const SizedBox(height: 16),

                    // الإيميل
                    TextFormField(
                      controller: _signUpController.emailController,
                      decoration: InputDecoration(
                        labelText: "الإيميل",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _signUpController.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // كلمة السر
                    TextFormField(
                      controller: _signUpController.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "كلمة السر",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _signUpController.validatePassword,
                    ),
                    const SizedBox(height: 16),

                    // تأكيد كلمة السر
                    TextFormField(
                      controller: _signUpController.confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "تأكيد كلمة السر",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      validator: _signUpController.validateConfirmPassword,
                    ),

                    const SizedBox(height: 30),

                    // زر إنشاء الحساب
                    Obx(
                      () => _signUpController.isLoading.value
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
                              onPressed: _handleSignUp,
                              child: const Text(
                                "إنشاء الحساب",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
