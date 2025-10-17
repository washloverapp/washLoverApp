import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Help/help.dart';
import 'package:my_flutter_mapwash/Home/history.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_mapwash/Home/API/api_account.dart';

class point extends StatefulWidget {
  const point({super.key});

  @override
  _pointState createState() => _pointState();
}

class _pointState extends State<point> {
  // Variables to hold API data
  String username = "Loading...";
  String userPhone = "Loading...";
  String credit = "Loading...";
  String point = "Loading...";
  String userImageUrl = "https://via.placeholder.com/150";
  String password = "Loading...";
  String address = "ที่อยู่สำหรับการจัดส่ง";
  String phoneT = "Loading...";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    var userData = await API_account.fetchapiaccount();
    if (userData != null) {
      setState(() {
        username = userData['name'] ?? 'ไม่ทราบชื่อ';
        userPhone = userData['phone'] ?? 'ไม่ทราบเบอร์';
        credit = userData['credit'].toString();
        point = userData['point'].toString();
        userImageUrl = userData['image_url'] ?? userImageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainLayout()),
                        (route) => false, // Clear all previous routes
                      );
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    // Profile Image and Name Section
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange[300], // สีพื้นหลัง
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 16),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      userPhone,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 20),
                    // credit and point Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              credit,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'สะส้มแต้ม',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          Divider(),
                          _buildMenuItemHepl(
                            icon: Icons.dataset,
                            date: '10 ตุลาคม 68',
                            time: '11.00 น.',
                            point: '0',
                          ),
                           _buildMenuItemHepl(
                            icon: Icons.dataset,
                            date: '10 ตุลาคม 68',
                            time: '11.00 น.',
                            point: '0',
                          ),
                            _buildMenuItemHepl(
                            icon: Icons.dataset,
                            date: '10 ตุลาคม 68',
                            time: '11.00 น.',
                            point: '0',
                          ), _buildMenuItemHepl(
                            icon: Icons.dataset,
                            date: '10 ตุลาคม 68',
                            time: '11.00 น.',
                            point: '0',
                          ), _buildMenuItemHepl(
                            icon: Icons.dataset,
                            date: '10 ตุลาคม 68',
                            time: '11.00 น.',
                            point: '0',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemHepl(
      {required IconData icon,
      required String date,
      required String time,
      required String point}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        date,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        point,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}