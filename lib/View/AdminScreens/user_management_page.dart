import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/AdminController/user_management_controller.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManagementController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "إدارة المستخدمين",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // 🔍 شريط البحث
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "ابحث عن مستخدم (الاسم أو الإيميل)...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.searchQuery.value = value,
            ),
          ),

          // 📌 قائمة المستخدمين
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = controller.filteredUsers;

              if (users.isEmpty) {
                return const Center(
                  child: Text("لا يوجد مستخدمون مطابقون للبحث"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final data = user.data() as Map<String, dynamic>;
                  final role = data["role"] ?? "user";

                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 10),
                    shadowColor: theme.primaryColor.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: role == "admin" ? Colors.red : theme.primaryColor,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        data["name"] ?? "بدون اسم",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data["email"] ?? ""),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: role == "admin"
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: role == "admin" ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == "change_role") {
                            _showRoleDialog(context, controller, user);
                          } else if (value == "edit") {
                            _showEditUserDialog(context, controller, user);
                          } else if (value == "delete") {
                            _showDeleteUserDialog(context, controller, user);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: "change_role",
                            child: Text("تغيير الدور (أدمن/مستخدم)"),
                          ),
                          const PopupMenuItem(
                            value: "edit",
                            child: Text("تعديل البيانات الأساسية"),
                          ),
                          const PopupMenuItem(
                            value: "delete",
                            child: Text(
                              "حذف الحساب نهائياً",
                              style: TextStyle(color: Colors.red),
                            ),
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

  // ⭐ 1. نافذة اختيار الدور
  void _showRoleDialog(BuildContext context, UserManagementController controller, DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;
    RxString selectedRole = (data["role"] ?? "user").toString().obs;

    Get.dialog(
      AlertDialog(
        title: const Text("تغيير دور المستخدم"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => RadioListTile<String>(
                  title: const Text("User (طالب مستجد)"),
                  value: "user",
                  groupValue: selectedRole.value,
                  onChanged: (value) => selectedRole.value = value!,
                )),
            Obx(() => RadioListTile<String>(
                  title: const Text("Admin (مسؤول لوحة التحكم)"),
                  value: "admin",
                  groupValue: selectedRole.value,
                  onChanged: (value) => selectedRole.value = value!,
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.updateUserRole(user.id, selectedRole.value);
            },
            child: const Text("تحديث الدور"),
          ),
        ],
      ),
    );
  }

  // ✏️ 2. نافذة تعديل بيانات المستخدم
  void _showEditUserDialog(BuildContext context, UserManagementController controller, DocumentSnapshot user) {
    final data = user.data() as Map<String, dynamic>;

    final nameController = TextEditingController(text: data["name"]);
    final idController = TextEditingController(text: data["universityId"] ?? "");

    Get.dialog(
      AlertDialog(
        title: const Text("تعديل بيانات المستخدم"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "الاسم الكامل"),
            ),
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: "الرقم الجامعي"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final id = idController.text.trim();

              if (name.isEmpty) {
                Get.snackbar(
                  "تنبيه", 
                  "يرجى إدخال الاسم الكامل",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.amber.withOpacity(0.9),
                  colorText: Colors.black,
                );
                return;
              }

              Get.back();
              await controller.updateUserData(user.id, name, id);
            },
            child: const Text("حفظ التعديلات"),
          ),
        ],
      ),
    );
  }

  // 🗑️ 3. نافذة تأكيد حذف الحساب
  void _showDeleteUserDialog(BuildContext context, UserManagementController controller, DocumentSnapshot user) {
    Get.dialog(
      AlertDialog(
        title: const Text("تأكيد حذف الحساب"),
        content: const Text("هل أنت متأكد من حذف هذا المستخدم نهائياً؟ لن يتمكن من تسجيل الدخول مجدداً."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Get.back();
              await controller.deleteUser(user.id);
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}