import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamsi_date/shamsi_date.dart'; // اضافه کردن کتابخونه تاریخ شمسی
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
  const AndroidInitializationSettings('notification_icon'); // آیکون باید وجود داشته باشه

  final DarwinInitializationSettings _darwinInitializationSettings =
  const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: true,
  );

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

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: _androidInitializationSettings,
        iOS: _darwinInitializationSettings,
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
    required String body,
    String? payload, required String title,
  }) async {
    // گرفتن تاریخ شمسی کنونی
    final jalaliDate = Jalali.now();
    final formattedDate = '${jalaliDate.day} / ${jalaliDate.month} / ${jalaliDate.year}';

    // تنظیم عنوان نوتیفیکیشن با تاریخ شمسی
    final notificationTitle = 'امروز: $formattedDate';

    print('نمایش نوتیفیکیشن با عنوان: $notificationTitle و متن: $body');

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'weather_channel',
      'Weather Notifications',
      channelDescription: 'نوتیفیکیشن‌های آب‌وهوا',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // نوتیفیکیشن همیشه نمایش داده می‌شه
      autoCancel: false, // کاربر نمی‌تونه حذفش کنه
      icon: 'notification_icon', // آیکون باید توی drawable باشه
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      notificationTitle, // تاریخ شمسی توی عنوان
      body,
      platformDetails,
      payload: payload,
    );

    print('نوتیفیکیشن با موفقیت فراخوانی شد');
  }
}