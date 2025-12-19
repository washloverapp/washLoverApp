import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/firebase_msg.dart';
import 'package:my_flutter_mapwash/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:my_flutter_mapwash/api_config.dart';
import 'package:my_flutter_mapwash/app_navigator.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMsg.setupFlutterNotifications();
  FirebaseMsg.showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
  print('Handling a background message ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _startScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    var token = await FirebaseMessaging.instance.getToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token ?? '');
    print('token');
    print(token);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🟡 คลิก Notification: นำทางจาก Background ด้วย GoRouter -- MyApp');
      handleFCMNavigation(message);
    });
    await api_config.loadEndpoint();
    _checkLogin(token); // ฟังก์ชันเช็ค login ของคุณ
  }

  Future<void> _checkLogin(tokenfcm) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    final endpoint = prefs.getString('endpoint');

    double currentLat = 13.7563;
    double currentLng = 100.5018;

    await prefs.setDouble('lat', currentLat);
    await prefs.setDouble('lng', currentLng);

    // if (token != null && phone != null && password != null) {
    try {
      final url = Uri.parse('$endpoint/api/auth/token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        await prefs.setString('token', token);
        await api_config.saveTokenFcmApi(tokenfcm, phone);
        setState(() {
          _startScreen = const MainLayout();
        });
        return;
      } else {
        await prefs.clear();
      }
    } catch (e) {
      debugPrint('Login check error: $e');
    }
    // }

    setState(() {
      _startScreen = LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Kanit'),
      navigatorKey: navigatorKey,
      home: _startScreen,
    );
  }
}
