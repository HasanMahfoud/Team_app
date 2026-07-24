import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Timestamp? createdAt;
  bool isRead;
  final IconData icon;
  final Color color;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.isRead = false,
    this.icon = Icons.campaign_rounded,
    this.color = const Color(0xFF3B82F6),
  });

  // تحويل بيانات Firestore إلى Model
  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    bool isReadLocally,
  ) {
    final data = doc.data() ?? {};
    return NotificationModel(
      id: doc.id,
      title: data["title"] ?? "",
      body: data["body"] ?? "",
      createdAt: data["createdAt"] as Timestamp?,
      isRead: isReadLocally,
    );
  }
}