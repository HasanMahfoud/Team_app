import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // المتغيرات التفاعلية
  final RxString searchQuery = ''.obs;
  final RxList<QueryDocumentSnapshot> allUsers = <QueryDocumentSnapshot>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // الانتظار حتى اكتمال رسم الشاشة وانيميشن التنقل أولاً ثم الاستماع لبيانات Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToUsers();
    });
  }

  void _listenToUsers() {
    _firestore.collection("users").orderBy("name").snapshots().listen((snapshot) {
      allUsers.value = snapshot.docs;
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      debugPrint("Error fetching users: $error");
    });
  }

  // 🔍 قائمة المستخدمين المفلترة ديناميكياً
  List<QueryDocumentSnapshot> get filteredUsers {
    if (searchQuery.isEmpty) return allUsers;
    final query = searchQuery.value.toLowerCase().trim();
    return allUsers.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data["name"] ?? "").toString().toLowerCase();
      final email = (data["email"] ?? "").toString().toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  // 🔄 1. تحديث دور المستخدم
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection("users").doc(userId).update({"role": newRole});
      Get.snackbar(
        "نجاح", 
        "تم تحديث دور المستخدم بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ", 
        "فشل تحديث الدور: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // ✏️ 2. تحديث بيانات المستخدم (الدالة المفقودة)
  Future<void> updateUserData(String userId, String name, String universityId) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "name": name,
        "universityId": universityId,
      });
      Get.snackbar(
        "نجاح",
        "تم تحديث بيانات المستخدم بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل تحديث البيانات: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // 🗑️ 3. حذف حساب المستخدم (الدالة المفقودة)
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection("users").doc(userId).delete();
      Get.snackbar(
        "نجاح",
        "تم حذف الحساب نهائياً",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل حذف الحساب: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}