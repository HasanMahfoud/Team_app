import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/AdminController/notification_controller.dart';

class SendNotificationPage extends StatelessWidget {
  const SendNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ربط الـ Controller بالصفحة
    final controller = Get.put(NotificationController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "إرسال إشعار عام",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 2,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // إغلاق لوحة المفاتيح
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ℹ️ كرت توضيحي للأدمن
                Card(
                  color: theme.primaryColor.withOpacity(0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.primaryColor),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "تنبيه: الإشعار المكتوب أدناه سيصل بشكل فوري لجميع الطلاب والمستخدمين المسجلين في التطبيق كرسالة منبثقة وسيتم حفظه في سجل الإشعارات.",
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 📌 حقل عنوان الإشعار
                Text(
                  "عنوان الإشعار",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.titleController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: "مثال: تغيير قاعة امتحان هندسة البرمجيات",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "الرجاء كتابة عنوان الإشعار";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 📝 حقل محتوى الإشعار
                Text(
                  "محتوى الرسالة",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.bodyController,
                  maxLines: 5,
                  maxLength: 250,
                  decoration: InputDecoration(
                    hintText: "اكتب هنا تفاصيل الإشعار بدقة ليراها الطلاب...",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.message_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "الرجاء كتابة محتوى الإشعار";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 📤 زر الإرسال المستجيب لحالة التحميل
                Obx(() {
                  final isLoading = controller.isLoading.value;
                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : () => controller.sendNotification(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      isLoading ? "جاري الإرسال للمستخدمين..." : "إرسال الإشعار الآن",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}