import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 💡 استيراد GetX لربط الحالات والاستماع للتغيرات
import 'package:team_app/Controller/UserController/user_notification_controller.dart';
import 'package:team_app/Model/User%20Model.dart';
import 'package:team_app/View/UserScreens/HomeScreens/home_screen.dart';
import 'package:team_app/View/UserScreens/mapScreen.dart';
import 'package:team_app/View/UserScreens/notificationsScreen.dart';
import 'package:team_app/View/UserScreens/profileScreen.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';

class ShellScreen extends StatefulWidget {
  final AppUser user; 

  const ShellScreen({super.key, required this.user});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // 🎯 جلب نسخة الـ UserNotificationController المحقونة مسبقاً لإدارة عداد الإشعارات عالمياً
  final UserNotificationController homeController = Get.find<UserNotificationController>();

  late final List<AnimationController> _iconControllers;
  late final List<Animation<double>> _iconScales;

  final List<_NavDestination> _destinations = const [
    _NavDestination(
      icon: Icons.home_rounded,
      outlineIcon: Icons.home_outlined,
      label: 'الرئيسية',
    ),
    _NavDestination(
      icon: Icons.map_rounded,
      outlineIcon: Icons.map_outlined,
      label: 'الخريطة',
    ),
    _NavDestination(
      icon: Icons.notifications_rounded,
      outlineIcon: Icons.notifications_outlined,
      label: 'الإشعارات',
      isNotification: true, 
    ),
    _NavDestination(
      icon: Icons.person_rounded,
      outlineIcon: Icons.person_outline_rounded,
      label: 'حسابي',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _iconControllers = List.generate(
      _destinations.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );

    _iconScales = _iconControllers
        .map(
          (c) => TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween(begin: 1.0, end: 1.25)
                  .chain(CurveTween(curve: Curves.easeOut)),
              weight: 50,
            ),
            TweenSequenceItem(
              tween: Tween(begin: 1.25, end: 1.0)
                  .chain(CurveTween(curve: Curves.elasticOut)),
              weight: 50,
            ),
          ]).animate(c),
        )
        .toList();

    _iconControllers[0].forward();
    
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });

    // if (index == 2) {
    //   homeController.clearUnreadNotifications(); 
    // }

    _iconControllers[index].forward(from: 0);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey(0));
      case 1:
        return const MapScreenReal(key: ValueKey(1));
      case 2:
        return const NotificationsScreen(key: ValueKey(2));
      case 3:
        return ProfileScreen(key: const ValueKey(3), user: widget.user);
      default:
        return const HomeScreen(key: ValueKey(0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _buildScreen(_currentIndex),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Obx(() => _PremiumNavBar(
                currentIndex: _currentIndex,
                destinations: _destinations,
                iconScales: _iconScales,
                unreadCount: homeController.unreadNotificationsCount.value,
                onTabSelected: _onTabSelected,
              )),
        ),
      ),
    );
  }
}

// ─── Premium Nav Bar ─────────────────────────────────────────────

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavDestination> destinations;
  final List<Animation<double>> iconScales;
  final int unreadCount;
  final ValueChanged<int> onTabSelected;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.destinations,
    required this.iconScales,
    required this.unreadCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.3,
        ),
        boxShadow: AppColors.navShadow,
      ),
      child: Row(
        children: List.generate(destinations.length, (i) {
          final isActive = i == currentIndex;
          return Expanded(
            child: _NavItem(
              destination: destinations[i],
              isActive: isActive,
              scaleAnim: iconScales[i],
              unreadCount: unreadCount, 
              onTap: () => onTabSelected(i),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavDestination destination;
  final bool isActive;
  final Animation<double> scaleAnim;
  final int unreadCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.scaleAnim,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    print("unreadCount: $unreadCount");
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: Badge(
              // 🎯 تعديل ذكي: إذا كان هناك إشعارات يظهر العداد الرقمي داخل النقطة
              label: unreadCount > 0 
                  ? Text(
                      '$unreadCount', 
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    )
                  : null,
              // 🎯 تظهر النقطة الحمراء فقط في تبويب الإشعارات وعند وجود إشعارات غير مقروءة فعلياً
              isLabelVisible: destination.isNotification && unreadCount > 0, 
              backgroundColor: AppColors.error, 
              child: Icon(
                isActive ? destination.icon : destination.outlineIcon,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            destination.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  final bool isNotification; 

  const _NavDestination({
    required this.icon,
    required this.outlineIcon,
    required this.label,
    this.isNotification = false,
  });
}