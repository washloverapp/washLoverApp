import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:my_flutter_mapwash/pages/banc.dart';
import 'package:my_flutter_mapwash/Home/home.dart';
import 'package:my_flutter_mapwash/pages/locatio_banch_page.dart';
import 'package:my_flutter_mapwash/pages/location_banc.dart';
import 'package:my_flutter_mapwash/pages/order_step.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/pages/status.dart';
import 'package:my_flutter_mapwash/Header/header.dart';
import 'package:my_flutter_mapwash/Payment/wallet.dart';
import 'package:http/http.dart' as http;

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 2;
  String workStatus = '';
  String? phone;
  bool hasUnreadOrders = false;

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 2) {
      loadPhoneData();
      // fetchOrders(phone ?? '');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        loadPhoneData();
        // fetchOrders(phone ?? '');
      }
    });
  }

  Future<void> loadPhoneData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phonex = prefs.getString('phone');

    if (phonex != null) {
      setState(() {
        phone = phonex;
      });
    } else {
      print('Phone is not available.');
    }
  }

  // Future<void> fetchOrders(String phone) async {
  //   final response = await http.get(Uri.parse(
  //       'https://android-dcbef-default-rtdb.firebaseio.com/order/$phone.json'));

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic>? data = jsonDecode(response.body);

  //     if (data == null || data.isEmpty) {
  //       setState(() {
  //         // hasUnreadOrders = false;
  //       });
  //     } else {
  //       bool hasUnread = data.entries.any((entry) {
  //         return entry.value['status'] == 'unread';
  //       });
  //       setState(() {
  //         // hasUnreadOrders = true;
  //       });
  //     }
  //   } else {
  //     throw Exception('Failed to load orders');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      LocationBanc(),
      // BranchDetailPage2(),
      Wallet(),
      HomeScreen(),
      LaundrySelection(),
      Status(),
    ];

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: Header(),
        ),
        body: Container(
          color: Color.fromARGB(255, 8, 119, 210),
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // สีของเงา
                offset: Offset(0, -2), // เงายื่นขึ้นด้านบน
                blurRadius: 4, // ความเบลอของเงา
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color(0xFF7bb0d8),
            unselectedItemColor: Color(0xFFadacac),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on),
                label: 'จุดบริการ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'เติมเงิน',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.house),
                label: 'หน้าแรก',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.send_and_archive_rounded),
                label: 'ส่งซัก',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.online_prediction_rounded), // Icon ของคำสั่งซื้อ
                    if (hasUnreadOrders) // ถ้ามีคำสั่งซื้อที่ยังไม่ได้อ่าน
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Icon(
                            Icons.notifications,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'สถานะ',
              ),
            ],
          ),
        ));
  }
}
