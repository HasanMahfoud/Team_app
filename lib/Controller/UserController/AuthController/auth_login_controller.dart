import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/Model/User%20Model.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // مفتاح النموذج والمتحكمات النصية
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // متغيرات التفاعل بالحالة (Rx)
  final RxBool isLoading = false.obs;
  final RxString selectedRole = "user".obs;

  // تغيير الدور المختار
  void setRole(String role) {
    selectedRole.value = role;
  }

  // التوابع الخاصة بالتحقق Validations
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "أدخل إيميل صحيح";
    }
    if (!value.contains("@") || !value.contains(".")) {
      return "أدخل إيميل صحيح";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "أدخل كلمة السر";
    }
    if (value.length < 6) {
      return "كلمة السر يجب أن تكون 6 أحرف على الأقل";
    }
    return null;
  }

  // دالة تسجيل الدخول كاملة
  Future<void> login({
    required Function(String targetRole) onSuccess,
    required Function(String error) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // 1. تسجيل الدخول عبر Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user!;
      final docRef = _firestore.collection('users').doc(user.uid);
      var doc = await docRef.get();

      // 2. إذا كان مستخدم جديد ولم يُنشأ له مستند بعد
      if (!doc.exists) {
        await docRef.set({
          'name': user.displayName ?? "مستخدم جديد",
          'studentId': "",
          'email': user.email,
          'role': "user",
        });
        doc = await docRef.get();
      }

      final roleInDb = doc.data()?['role'] ?? "user";

      // 3. التحقق من تطابق الدور المختار مع قاعدة البيانات
      if (roleInDb != selectedRole.value) {
        onError("نوع الحساب غير صحيح");
        return;
      }

      // 4. حفظ حالة تسجيل الدخول
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // 5. التوجيه في حال النجاح
      onSuccess(roleInDb);
    } catch (e) {
      onError("خطأ: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // جلب بيانات المستخدم
  Future<AppUser> getUserData(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();
    return AppUser.fromMap(doc.data()!);
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  Stream<User?> authState() {
    return _auth.authStateChanges();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
