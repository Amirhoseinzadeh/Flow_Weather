// import 'dart:async';
// import 'package:flow_weather/features/weather_feature/domain/entities/meteo_murrent_weather_entity.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shamsi_date/shamsi_date.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:flow_weather/core/resources/data_state.dart';
// import 'package:flow_weather/features/weather_feature/domain/bookmark_use_cases/get_current_weather_usecase.dart';
// import 'package:flow_weather/locator.dart';
//
// class NotificationService {
//   static const String _notificationShownKey = 'notification_shown';
//
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   Timer? _updateTimer;
//   String? cityName;
//   double? lat;
//   double? lon;
//
//   Future<void> initialize() async {
//     try {
//       tz.initializeTimeZones();
//       if (await Permission.notification.isDenied) {
//         print('درخواست اجازه نوتیفیکیشن');
//         final status = await Permission.notification.request();
//         print('وضعیت اجازه نوتیفیکیشن: $status');
//       } else {
//         print('اجازه نوتیفیکیشن قبلاً داده شده: ${await Permission.notification.status}');
//       }
//
//       final jalaliDate = Jalali.now();
//       final day = jalaliDate.day;
//       final iconName = 'day_$day';
//
//       final AndroidInitializationSettings androidInitializationSettings =
//       AndroidInitializationSettings(iconName);
//
//       const DarwinInitializationSettings darwinInitializationSettings =
//       DarwinInitializationSettings(
//         requestSoundPermission: false,
//         requestBadgePermission: false,
//         requestAlertPermission: true,
//       );
//
//       final InitializationSettings initializationSettings =
//       InitializationSettings(
//         android: androidInitializationSettings,
//         iOS: darwinInitializationSettings,
//       );
//
//       await _flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: (NotificationResponse response) {},
//       );
//     } catch (e) {
//       print('خطا توی مقداردهی اولیه نوتیفیکیشن: $e');
//     }
//   }
//
//   Future<bool> _isNotificationAlreadyShown(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('$_notificationShownKey$id') ?? false;
//   }
//
//   Future<void> _setNotificationShown(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('$_notificationShownKey$id', true);
//   }
//
//   Future<void> resetNotificationStatus(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('$_notificationShownKey$id');
//     print('وضعیت نوتیفیکیشن برای id $id ریست شد.');
//   }
//
//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     if (await _isNotificationAlreadyShown(id)) {
//       print('نوتیفیکیشن با id $id قبلاً نمایش داده شده، از نمایش دوباره جلوگیری شد.');
//       return;
//     }
//
//     final jalaliDate = Jalali.now();
//     final day = jalaliDate.day;
//     final iconName = 'day_$day';
//     final formattedDate = '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';
//
//     print('ثبت نوتیفیکیشن با عنوان: $formattedDate و متن: $body');
//
//     final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'weather_channel',
//       'Weather Notifications',
//       channelDescription: 'نوتیفیکیشن‌های آب‌وهوا',
//       importance: Importance.low,
//       priority: Priority.low,
//       showWhen: false,
//       ongoing: true,
//       autoCancel: false,
//       icon: iconName,
//       playSound: false,
//       enableVibration: false,
//       setAsGroupSummary: true,
//       groupKey: 'weather_group',
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: false,
//       presentSound: false,
//     );
//
//     final NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       formattedDate, // فقط تاریخ شمسی توی عنوان
//       body,
//       platformDetails,
//       payload: payload,
//     );
//
//     await _setNotificationShown(id);
//     print('نوتیفیکیشن با موفقیت ثبت شد');
//   }
//
//   // انتخاب آیکون بر اساس وضعیت آب‌وهوا
//   String _getWeatherIcon(String? description) {
//     if (description == null) return 'weather_default';
//     switch (description.toLowerCase()) {
//       case 'آسمان صاف':
//       case 'صاف':
//         return 'sunny';
//       case 'ابری':
//       case 'آسمان ابری':
//         return 'cloudy';
//       case 'کمی ابری':
//         return 'partly_cloudy';
//       case 'بارانی':
//       case 'بارش باران':
//         return 'rainy';
//       case 'برفی':
//       case 'بارش برف':
//         return 'snowy';
//       default:
//         return 'weather_default';
//     }
//   }
//
//   // شروع به‌روزرسانی دوره‌ای
//   void startPeriodicUpdate(String city, double latitude, double longitude) {
//     cityName = city;
//     lat = latitude;
//     lon = longitude;
//
//     _updateTimer?.cancel();
//     _updateTimer = Timer.periodic(Duration(seconds: 3600), (timer) async {
//       print('به‌روزرسانی دوره‌ای نوتیفیکیشن...');
//       await _updateNotification(cityName, lat, lon);
//     });
//   }
//
//   // به‌روزرسانی نوتیفیکیشن
//   Future<void> _updateNotification(String? city, double? latitude, double? longitude) async {
//     if (city == null || latitude == null || longitude == null) {
//       print('اطلاعات شهر یا مختصات موجود نیست.');
//       return;
//     }
//
//     try {
//       final getCurrentWeatherUseCase = locator<GetCurrentWeatherUseCase>();
//       final weather = await getCurrentWeatherUseCase(city);
//       if (weather is DataSuccess<MeteoCurrentWeatherEntity>) {
//         final temp = weather.data!.main?.temp?.round() ?? 0;
//         final description = weather.data!.weather?.isNotEmpty == true
//             ? weather.data!.weather![0].description ?? 'نامشخص'
//             : 'نامشخص';
//
//         // گرفتن تاریخ شمسی
//         final jalaliDate = Jalali.now();
//         final formattedDate = '${jalaliDate.year}/${jalaliDate.month}/${jalaliDate.day}';
//
//         // انتخاب آیکون بر اساس وضعیت آب‌وهوا
//         final iconName = _getWeatherIcon(description);
//
//         final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//           'weather_channel',
//           'Weather Notifications',
//           channelDescription: 'نوتیفیکیشن‌های آب‌وهوا',
//           importance: Importance.low,
//           priority: Priority.low,
//           showWhen: false,
//           ongoing: true,
//           autoCancel: false,
//           icon: iconName,
//           playSound: false,
//           enableVibration: false,
//           setAsGroupSummary: true,
//           groupKey: 'weather_group',
//         );
//
//         const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//           presentAlert: false,
//           presentSound: false,
//         );
//
//         final NotificationDetails platformDetails = NotificationDetails(
//           android: androidDetails,
//           iOS: iosDetails,
//         );
//
//         // نمایش نوتیفیکیشن با فرمت جدید
//         await _flutterLocalNotificationsPlugin.show(
//           0,
//           formattedDate, // فقط تاریخ شمسی توی عنوان
//           'دمای $city: $temp° - $description', // دما و وضعیت آب‌وهوا توی متن
//           platformDetails,
//           payload: 'weather_update',
//         );
//         print('نوتیفیکیشن برای $city به‌روزرسانی شد.');
//       } else {
//         print('دریافت داده آب‌وهوا با خطا مواجه شد: ');
//         return;
//       }
//     } catch (e) {
//       print('خطا در به‌روزرسانی نوتیفیکیشن: $e');
//     }
//   }
//
//   // توقف به‌روزرسانی دوره‌ای
//   void stopPeriodicUpdate() {
//     _updateTimer?.cancel();
//     print('به‌روزرسانی دوره‌ای متوقف شد.');
//   }
// }