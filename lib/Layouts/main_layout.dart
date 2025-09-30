import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Home/home.dart';
// import 'package:my_flutter_mapwash/pages/banc.dart';
import 'package:my_flutter_mapwash/Home/dddd.dart' hide HomeScreen;
import 'package:my_flutter_mapwash/Oders/sendwash.dart';
import 'package:my_flutter_mapwash/pages/locatio_banch_page.dart';
import 'package:my_flutter_mapwash/Banchs/location_banc.dart';
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
  int _selectedIndex = 0;
  String workStatus = '';
  String? phone;
  bool hasUnreadOrders = false;

  @override
  void initState() {
    super.initState();
    if (_selectedIndex == 2) {
      // loadPhoneData();
      // fetchOrders(phone ?? '');
    }
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

  // Future<void> loadPhoneData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? phonex = prefs.getString('phone');

  //   if (phonex != null) {
  //     setState(() {
  //       phone = phonex;
  //     });
  //   } else {
  //     print('Phone is not available.');
  //   }
  // }

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
      home(),
      Wallet(),
      home(),
      LaundrySelection(),
      // Status(),
      sendwash(),
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
        backgroundColor: Colors.blue, // A blue color like in the image
        shape: CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
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
              icon: Icon(Icons.house),
              label: 'หน้าหลัก',
            ),
            // 1: เติมเงิน (Top-up/Wallet)
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
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
              icon: Icon(Icons.send_and_archive_rounded),
              label: 'ส่งซัก',
            ),
            // 4: สถานะ (Status) - Has the notification badge logic
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.online_prediction_rounded), // Icon ของคำสั่งซื้อ
                  if (hasUnreadOrders) // ถ้ามีคำสั่งซื้อที่ยังไม่ได้อ่าน
                    Positioned(
                      right: -5, // Adjust position to look like a badge
                      top: -5,
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
      ),
    );
  }
}








// import 'dart:convert';
// import 'package:flutter/material.dart';
// // import 'package:my_flutter_mapwash/pages/banc.dart';
// import 'package:my_flutter_mapwash/Home/home.dart';
// import 'package:my_flutter_mapwash/pages/locatio_banch_page.dart';
// import 'package:my_flutter_mapwash/pages/location_banc.dart';
// import 'package:my_flutter_mapwash/pages/order_step.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:my_flutter_mapwash/pages/status.dart';
// import 'package:my_flutter_mapwash/Header/header.dart';
// import 'package:my_flutter_mapwash/Payment/wallet.dart';
// import 'package:http/http.dart' as http;

// class MainLayout extends StatefulWidget {
//   const MainLayout({super.key});

//   @override
//   _MainLayoutState createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   // สังเกต: Index ของ FAB คือ 2
//   // แต่ _pages มี 4 หน้า (0, 1, 2, 3)
//   // หากต้องการให้หน้าหลัก (HomeScreen) เป็นหน้าเริ่มต้น
//   // หน้าหลักคือ index 1 ของ _pages
//   int _selectedIndex = 1; // เปลี่ยนเป็น 1 เพื่อให้เริ่มต้นที่ HomeScreen
  
//   String workStatus = '';
//   String? phone;
//   bool hasUnreadOrders = false;
  
//   // Widget Placeholder (ตัวอย่างสมมติเพื่อให้โค้ดคอมไพล์ได้)
//   final Widget Wallet = const Center(child: Text('กระเป๋าเงิน (Wallet)'));
//   final Widget HomeScreen = const Center(child: Text('หน้าหลัก (Home)'));
//   final Widget LaundrySelection = const Center(child: Text('ส่งซัก (Laundry)'));
//   final Widget Status = const Center(child: Text('สถานะ (Status)'));
//   final Widget Header = const Placeholder(); 

//   @override
//   void initState() {
//     super.initState();
//     loadPhoneData();
//   }

//   // ปรับการจัดการ Index: Index 2 คือการกด FAB (สแกน) ซึ่งไม่ควรเปลี่ยน _selectedIndex
//   void _onItemTapped(int index) {
//     if (index == 2) {
//       // Index 2 ถูกสงวนไว้สำหรับการกด FAB
//       // คุณสามารถเพิ่ม Logic สำหรับการสแกน QR Code ที่นี่
//       print('Scan button tapped - Index: $index');
//       return; 
//     }

//     // ปรับ Index สำหรับ _pages:
//     // BottomNavigationBar Items: 0, 1, (2=FAB), 3, 4
//     // _pages: 0, 1, 2, 3
//     // index ที่กด 0 และ 1 ตรงกับ index 0 และ 1 ใน _pages
//     // index ที่กด 3 ตรงกับ index 2 ใน _pages
//     // index ที่กด 4 ตรงกับ index 3 ใน _pages
//     int newIndex = index;
//     if (index > 2) {
//       newIndex = index - 1;
//     }
    
//     // ตั้งค่า _selectedIndex ใหม่
//     if (_selectedIndex != newIndex) {
//       setState(() {
//         _selectedIndex = newIndex;
//       });
//     }
//   }

//   Future<void> loadPhoneData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? phonex = prefs.getString('phone');

//     if (phonex != null) {
//       setState(() {
//         phone = phonex;
//       });
//     } else {
//       print('Phone is not available.');
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> _pages = [
//       Wallet,
//       HomeScreen,
//       LaundrySelection,
//       Status,
//     ];

   
//     return Scaffold(
//       // *** 1. เพิ่ม extendBody: true เพื่อให้ body ทะลุลงไปใต้ BottomAppBar
//       extendBody: true,
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(80),
//         child: Header(),
//       ),
//       body: Container(
//         color: const Color.fromARGB(255, 8, 119, 210),
//         // ปรับ index ให้ถูกต้องตามการเรียงใน _pages
//         child: _pages[_selectedIndex > 1 ? _selectedIndex - 1 : _selectedIndex],
//       ),
      
//       floatingActionButton: FloatingActionButton(
//         // Index 2 คือ 'Scan' button (ในมุมมองของ BottomNavigationBar Item)
//         onPressed: () => _onItemTapped(2), 
//         backgroundColor: const Color.fromARGB(255, 8, 119, 210), 
//         shape: const CircleBorder(),
//         child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
//         elevation: 8.0,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
//       // *** 2. เปลี่ยนจาก Container และ BottomNavigationBar เป็น BottomAppBar ***
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.white,
//         // *** 3. กำหนด shape ให้มีรอยเว้า ***
//         shape: const CircularNotchedRectangle(),
//         // *** 4. กำหนด clipBehavior เพื่อสร้างขอบโค้งมนที่มุมซ้าย/ขวา ***
//         clipBehavior: Clip.antiAlias, 
//         // 5. กำหนดระยะห่างระหว่าง FAB กับรอยเว้า
//         notchMargin: 6.0, 
//         elevation: 10.0, // เพิ่มเงาเพื่อให้ดูนูนออกมา
        
//         // 6. ใส่ BottomNavigationBar เดิมไว้เป็น child ของ BottomAppBar
//         child: SizedBox(
//           height: kBottomNavigationBarHeight, // กำหนดความสูงมาตรฐาน
//           child: BottomNavigationBar(
//             // ปรับ currentIndex เพื่อให้สอดคล้องกับการแสดงผล 5 ตำแหน่ง
//             // ถ้า _selectedIndex คือ 0 หรือ 1 ก็ใช้ค่านั้น
//             // ถ้า _selectedIndex คือ 2 หรือ 3 (จาก _pages) จะต้องเพิ่ม 1 เพื่อข้ามตำแหน่ง FAB (2)
//             currentIndex: _selectedIndex <= 1 ? _selectedIndex : _selectedIndex + 1,
//             onTap: _onItemTapped,
//             selectedItemColor: const Color(0xFF7bb0d8),
//             unselectedItemColor: const Color(0xFFadacac),
//             backgroundColor: Colors.white,
//             // ต้องเป็น Colors.transparent ถ้าไม่ใช้ clipBehavior แต่ในโค้ดนี้ใช้ Colors.white
//             type: BottomNavigationBarType.fixed,
//             items: <BottomNavigationBarItem>[
//               // 0: เติมเงิน (Wallet)
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.wallet),
//                 label: 'เติมเงิน',
//               ),
//               // 1: หน้าหลัก (Home)
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.house),
//                 label: 'หน้าหลัก',
//               ),
//               // 2: สแกน (Scan) - Placeholder icon, the FAB เป็นตัวหลัก
//               BottomNavigationBarItem(
//                 // ใช้ Icon ที่โปร่งใส เพื่อให้ FAB ที่ Docked อยู่ข้างบนไม่ถูกบดบัง
//                 icon: const Icon(Icons.circle, color: Colors.transparent),
//                 label: 'สแกน',
//               ),
//               // 3: ส่งซัก (Send Laundry)
//               BottomNavigationBarItem(
//                 icon: const Icon(Icons.send_and_archive_rounded),
//                 label: 'ส่งซัก',
//               ),
//               // 4: สถานะ (Status) - Has the notification badge logic
//               BottomNavigationBarItem(
//                 icon: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.online_prediction_rounded), // Icon ของคำสั่งซื้อ
//                     if (hasUnreadOrders) // ถ้ามีคำสั่งซื้อที่ยังไม่ได้อ่าน
//                       Positioned(
//                         right: -5,
//                         top: -5,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           constraints: const BoxConstraints(
//                             minWidth: 16,
//                             minHeight: 16,
//                           ),
//                           child: const Icon(
//                             Icons.notifications,
//                             size: 12,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 label: 'สถานะ',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }