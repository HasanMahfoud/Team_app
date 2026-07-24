import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/AdminController/room_management_controller.dart';

class RoomManagementPage extends StatelessWidget {
  const RoomManagementPage({super.key});

  static const Color primaryThemeColor = Color.fromARGB(255, 76, 175, 125);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RoomManagementController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryThemeColor,
        title: const Text(
          "إدارة القاعات",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNodeDialog(context, controller),
        backgroundColor: primaryThemeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 شريط البحث
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن قاعة...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),

          // 📌 قائمة القاعات
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final nodes = controller.filteredNodes;

              if (nodes.isEmpty) {
                return const Center(child: Text("لا توجد قاعات مطابقة للبحث"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: nodes.length,
                itemBuilder: (context, index) {
                  final node = nodes[index];
                  final data = node.data() as Map<String, dynamic>;
                  final images = (data["image"] is List) ? List<String>.from(data["image"]) : [];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: images.isNotEmpty
                                ? Image.network(
                                    images[0],
                                    key: ValueKey(images[0]),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["title"] ?? "بدون اسم",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "ID: ${data["id"]}",
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "الجيران: ${(data["neighbors"] is List) ? (data["neighbors"] as List).join(", ") : 'لا يوجد'}",
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == "edit") {
                                _showEditNodeDialog(context, controller, node);
                              } else if (value == "delete") {
                                _showDeleteNodeDialog(context, controller, node.id);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Text("تعديل القاعة"),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: Text(
                                  "حذف القاعة",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🤝 دالة اختيار الجيران بالـ GetX
  Future<List<String>> _showNeighborsSelectionDialog(
      BuildContext context, RoomManagementController controller, List<String> initiallySelected) async {
    final tempSelected = List<String>.from(initiallySelected).obs;
    final allRoomIds = controller.allNodes
        .map((doc) => (doc.data() as Map<String, dynamic>)["id"]?.toString() ?? "")
        .where((id) => id.isNotEmpty)
        .toList();

    if (allRoomIds.isEmpty) {
      Get.snackbar("تنبيه", "لا توجد قاعات مضافة مسبقاً لتحديدها كجيران", snackPosition: SnackPosition.BOTTOM);
      return [];
    }

    final List<String>? result = await Get.dialog<List<String>>(
      AlertDialog(
        title: const Text("اختر الجيران المحيطين"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: allRoomIds.length,
            itemBuilder: (context, index) {
              final roomId = allRoomIds[index];
              return Obx(() {
                final isChecked = tempSelected.contains(roomId);
                return CheckboxListTile(
                  title: Text(roomId),
                  value: isChecked,
                  activeColor: primaryThemeColor,
                  onChanged: (val) {
                    if (val == true) {
                      tempSelected.add(roomId);
                    } else {
                      tempSelected.remove(roomId);
                    }
                  },
                );
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryThemeColor),
            onPressed: () => Get.back(result: tempSelected.toList()),
            child: const Text("تأكيد الاختيار", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? initiallySelected;
  }

  // ➕ نافذة إضافة قاعة
  void _showAddNodeDialog(BuildContext context, RoomManagementController controller) {
    final idController = TextEditingController();
    final titleController = TextEditingController();

    final selectedNeighbors = <String>[].obs;
    final selectedImages = <String>[].obs;
    final isUploading = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("إضافة قاعة جديدة"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: "ID", hintText: "مثال: Room101"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "اسم القاعة"),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: const Text("تحديد جيران القاعة", style: TextStyle(fontSize: 14)),
                    subtitle: Obx(() => Text(
                          selectedNeighbors.isEmpty ? "لم يتم اختيار جيران بعد" : selectedNeighbors.join(", "),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                    trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
                    onTap: () async {
                      final result = await _showNeighborsSelectionDialog(context, controller, selectedNeighbors);
                      selectedNeighbors.assignAll(result);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() => isUploading.value
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text("جاري رفع الصور إلى السيرفر..."),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          final urls = await controller.imageService.pickAndUploadImages((loading) {
                            isUploading.value = loading;
                          });
                          if (urls.isNotEmpty) {
                            selectedImages.assignAll(urls);
                          }
                        },
                        icon: const Icon(Icons.image_search),
                        label: const Text("اختيار صور القاعة"),
                      )),
                const SizedBox(height: 10),
                Obx(() => selectedImages.isNotEmpty
                    ? SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: selectedImages
                              .map((url) => Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(url, width: 90, fit: BoxFit.cover),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: isUploading.value ? null : () => Get.back(),
                child: const Text("إلغاء"),
              )),
          Obx(() => ElevatedButton(
                onPressed: isUploading.value
                    ? null
                    : () async {
                        final id = idController.text.trim();
                        final title = titleController.text.trim();

                        if (id.isEmpty || title.isEmpty) {
                          Get.snackbar("تنبيه", "يرجى تعبئة جميع الحقول المطلوبة", snackPosition: SnackPosition.BOTTOM);
                          return;
                        }

                        Get.back();
                        await controller.addNode(
                          id: id,
                          title: title,
                          images: selectedImages.toList(),
                          neighbors: selectedNeighbors.toList(),
                        );
                      },
                child: const Text("إضافة"),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✏️ نافذة تعديل قاعة
  void _showEditNodeDialog(BuildContext context, RoomManagementController controller, DocumentSnapshot node) {
    final data = node.data() as Map<String, dynamic>;

    final idController = TextEditingController(text: data["id"]);
    final titleController = TextEditingController(text: data["title"]);

    final selectedNeighbors = ((data["neighbors"] is List) ? List<String>.from(data["neighbors"]) : <String>[]).obs;
    final selectedImages = ((data["image"] is List) ? List<String>.from(data["image"]) : <String>[]).obs;
    final isUploading = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("تعديل بيانات القاعة"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: "ID"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "اسم القاعة"),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: const Text("تعديل جيران القاعة", style: TextStyle(fontSize: 14)),
                    subtitle: Obx(() => Text(
                          selectedNeighbors.isEmpty ? "لم يتم اختيار جيران بعد" : selectedNeighbors.join(", "),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                    trailing: const Icon(Icons.arrow_drop_down_circle_outlined),
                    onTap: () async {
                      final result = await _showNeighborsSelectionDialog(context, controller, selectedNeighbors);
                      selectedNeighbors.assignAll(result);
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Obx(() => isUploading.value
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text("جاري تحديث الصور..."),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          final urls = await controller.imageService.pickAndUploadImages((loading) {
                            isUploading.value = loading;
                          });
                          if (urls.isNotEmpty) {
                            selectedImages.assignAll(urls);
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("تغيير الصور"),
                      )),
                const SizedBox(height: 10),
                Obx(() => selectedImages.isNotEmpty
                    ? SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: selectedImages
                              .map((url) => Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(url, width: 90, fit: BoxFit.cover),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() => TextButton(
                onPressed: isUploading.value ? null : () => Get.back(),
                child: const Text("إلغاء"),
              )),
          Obx(() => ElevatedButton(
                onPressed: isUploading.value
                    ? null
                    : () async {
                        Get.back();
                        await controller.updateNode(
                          docId: node.id,
                          id: idController.text.trim(),
                          title: titleController.text.trim(),
                          images: selectedImages.toList(),
                          neighbors: selectedNeighbors.toList(),
                        );
                      },
                child: const Text("حفظ"),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // 🗑️ نافذة حذف قاعة
  void _showDeleteNodeDialog(BuildContext context, RoomManagementController controller, String docId) {
    Get.dialog(
      AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حذف هذه القاعة نهائياً؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("حذف", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Get.back();
              await controller.deleteNode(docId);
            },
          ),
        ],
      ),
    );
  }
}