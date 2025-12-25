import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/NOaccount/NOaccount_home2.dart';
import 'package:my_flutter_mapwash/NOaccount/NOaccount_wallet.dart';
import 'package:my_flutter_mapwash/Banchs/location_banc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Status/status.dart';
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
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Header(),
      ),
      body: Container(
        color: const Color.fromARGB(255, 8, 119, 210),
        child: _pages[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2), // Index 2 is the 'Scan' button
        backgroundColor: Colors.blue, // พื้นหลังปุ่ม
        shape: CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2), // ขอบสีฟ้า
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/duck2.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        elevation: 8.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(39, 180, 180, 180),
              spreadRadius: 5,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Color(0xFFadacac),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            // 0: หน้าหลัก (Home)
            BottomNavigationBarItem(
              icon: Icon(Icons.house_outlined),
              label: 'หน้าหลัก',
            ),
            // 1: เติมเงิน (Top-up/Wallet)
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'เติมเงิน',
            ),
            // 2: สแกน (Scan) - Placeholder icon, the FAB is the main visual
            BottomNavigationBarItem(
              // Use a non-visible icon for the notched item
              icon: Icon(Icons.circle, color: Colors.transparent),
              label: 'สแกน',
            ),
            // 3: ส่งซัก (Send Laundry)
            BottomNavigationBarItem(
              icon: Icon(Icons.send_and_archive_outlined),
              label: 'ส่งซัก',
            ),
            // 4: สถานะ (Status) - Has the notification badge logic
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.online_prediction_rounded), // Icon ของคำสั่งซื้อ
                  if (!hasUnreadOrders) // ถ้ามีคำสั่งซื้อที่ยังไม่ได้อ่าน
                    Positioned(
                      right: -5, // Adjust position to look like a badge
                      top: -5,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }
}
