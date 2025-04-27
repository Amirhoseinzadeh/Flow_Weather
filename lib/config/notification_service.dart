import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamsi_date/shamsi_date.dart'; // برای تاریخ شمسی
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      if (await Permission.notification.isDenied) {
        print('درخواست اجازه نوتیفیکیشن');
        final status = await Permission.notification.request();
        print('وضعیت اجازه نوتیفیکیشن: $status');
      } else {
        print('اجازه نوتیفیکیشن قبلاً داده شده: ${await Permission.notification.status}');
      }

      // گرفتن روز فعلی برای تنظیم آیکون اولیه
      final jalaliDate = Jalali.now();
      final day = jalaliDate.day;
      final iconName = 'day_$day'; // مثلاً day_7

      final AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings(iconName);

      const DarwinInitializationSettings darwinInitializationSettings =
      DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: true,
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {},
      );
    } catch (e) {
      print('خطا توی مقداردهی اولیه نوتیفیکیشن: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title, // اضافه کردن پارامتر title
    required String body,
    String? payload,
  }) async {
    // گرفتن تاریخ شمسی کنونی
    final jalaliDate = Jalali.now();
    final day = jalaliDate.day; // مثلاً 7
    final iconName = 'day_$day'; // مثلاً day_7

    // لاگ برای دیباگ
    print('نمایش نوتیفیکیشن با عنوان: $title و متن: $body');

    // تنظیمات نوتیفیکیشن برای اندروید
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      channelDescription: 'نوتیفیکیشن‌های آب‌وهوا',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      icon: iconName, // آیکون پویا بر اساس روز
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title, // استفاده از پارامتر title
      body,
      platformDetails,
      payload: payload,
    );

    print('نوتیفیکیشن با موفقیت فراخوانی شد');
  }
}