import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Home/account.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  // ฟังก์ชันลบข้อมูลทั้งหมดใน SharedPreferences
  Future<void> _clearSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ลบข้อมูลทั้งหมดใน SharedPreferences
    await prefs.clear();
    // นำผู้ใช้กลับไปยังหน้า login
    Navigator.pushReplacementNamed(context, '/login_page');
  }

  // ฟังก์ชันดึงข้อมูลจาก SharedPreferences
  Future<String?> _getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone'); // ดึงเบอร์โทรศัพท์จาก SharedPreferences
  }

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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                  // ใช้ FutureBuilder เพื่อดึงหมายเลขโทรศัพท์
                  FutureBuilder<String?>(
                    future: _getPhoneNumber(), // ฟังก์ชันดึงหมายเลขโทรศัพท์
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // แสดง loading indicator
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        String phone =
                            snapshot.data ?? 'Unknown'; // ถ้าได้ข้อมูลแล้ว
                            if(phone.length > 3){
                              phone = '${phone.substring(0, 3)}xxxxxxx';
                            }
                        return ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (route) => false,
                            );
                          },
                          label: Text(
                            phone, // ใช้เบอร์โทรศัพท์ที่ดึงมา
                            style: TextStyle(
                              color: Color(0xFFfdc607),
                            ),
                          ),
                          icon: Icon(
                            Icons.account_circle,
                            color: Color(0xFFfdc607),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Color(0xFFfdc607),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // return Text('No phone number available');
                        return ElevatedButton.icon(
                          onPressed: () {
                            logout(context);
                          },
                          label: Text(
                            'กรุณาเข้าสู่ระบบ', // ใช้เบอร์โทรศัพท์ที่ดึงมา
                            style: TextStyle(
                              color: Color(0xFFfdc607),
                            ),
                          ),
                          icon: Icon(
                            Icons.account_circle,
                            color: Color(0xFFfdc607),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Color(0xFFfdc607),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }
                    },
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
          child: Column(
            children: [Text('Main content goes here')],
          ),
        ),
      ),
    );
  }

   void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully logged out')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
