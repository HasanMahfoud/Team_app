import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_app/View/AdminScreens/notification_page.dart';
import 'package:team_app/View/AdminScreens/path_management_page.dart';
import 'package:team_app/View/AdminScreens/room_management_page.dart';
import 'package:team_app/View/AdminScreens/user_management_page.dart';
import 'package:team_app/View/AuthScreens/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> logout(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("تأكيد تسجيل الخروج"),
        content: const Text("هل أنت متأكد أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            child: const Text("تسجيل الخروج"),
            onPressed: () async {
              Navigator.pop(context); // إغلاق النافذة

              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", false);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

  PreferredSizeWidget buildAdminAppBar(BuildContext context) {
    
  final theme = Theme.of(context);

  return PreferredSize(
    preferredSize: const Size.fromHeight(85),
    child: Container(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings,
                color: theme.scaffoldBackgroundColor, size: 26),
            const SizedBox(width: 10),
            Text(
              "لوحة التحكم",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert,
                color: theme.scaffoldBackgroundColor, size: 26),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: buildAdminAppBar(context),


      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Text(
              "مرحباً بك في لوحة تحكم المسؤول",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  adminButton(
                    context: context,
                    icon: Icons.people_alt,
                    label: "إدارة المستخدمين",
                    onTap: () {
                    Get.to(UserManagementPage());

                    },
                  ),
                  adminButton(
                    context: context,
                    icon: Icons.meeting_room,
                    label: "إدارة القاعات",
                    onTap: () {
                      Get.to(RoomManagementPage());
                    },
                  ),
                  adminButton(
                    context: context,
                    icon: Icons.alt_route,
                    label: "إدارة المسارات",
                    onTap: () {
                      Get.to(PathManagementPage());
                    },
                  ),
                  adminButton(
                    context: context,
                    icon: Icons.notifications_active,
                    label: "إرسال إشعار",
                    onTap: () {
                        Get.to(SendNotificationPage());
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => logout(context),
                child: const Text(
                  "تسجيل الخروج",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget adminButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
