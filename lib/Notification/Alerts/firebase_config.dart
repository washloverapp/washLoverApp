import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> setupFirebase() async {
  // เรียก Firebase.initializeApp() เพื่อเริ่มใช้งาน Firebase
  await Firebase.initializeApp();

  // ตั้งค่าการรับการแจ้งเตือนจาก Firebase Messaging
  await setupFirebaseMessaging();
}

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ขออนุญาตการแจ้งเตือน
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("User granted permission for notifications");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("User granted provisional permission for notifications");
  } else {
    print("User denied permission for notifications");
  }

  // รับการแจ้งเตือนเมื่อแอปกำลังทำงานอยู่
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in the foreground: ${message.notification?.title}');
  });

  // รับการแจ้งเตือนเมื่อแอปอยู่ใน background หรือ terminated
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

// ฟังก์ชันที่เรียกเมื่อแอปอยู่ใน background หรือ terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Messaging Example'),
        ),
        body: Center(
          child: Text('Welcome to Firebase Messaging!'),
        ),
      ),
    );
  }
}
