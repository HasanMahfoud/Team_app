import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // Rx Variables for Dropdowns & UI State
  final RxnString selectedCollege = RxnString();
  final RxnString selectedStudyYear = RxnString();
  final RxnString selectedJoinYear = RxnString();
  final RxBool isLoading = false.obs;

  final String role = "user";

  // Dynamic Lists Data
  final List<String> colleges = const [
    "كلية الهندسة المعلوماتية",
    "كلية الحقوق",
    "كلية طب الأسنان",
    "كلية الطب",
    "كلية الصيدلة",
    "كلية الهندسة المدنية",
    "كلية الهندسة الميكانيكية",
    "كلية الاقتصاد",
    "كلية العلوم",
    "كلية الآداب",
  ];

  final List<String> studyYears = const [
    "السنة الأولى",
    "السنة الثانية",
    "السنة الثالثة",
    "السنة الرابعة",
    "السنة الخامسة",
  ];

  final List<String> joinYears = const [
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
  ];

  // Validation Logic
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "أدخل اسمك";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty || !value.contains("@")) {
      return "أدخل إيميل صحيح";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "كلمة السر قصيرة (6 أحرف على الأقل)";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "أدخل تأكيد كلمة السر";
    }
    if (value.trim() != passwordController.text.trim()) {
      return "كلمة السر غير متطابقة";
    }
    return null;
  }

  // Sign Up Process
  Future<void> signUp({
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedCollege.value == null ||
        selectedStudyYear.value == null ||
        selectedJoinYear.value == null) {
      onError("يرجى اختيار جميع الحقول القائمة");
      return;
    }

    isLoading.value = true;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': nameController.text.trim(),
        'studentId': idController.text.trim(),
        'email': emailController.text.trim(),
        'college': selectedCollege.value,
        'studyYear': selectedStudyYear.value,
        'joinYear': selectedJoinYear.value,
        'role': role,
      });

      onSuccess();
    } catch (e) {
      onError("خطأ: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
