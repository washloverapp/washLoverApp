import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:my_flutter_mapwash/Notification/Alerts/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await setupFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Kanit',
      ),
      home: LoginPage(),
    );
  }
}
