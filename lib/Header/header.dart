import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Notification/notification.dart';
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

  @override
  void initState() {
    super.initState();
    _requestNotification();
  }

  void _openAppSettings() {
    AppSettings.openAppSettings();
  }

  Future<void> _requestNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool fcmSent = prefs.getBool('fcm_token_sent') ?? false;
    if (!mounted) return;
    setState(() {
      _notificationPermissionGranted = true;
      _notificationEnabled = true;
    });
    // ส่ง FCM token แค่ครั้งแรก
    if (!fcmSent) {
      await api_config.saveTokenFcmApi();
      await prefs.setBool('fcm_token_sent', true);
    }
  }

  void _showNotificationSetting(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _notificationEnabled
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _notificationEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    key: ValueKey(_notificationEnabled),
                    size: 72,
                    color: _notificationEnabled ? Colors.orange : Colors.grey,
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // const Text(
                  //   'เปิด-ปิดการแจ้งเตือน',
                  //   style: TextStyle(fontWeight: FontWeight.w500),
                  // ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // สีปุ่ม
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // เมื่อกด → เปิด Settings
                      _openAppSettings();
                    },
                    child: const Text(
                      'ไปที่การตั้งค่า',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: const Color(0xFF42A5F5),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo/Washloverwhite.png',
                      height: 60),
                  Row(
                    children: [
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(top: 3, end: 5),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red,
                          padding: const EdgeInsets.all(4),
                          elevation: 0,
                        ),
                        badgeContent: const SizedBox.shrink(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _notificationEnabled
                                ? const Color(0xFFfdc607)
                                : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _notificationEnabled
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: Colors.white,
                              size: 23,
                            ),
                            onPressed: () {
                              _showNotificationSetting(context);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => profile()),
                            );
                          },
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(39, 180, 180, 180),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: const Column(children: [Text('Main content goes here')]),
        ),
      ),
    );
  }
}
