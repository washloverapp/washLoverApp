import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Notification/notification.dart';
import 'package:my_flutter_mapwash/Profile/profile.dart';
import 'package:my_flutter_mapwash/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  void _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notification_enabled') ?? false;
    setState(() {
      _notificationEnabled = enabled;
    });
    print(_notificationEnabled);
    setState(() {
      _notificationEnabled = enabled;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _notificationEnabled) return;
      if (!enabled) {
        _showNotificationSetting(context);
        return;
      }
      if (MainLayout.initialIndex == 4 && !enabled) {
        _notificationEnabled = true;
        _showNotificationSetting(context);
      }
    });
  }

  void _showNotificationSetting(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('notification_enabled') ?? false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        isEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        key: ValueKey(isEnabled),
                        size: 72,
                        color: isEnabled ? Colors.orange : Colors.grey,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'เปิดการแจ้งเตือน',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Switch(
                        value: isEnabled,
                        activeColor: Colors.orange,
                        onChanged: (value) async {
                          setStateDialog(() {
                            isEnabled = value;
                          });

                          setState(() {
                            _notificationEnabled = value;
                          });

                          await prefs.setBool('notification_enabled', value);

                          // 🔥 เปิด notification → ยิง FCM token
                          if (value) {
                            api_config.saveTokenFcmApi();
                          } else {
                            // optional: unsubscribe / delete token
                            // api_config.deleteTokenFcmApi();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
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
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Color(0xFF42A5F5),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                          padding: EdgeInsets.all(4),
                          elevation: 0,
                        ),
                        badgeContent: SizedBox.shrink(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _notificationEnabled
                                ? Color(0xFFfdc607)
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
                            constraints: BoxConstraints(),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(39, 180, 180, 180),
                blurRadius: 8,
                spreadRadius: 0,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(children: [Text('Main content goes here')]),
        ),
      ),
    );
  }
}
