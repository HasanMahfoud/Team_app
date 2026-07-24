import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_app/Model/User%20Model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:team_app/View/AuthScreens/login_screen.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _avatarScale;
  
  // متغير محلي لحفظ بيانات المستخدم وتحديثها فورياً بالصفحة
  late AppUser _currentUser;
  
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadSettings();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    
    _avatarScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  // تحميل إعدادات التطبيق المحفوظة بجهاز الطالب
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs?.getBool('notifications_enabled') ?? true;
      _darkMode = _prefs?.getBool('dark_mode') ?? (appThemeModeNotifier.value == ThemeMode.dark);
    });
  }

  // حفظ وتغيير حالة الوضع الليلي دائمًا
  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    await _prefs?.setBool('dark_mode', value);
    appThemeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  // التحكم باستقبال الإشعارات المرسلة من الأدمن
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _prefs?.setBool('notifications_enabled', value);
    
    if (value) {
      // 💡 تفعيل استقبال الإشعارات العامة من الأدمن
      // await FirebaseMessaging.instance.subscribeToTopic('admin_notifications');
      Get.snackbar('الإشعارات', 'تم تفعيل استقبال إشعارات الإدارة والكلية',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success.withOpacity(0.2));
    } else {
      // 💡 إلغاء الاشتراك لتفادي وصول أي إشعار مرسل من الأدمن
      // await FirebaseMessaging.instance.unsubscribeFromTopic('admin_notifications');
      Get.snackbar('الإشعارات', 'تم إيقاف الإشعارات، لن تتلقى تنبيهات من الإدارة بعد الآن',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.error.withOpacity(0.2));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHero(
              topPad: topPad,
              avatarScale: _avatarScale,
              user: _currentUser,
              onEditTap: _openEditProfileSheet,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _ProfileStats(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _AcademicCard(user: _currentUser),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _SettingsSection(
                notificationsEnabled: _notificationsEnabled,
                darkMode: _darkMode,
                onNotifToggle: _toggleNotifications,
                onDarkToggle: _toggleDarkMode,
                onSupportTap: _showSupportDialog,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: _ActionButtons(
                onEditProfile: _openEditProfileSheet,
                onLogout: _showLogoutDialog,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  // فتح ورقة منبثقة لتعديل بيانات الحساب الشخصي وتحديث الواجهة مباشرة فور الحفظ
  void _openEditProfileSheet() {
    final nameController = TextEditingController(text: _currentUser.name);
    final collegeController = TextEditingController(text: _currentUser.college);
    final idController = TextEditingController(text: _currentUser.studentId);
    final yearController = TextEditingController(text: _currentUser.studyYear);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text('تعديل البيانات الشخصية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 20),
              _buildEditTextField(label: 'الاسم الكامل', controller: nameController, icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildEditTextField(label: 'الكلية / التخصص', controller: collegeController, icon: Icons.school_outlined),
              const SizedBox(height: 12),
              _buildEditTextField(label: 'الرقم الجامعي', controller: idController, icon: Icons.badge_outlined, isNumeric: true),
              const SizedBox(height: 12),
              _buildEditTextField(label: 'السنة الدراسية', controller: yearController, icon: Icons.timeline_outlined),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      Get.snackbar('تنبيه', 'يجب إدخال الاسم المعتمد على الأقل');
                      return;
                    }
                    setState(() {
                      // تحديث الـ Object المحلي فورياً لإعادة بناء الصفحة بالقيم الجديدة
                      _currentUser = AppUser(
                        name: nameController.text.trim(),
                        email: _currentUser.email,
                        college: collegeController.text.trim(),
                        studentId: idController.text.trim(),
                        studyYear: yearController.text.trim(),
                        joinYear: _currentUser.joinYear, role: '',
                      );
                    });
                    
                    // 💡 هنا يمكنك تمرير التعديلات لقاعدة البيانات (Firestore أو MySQL API)
                    // await UsersController.to.updateUserData(_currentUser);

                    Get.back();
                    Get.snackbar('نجاح العملية', 'تم تحديث ملفك الأكاديمي بنجاح',
                        snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.success.withOpacity(0.2));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildEditTextField({required String label, required TextEditingController controller, required IconData icon, bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // عرض نافذة الدعم الفني الخاصة بالتواصل البريدي
  void _showSupportDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.contact_support_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('تواصل مع فريق الدعم', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إذا واجهتك أي مشكلة برمجية أو تقنية داخل التطبيق، يمكنك مراسلتنا مباشرة عبر البريد الإلكتروني المعتمد للإدارة أدناه:',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text(
                  'hasanmahfoud6740@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary, letterSpacing: 0.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // 💡 باستخدام حزمة url_launcher يمكنك فتح تطبيق الإيميل الخاص بالطالب مباشرة:
              // launchUrl(Uri.parse("mailto:hasanmahfoud6740@gmail.com?subject=Support_Request"));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('إرسال رسالة الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد تسجيل الخروج
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك الجامعي؟', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // 💡 تنفيذ خروج الحساب
              // await FirebaseAuth.instance.signOut();
              // Get.offAll(() => const LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تسجيل خروج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROFILE HERO
// ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final double topPad;
  final Animation<double> avatarScale;
  final AppUser user;
  final VoidCallback onEditTap;

  const _ProfileHero({
    required this.topPad,
    required this.avatarScale,
    required this.user,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ملفي الشخصي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: onEditTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ScaleTransition(
                    scale: avatarScale,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name.characters.first
                                  : "؟",
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🎓 ${user.college.isEmpty ? 'لم تحدد الكلية' : user.college}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    user.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PROFILE STATS
// ─────────────────────────────────────────────────────────────

class _ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: const [
          Expanded(
              child: _StatItem(
                  value: '3.9',
                  label: 'المعدل التراكمي',
                  icon: Icons.auto_graph_rounded)),
          _Divider(),
          Expanded(
              child: _StatItem(
                  value: '87',
                  label: 'ساعة مكتملة',
                  icon: Icons.check_circle_rounded)),
          _Divider(),
          Expanded(
              child: _StatItem(
                  value: '4',
                  label: 'السنة الحالية',
                  icon: Icons.school_rounded)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppColors.surfaceVariant);
  }
}

// ─────────────────────────────────────────────────────────────
// ACADEMIC CARD
// ─────────────────────────────────────────────────────────────

class _AcademicCard extends StatelessWidget {
  final AppUser user;

  const _AcademicCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'المعلومات الأكاديمية',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _InfoRow(
              icon: Icons.badge_rounded,
              label: 'الرقم الجامعي',
              value: user.studentId.isEmpty ? "غير متوفر" : user.studentId),

          const SizedBox(height: 14),

          _InfoRow(
              icon: Icons.timeline_rounded,
              label: 'السنة الدراسية',
              value: user.studyYear.isEmpty ? "غير محدد" : user.studyYear),

          const SizedBox(height: 14),

          _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'سنة الالتحاق',
              value: user.joinYear),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SETTINGS SECTION
// ─────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final bool darkMode;
  final ValueChanged<bool> onNotifToggle;
  final ValueChanged<bool> onDarkToggle;
  final VoidCallback onSupportTap;

  const _SettingsSection({
    required this.notificationsEnabled,
    required this.darkMode,
    required this.onNotifToggle,
    required this.onDarkToggle,
    required this.onSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentViolet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_rounded,
                      color: AppColors.accentViolet, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  'الإعدادات المتاحة',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),

          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'إشعارات الأدمن',
            subtitle: 'تلقي التنبيهات والتعميمات الهامة',
            color: AppColors.accentAmber,
            trailing: Switch.adaptive(
              value: notificationsEnabled,
              onChanged: onNotifToggle,
              activeColor: AppColors.primary,
            ),
          ),

          _SettingsDivider(),

          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            label: 'الوضع الليلي',
            subtitle: 'تغيير المظهر العام للتطبيق',
            color: AppColors.accentViolet,
            trailing: Switch.adaptive(
              value: darkMode,
              onChanged: onDarkToggle,
              activeColor: AppColors.primary,
            ),
          ),

          _SettingsDivider(),

          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            label: 'الخصوصية والأمان',
            subtitle: 'إدارة أذونات الحساب الحالي',
            color: AppColors.primary,
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textTertiary),
            onTap: () {},
          ),

          _SettingsDivider(),

          _SettingsTile(
            icon: Icons.help_rounded,
            label: 'الدعم والمساعدة',
            subtitle: 'تواصل فوري مع مطوري النظام',
            color: AppColors.accentRose,
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textTertiary),
            onTap: onSupportTap,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(24))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7))),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  
  const _ActionButtons({required this.onEditProfile, required this.onLogout});
       
  // دالة تسجيل الخروج المنظِفة للكاش والمسارات
  Future<void> _executeLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setBool('hasReadEverything', false); 

      Get.offAll(() => const LoginScreen());
    } catch (e) {
      debugPrint("⚠️ خطأ أثناء تسجيل الخروج: $e");
      Get.offAll(() => const LoginScreen());
    }
  }

  // 💡 دالة إظهار نافذة التأكيد قبل تسجيل الخروج
  void _showLogoutConfirmation() {
    Get.defaultDialog(
      title: "تأكيد تسجيل الخروج",
      titleStyle: const TextStyle(
        fontFamily: 'Cairo', // استبدلها بنوع الخط المستخدم عندك لو رغبت
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: "هل أنت متأكد من أنك تريد تسجيل الخروج من الحساب؟",
      middleTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
      ),
      backgroundColor: Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      
      // زر الإلغاء
      textCancel: "إلغاء",
      cancelTextColor: AppColors.textTertiary,
      onCancel: () {
        // الـ Dialog يغلق تلقائياً عند الضغط على إلغاء
      },

      // زر التأكيد
      textConfirm: "تأكيد",
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error, // لون أحمر متناسق مع طبيعة الزر
      onConfirm: () async {
        Get.back(); // إغلاق الـ Dialog أولاً
        await _executeLogout(); // تنفيذ عملية تسجيل الخروج
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زر تعديل الملف الشخصي
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onEditProfile,
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // زر تسجيل الخروج
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _showLogoutConfirmation, // 🎯 استدعاء نافذة التأكيد هنا
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}