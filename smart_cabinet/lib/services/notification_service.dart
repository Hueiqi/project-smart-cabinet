import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:smart_cabinet/model/app_data.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: settings);

    // Request notification permission on Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'expiry_channel',
          'Expiry Alerts',
          channelDescription: 'Notifications for items nearing expiration',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> checkAndNotifyExpiringItems() async {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    final expiringItems = <BoxItem>[];

    for (var category in AppData.categories) {
      for (var item in category.items) {
        if (item.expirationDate != null &&
            item.expirationDate!.isAfter(now) &&
            item.expirationDate!.isBefore(threeDaysLater)) {
          expiringItems.add(item);
        }
      }
    }

    if (expiringItems.isEmpty) return;

    for (var item in expiringItems) {
      final daysLeft = item.expirationDate!.difference(now).inDays;
      await showNotification(
        id: item.id.hashCode,
        title: '⚠️ Item expiring soon',
        body:
            '${item.name} expires in $daysLeft day(s). Store in ${item.storageBox}.',
      );
    }
  }
}
