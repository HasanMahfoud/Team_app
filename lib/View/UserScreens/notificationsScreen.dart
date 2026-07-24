import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:team_app/Controller/UserController/user_notification_controller.dart';

import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = const ['الكل', 'غير مقروء'];

  late final UserNotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<UserNotificationController>()
        ? Get.find<UserNotificationController>()
        : Get.put(UserNotificationController());
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'الآن';
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return intl.DateFormat('yyyy/MM/dd hh:mm a', 'ar').format(dateTime);
    }
  }

  void _showNotificationDialog(_Notification notif) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(notif.icon, color: notif.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "تفاصيل الإشعار",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              Text(
                notif.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    notif.time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "إغلاق ومتابعة",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    ).then((_) {
      _controller.markAsReadLocally(notif.id);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data!.docs;
        final DateTime? userCreationTime =
            FirebaseAuth.instance.currentUser?.metadata.creationTime;

        // فلترة الإشعارات: استبعاد المحذوفة محلياً + الإشعارات التي أُرسلت قبل إنشاء الحساب
        final activeDocs = allDocs.where((doc) {
          if (_controller.isDeletedLocally(doc.id)) return false;

          final data = doc.data() as Map<String, dynamic>;
          final Timestamp? createdAtTimestamp = data["createdAt"] as Timestamp?;

          if (userCreationTime != null && createdAtTimestamp != null) {
            final DateTime notifTime = createdAtTimestamp.toDate();
            if (notifTime.isBefore(userCreationTime)) {
              return false; // استبعاد الإشعار لأنه أُرسل قبل إنشاء الحساب
            }
          }

          return true;
        }).toList();

        final List<_Notification> parsedNotifications = activeDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id;
          bool isRead = (data["isread"] ?? false) || _controller.isReadLocally(id);

          return _Notification(
            id: id,
            title: data["title"] ?? "",
            body: data["body"] ?? "",
            time: _formatTimestamp(data["createdAt"] as Timestamp?),
            isRead: isRead,
            icon: Icons.campaign_rounded,
            color: const Color(0xFF3B82F6),
          );
        }).toList();

        final filteredNotifications = _selectedFilter == 1
            ? parsedNotifications.where((n) => !n.isRead).toList()
            : parsedNotifications;

        int unreadCount = parsedNotifications.where((n) => !n.isRead).length;

        return Column(
          children: [
            _NotifHeader(
              topPad: topPad,
              unreadCount: unreadCount,
              onMarkAll: () {
                _controller.clearUnreadNotifications(
                    parsedNotifications.map((e) => e.id).toList());
                setState(() {});
              },
            ),
            _FilterRow(
              filters: _filters,
              selected: _selectedFilter,
              onSelected: (i) => setState(() => _selectedFilter = i),
            ),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Text(
                        _selectedFilter == 1
                            ? 'لا توجد إشعارات غير مقروءة'
                            : 'سجل الإشعارات فارغ',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: ListView.builder(
                        key: ValueKey(_selectedFilter),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (ctx, i) {
                          final item = filteredNotifications[i];
                          return _NotificationCard(
                            notif: item,
                            delay: Duration(milliseconds: 40 * i),
                            onDismiss: () {
                              _controller.deleteNotificationLocally(item.id);
                              setState(() {});
                            },
                            onTap: () {
                              _showNotificationDialog(item);
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _Notification {
  final String id;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final IconData icon;
  final Color color;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}

class _NotifHeader extends StatelessWidget {
  final double topPad;
  final int unreadCount;
  final VoidCallback onMarkAll;

  const _NotifHeader({
    required this.topPad,
    required this.unreadCount,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount إشعار جديد',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (unreadCount > 0)
            GestureDetector(
              onTap: onMarkAll,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGlow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: const Text(
                  'قراءة الكل',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelected;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? AppColors.buttonShadow : [],
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final _Notification notif;
  final Duration delay;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notif,
    required this.delay,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: Key(widget.notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_rounded,
                color: Colors.white, size: 24),
          ),
          onDismissed: (_) => widget.onDismiss(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: widget.notif.isRead
                    ? Colors.white
                    : widget.notif.color.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.notif.isRead
                      ? Colors.transparent
                      : widget.notif.color.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.notif.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.notif.icon,
                          color: widget.notif.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.notif.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: widget.notif.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (!widget.notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: widget.notif.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.notif.body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 11, color: AppColors.textTertiary),
                              const SizedBox(width: 3),
                              Text(
                                widget.notif.time,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}