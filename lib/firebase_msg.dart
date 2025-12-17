import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Status/status.dart';
import 'app_navigator.dart';

class FirebaseMsg {
  /// Create a [AndroidNotificationChannel] for heads up notifications
  static late AndroidNotificationChannel channel;

  static bool isFlutterLocalNotificationsInitialized = false;

  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  static void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      var initializationSettings = new InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) async {
          handleFCMNavigation(message);
        },
      );
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
}

void handleFCMNavigation(RemoteMessage message) {
  print('handleFCMNavigation---s');
  final Map<String, dynamic> payload = message.data;
  print(payload);
  // final String? path = payload['screen'];

  // if (path == null) {
  //   print('❌ Data Payload ไม่มี Path/route สำหรับ GoRouter');
  //   return;
  // }

  // แปลง data payload ทั้งหมดให้เป็น Query Parameters

  
  // Ex: /productDetail?id=P1001&category=watches
  // final Uri uri = Uri(
  //   path: path,
  //   queryParameters: {
  //     for (final entry in payload.entries)
  //       if (entry.key != 'path') entry.key: entry.value.toString(),
  //   },
  // );
  
  final navigator = navigatorKey.currentState;
  if (navigator == null) {
    debugPrint('❌ navigator ยังไม่พร้อม');
    return;
  }

  MainLayout.initialIndex = 4; // ← แก้บั๊กจากโค้ดเดิม

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const MainLayout()),
    (_) => false,
  );

  // final String targetPath = uri.toString();
  // print('✅ GoRouter Redirecting to: $targetPath');

  // สั่งนำทางโดยใช้ Global Key
  // _rootNavigatorKey.currentContext?.go(targetPath);
}


