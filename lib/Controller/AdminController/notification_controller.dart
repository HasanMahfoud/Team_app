import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // عناصر التحكم بالنصوص والنموذج
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // حالة التحميل المستجيبة
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  // 🚀 دالة إرسال الإشعار
  Future<void> sendNotification() async {
    // التحقق من صحة المدخلات
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final title = titleController.text.trim();
      final body = bodyController.text.trim();

      // إضافة الإشعار إلى Firestore
      await _firestore.collection("notifications").add({
        "title": title,
        "body": body,
        "createdAt": FieldValue.serverTimestamp(),
        "sender": "Admin",
        "isRead": false,
      });

      // تفريغ الحقول بعد الإرسال بنجاح
      titleController.clear();
      bodyController.clear();

      // إظهار رسالة النجاح عبر GetX
      Get.snackbar(
        "تم الإرسال",
        "تم إرسال الإشعار بنجاح لجميع المستخدمين!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // إظهار رسالة الخطأ
      Get.snackbar(
        " خطأ",
        "حدث خطأ أثناء الإرسال: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}