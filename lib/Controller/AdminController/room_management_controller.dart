import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/AdminController/imgBB_service.dart';

class RoomManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImgBBService imageService = ImgBBService();

  // المتغيرات التفاعلية
  final RxString searchQuery = ''.obs;
  final RxList<QueryDocumentSnapshot> allNodes = <QueryDocumentSnapshot>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToNodes();
    });
  }

  // 📡 الاستماع الفوري للقاعات من Firestore
  void _listenToNodes() {
    _firestore.collection("nodes").orderBy("id").snapshots().listen((snapshot) {
      allNodes.value = snapshot.docs;
      isLoading.value = false;
    }, onError: (error) {
      isLoading.value = false;
      debugPrint("Error fetching nodes: $error");
    });
  }

  // 🔍 قائمة القاعات المفلترة بحسب البحث
  List<QueryDocumentSnapshot> get filteredNodes {
    if (searchQuery.isEmpty) return allNodes;
    final query = searchQuery.value.toLowerCase().trim();
    return allNodes.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final id = (data["id"] ?? "").toString().toLowerCase();
      final title = (data["title"] ?? "").toString().toLowerCase();
      return id.contains(query) || title.contains(query);
    }).toList();
  }

  // ➕ إضافة قاعة جديدة
  Future<void> addNode({
    required String id,
    required String title,
    required List<String> images,
    required List<String> neighbors,
  }) async {
    try {
      await _firestore.collection("nodes").add({
        "id": id,
        "title": title,
        "image": images,
        "neighbors": neighbors,
      });
      Get.snackbar(
        "نجاح",
        "تمت إضافة القاعة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل إضافة القاعة: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // ✏️ تحديث قاعة موجودة
  Future<void> updateNode({
    required String docId,
    required String id,
    required String title,
    required List<String> images,
    required List<String> neighbors,
  }) async {
    try {
      await _firestore.collection("nodes").doc(docId).update({
        "id": id,
        "title": title,
        "image": images,
        "neighbors": neighbors,
      });
      Get.snackbar(
        "نجاح",
        "تم تحديث القاعة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل تحديث القاعة: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  // 🗑️ حذف قاعة
  Future<void> deleteNode(String docId) async {
    try {
      await _firestore.collection("nodes").doc(docId).delete();
      Get.snackbar(
        "نجاح",
        "تم حذف القاعة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل حذف القاعة: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}