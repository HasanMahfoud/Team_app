import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserNotificationController extends GetxController {
  var unreadNotificationsCount = 0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _box = GetStorage();

  StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.idTokenChanges().listen((user) async {
      if (user != null) {
        _listenToUnreadNotifications(user.uid);
      } else {
        _cancelSubscription();
        unreadNotificationsCount.value = 0;
      }
    });
  }

  // Check local storage states
  bool isReadLocally(String id) => _box.read(id) ?? false;
  bool isDeletedLocally(String id) => _box.read('deleted_$id') ?? false;

  void _listenToUnreadNotifications(String uid) {
    _cancelSubscription();
    unreadNotificationsCount.value = 0;

    // الحصول على تاريخ إنشاء حساب المستخدم الحالي
    final DateTime? userCreationTime = _auth.currentUser?.metadata.creationTime;

    _notificationsSubscription = _firestore
        .collection('notifications')
        .snapshots()
        .listen((snapshot) {
      int unread = snapshot.docs.where((doc) {
        final data = doc.data();
        bool serverIsRead = data['isread'] ?? false;
        
        // التحقق من تاريخ الإشعار بالنسبة لتاريخ حساب المستخدم
        Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
        if (userCreationTime != null && createdAtTimestamp != null) {
          DateTime notifTime = createdAtTimestamp.toDate();
          if (notifTime.isBefore(userCreationTime)) {
            return false; // تجاهل الإشعارات المرسلة قبل إنشاء الحساب
          }
        }

        return !serverIsRead && !isDeletedLocally(doc.id) && !isReadLocally(doc.id);
      }).length;

      unreadNotificationsCount.value = unread;
    }, onError: (error) {
      debugPrint("⚠️ Error listening to notifications: $error");
    });
  }

  // Mark single notification as read
  void markAsReadLocally(String notificationId) {
    try {
      _box.write(notificationId, true);
      fetchUnreadCountOnce();
    } catch (e) {
      debugPrint("⚠️ Error marking notification as read: $e");
    }
  }

  // Mark all non-deleted notifications as read
  Future<void> clearUnreadNotifications(List<String> notificationIds) async {
    try {
      for (var id in notificationIds) {
        if (!isDeletedLocally(id)) {
          _box.write(id, true);
        }
      }
      unreadNotificationsCount.value = 0;
    } catch (e) {
      debugPrint("⚠️ Error clearing unread notifications: $e");
    }
  }

  // Delete notification per-user locally
  void deleteNotificationLocally(String notificationId) {
    try {
      _box.write('deleted_$notificationId', true);
      fetchUnreadCountOnce();
    } catch (e) {
      debugPrint("⚠️ Error deleting notification locally: $e");
    }
  }

void fetchUnreadCountOnce() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final DateTime? userCreationTime = user.metadata.creationTime;

    try {
      final snapshot = await _firestore.collection('notifications').get();
      int unread = snapshot.docs.where((doc) {
        final data = doc.data();
        bool serverIsRead = data['isread'] ?? false;

        Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;
        if (userCreationTime != null && createdAtTimestamp != null) {
          DateTime notifTime = createdAtTimestamp.toDate();
          if (notifTime.isBefore(userCreationTime)) {
            return false;
          }
        }

        return !serverIsRead && !isDeletedLocally(doc.id) && !isReadLocally(doc.id);
      }).length;

      unreadNotificationsCount.value = unread;
    } catch (e) {
      debugPrint("⚠️ Error fetching unread count: $e");
    }
  }

  void _cancelSubscription() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  @override
  void onClose() {
    _cancelSubscription();
    _authSubscription?.cancel();
    super.onClose();
  }
}