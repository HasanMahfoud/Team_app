import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:team_app/Controller/UserController/user_notification_controller.dart';
import 'package:team_app/View/appLancher.dart';
import 'package:team_app/core/theme/app_theme.dart';
import 'package:team_app/firebase_options.dart';

//  متغير عالمي لتخزين عملية تهيئة الفايربيز ومشاركتها مع شاشة الـ Launcher لضمان عدم حدوث السباق (Race Condition)
late final Future<void> firebaseInitialization;

Future<void> main() async {
  // تضمن تهيئة إعدادات فلاتر قبل تشغيل أي كود منصة
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  
  // 🔥 تهيئة بيانات تنسيق التاريخ لجميع اللغات لحل مشكلة الـ LocaleDataException
  await initializeDateFormatting(); 

  // ضبط شريط الحالة والاتجاهات فوراً لكي تظهر الواجهات بأسرع وقت
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 💡 بدء تهيئة Firebase والإشعارات في الخلفية وحفظ العملية في المتغير العالمي
  firebaseInitialization = _initializeFirebaseAndNotifications();

  // 🚀 تشغيل التطبيق والواجهات فوراً دون انتظار الخدمات لتجنب تعليق الـ Shell والشاشة البيضاء
  runApp(const UniversityGuideApp());
}

/// دالة خلفية لتهيئة خدمات Firebase دون حجب الـ UI الرئيسي
Future<void> _initializeFirebaseAndNotifications() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🟢 تم تهيئة Firebase بنجاح في الخلفية');

    // استدعاء دالة طلب صلاحيات الإشعارات بعد نجاح تهيئة الفايربيز
    await _initNotifications();
  } catch (e) {
    debugPrint('⚠️ خطأ أثناء تهيئة Firebase في الخلفية: $e');
  }
}

Future<void> _initNotifications() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🟢 تم قبول صلاحية الإشعارات من قبل المستخدم');

      await messaging.subscribeToTopic("all_users");
      debugPrint('🚀 تم اشتراك الجهاز في الـ Topic (all_users) بنجاح!');

      // 🔥 القطعة الناقصة 1: الاستماع اللحظي والتطبيق مفتوح بالواجهة
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔥 وصل إشعار جديد في الواجهة الأمامية: ${message.notification?.title}');
        
    
        if (Get.isRegistered<UserNotificationController>()) {
          Get.find<UserNotificationController>().fetchUnreadCountOnce();
        }
        
      });

    } else {
      debugPrint('🔴 المستخدم رفض إعطاء صلاحية الإشعارات');
    }
  } catch (e) {
    debugPrint('⚠️ خطأ أثناء إعداد إشعارات الـ FCM: $e');
  }
}

class UniversityGuideApp extends StatelessWidget {
  const UniversityGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, themeMode, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'University Guide',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AppLauncher(),
        );
      },
    );
  }
}