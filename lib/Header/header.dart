import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:my_flutter_mapwash/Notification/notification.dart';
import 'package:my_flutter_mapwash/Profile/profile.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // โลโก้
                  Image.asset('assets/images/logo/Washlovercolor.png',
                      height: 60),
                  Row(
                    children: [
                      // ปุ่มแจ้งเตือน
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(
                            top: 3, end: 5), // ปรับตำแหน่งจุดแดง
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red, // สีของจุด
                          padding: EdgeInsets.all(4), // ขนาดของจุดแดง
                          elevation: 0,
                        ),
                        badgeContent: SizedBox.shrink(), // ไม่มีตัวเลข
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xFFfdc607),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 23,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NotificationScreen()),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // ปุ่ม User
                      // ElevatedButton.icon(
                      //   onPressed: () {},
                      //   label: Text(
                      //     '098xxxx321',
                      //     style: TextStyle(color: Color(0xFFfdc607)),
                      //   ),
                      //   icon: Icon(Icons.account_circle,
                      //       color: Color(0xFFfdc607)),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 16,
                      //       vertical: 8,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       side:
                      //           BorderSide(color: Color(0xFFfdc607), width: 2),
                      //     ),
                      //   ),
                      // ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        clipBehavior: Clip.hardEdge, // ทำให้รูปโค้งตามวงกลม
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => profile()),
                            );
                          },
                          child: Image.asset(
                              'assets/images/collectionduck/Artboard25copy9.png', // 👈 เปลี่ยนเป็น path รูปของคุณ
                              fit: BoxFit.contain),
                        ),
                      )
                    ],
                  ),
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

