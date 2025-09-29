import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/NOaccount/NOaccount_home2.dart';
import 'package:my_flutter_mapwash/NOaccount/NOaccount_wallet.dart';
import 'package:my_flutter_mapwash/Home/dddd.dart';
import 'package:my_flutter_mapwash/Banchs/location_banc.dart';
import 'package:my_flutter_mapwash/pages/order_step.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/status.dart';
import '../Header/header.dart';
import 'package:my_flutter_mapwash/Payment/wallet.dart';
import 'package:http/http.dart' as http;

class NO_accountMainLayout extends StatefulWidget {
  const NO_accountMainLayout({super.key});

  @override
  _NO_accountMainLayoutState createState() => _NO_accountMainLayoutState();
}

class _NO_accountMainLayoutState extends State<NO_accountMainLayout> {
  int _selectedIndex = 2;
  String workStatus = '';
  String? phone;
  bool hasUnreadOrders = false;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        // loadPhoneData();
        // fetchOrders(phone ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      NO_account_Wallet(),
      NO_account_Wallet(),
      NO_account_HomeScreen(),
      NO_account_Wallet(),
      NO_account_Wallet(),
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
