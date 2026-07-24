import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:team_app/Controller/UserController/user_notification_controller.dart';
import 'package:team_app/View/UserScreens/HomeScreens/college_card.dart';
import 'package:team_app/View/UserScreens/HomeScreens/hero_header.dart';
import 'package:team_app/View/UserScreens/HomeScreens/quick_action_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heroController;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  // 🎯 ضمان وجود وحقن كنترولر الإشعارات فور فتح الشاشة الرئيسية
  late final UserNotificationController _notificationController;

  final List<QuickAction> _quickActions = const [
    QuickAction(
      icon: Icons.calendar_month_rounded,
      label: 'التقويم الجامعي',
      color: Color(0xFF3B82F6),
    ),
    QuickAction(
      icon: Icons.info_rounded,
      label: 'معلومات',
      color: Color(0xFFF59E0B),
    ),
  ];

  final List<CollegeCardData> _collegeCards = const [
    CollegeCardData(name: 'كلية الهندسة المعلوماتية', asset: 'assets/it.jpg'),
    CollegeCardData(name: 'كلية طب الأسنان', asset: 'assets/dentisy.jpg'),
    CollegeCardData(name: 'كلية الحقوق', asset: 'assets/low.jpg'),
  ];

  @override
  void initState() {
    super.initState();

    // 🎯 التأكد من تشغيل استماع الإشعارات
    _notificationController = Get.isRegistered<UserNotificationController>()
        ? Get.find<UserNotificationController>()
        : Get.put(UserNotificationController());

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heroController.forward();
      // 🎯 تحديث العداد لمرة واحدة عند فتح الشاشة الرئيسية للتأكد من القيمة
      _notificationController.fetchUnreadCountOnce();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _heroFade,
              child: SlideTransition(
                position: _heroSlide,
                child: HeroHeader(topPad: topPad),
              ),
            ),

            const SizedBox(height: 50),

            // الوصول السريع
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'الوصول السريع'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: _quickActions
                        .map((a) => SizedBox(
                              width: (MediaQuery.of(context).size.width - 54) / 2,
                              child: QuickActionCard(action: a),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // الكليات
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: 'الكليات'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(left: 20, right: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _collegeCards.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return CollegeCard(college: _collegeCards[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}