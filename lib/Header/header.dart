import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:my_flutter_mapwash/Profile/profile.dart';
import 'package:my_flutter_mapwash/api_config.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _notificationEnabled = false;
  bool _notificationPermissionGranted = false;
  bool _incognito = false;

  @override
  void initState() {
    super.initState();
    _loadIncognito();
    _requestNotification();
  }

  /// โหลดสถานะ Incognito
  Future<void> _loadIncognito() async {
    final prefs = await SharedPreferences.getInstance();
    final incognitoValue = prefs.getString('incognito') ?? '';

    if (!mounted) return;
    setState(() {
      _incognito = incognitoValue.isNotEmpty;
    });
  }

  void _openAppSettings() {
    AppSettings.openAppSettings();
  }

  /// ขอสิทธิ์แจ้งเตือน (ปิดอัตโนมัติถ้า incognito)
  Future<void> _requestNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final incognitoValue = prefs.getString('incognito') ?? '';

    if (incognitoValue.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _notificationEnabled = false;
        _notificationPermissionGranted = false;
      });
      return;
    }

    // final bool fcmSent = prefs.getBool('fcm_token_sent') ?? false;

    if (!mounted) return;
    setState(() {
      _notificationPermissionGranted = true;
      _notificationEnabled = true;
    });

    // if (!fcmSent) {
    await api_config.saveTokenFcmApi();
    await prefs.setBool('fcm_token_sent', true);
    // }
  }

  void _showNotificationSetting(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _notificationEnabled ? Colors.orange.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _notificationEnabled ? Icons.notifications_active : Icons.notifications_off,
                  size: 72,
                  color: _notificationEnabled ? Colors.orange : Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'เปิด-ปิดแจ้งเตือนสถานะการส่งซัก',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E435A),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'เปิดหรือปิดการแจ้งเตือนเพื่อรับข้อมูลสถานะการส่งซักของคุณผ่านแอปพลิเคชัน',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _openAppSettings,
                child: const Text(
                  'ไปที่การตั้งค่า',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _incognito ? Colors.black : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: _incognito ? Colors.black : const Color(0xFF42A5F5),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo/Washloverwhite.png',
                    height: 60,
                  ),
                  Text(
                    _incognito ? 'โหมดไม่ระบุตัวตน' : '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      badges.Badge(
                        badgeContent: const SizedBox.shrink(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _notificationEnabled ? const Color(0xFFfdc607) : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _notificationEnabled ? Icons.notifications_active : Icons.notifications_off,
                              color: Colors.white,
                              size: 23,
                            ),
                            onPressed: () {
                              _showNotificationSetting(context);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => profile()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: Colors.grey[400],
                          child: Image.asset(
                            'assets/images/collectionduck/Artboard25copy9.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Text('Main content goes here'),
        ),
      ),
    );
  }
}
