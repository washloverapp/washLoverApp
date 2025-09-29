import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/pages/help.dart';
import 'package:my_flutter_mapwash/Home/history.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:my_flutter_mapwash/pages/address_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_mapwash/Home/API/api_account.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  _accountState createState() => _accountState();
}

class _accountState extends State<account> {
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
                              point,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'เครดิต',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
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
                    // Menu Options Section
                    Expanded(
                      child: ListView(
                        children: [
                          _buildMenuItemUser(
                            icon: Icons.people,
                            text: '$userPhone',
                          ),
                          _buildMenuItem(
                            icon: Icons.location_city,
                            text: '$address',
                          ),
                          _buildMenuItemHistory(
                            icon: Icons.history,
                            text: 'ประวัติ',
                          ),
                          Divider(),
                          _buildMenuItemHepl(
                            icon: Icons.help_outline,
                            text: 'ศูนย์ช่วยเหลือ',
                          ),
                          _buildMenuItemExit(
                            icon: Icons.exit_to_app_outlined,
                            text: 'ออกจากระบบ',
                            context: context, // Pass context here
                          ),
                          Divider(),
                          SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onPressed: () {
                              _confirmDeletePhone();
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => Amount()),
                              // );
                            },
                            child: Text(
                              'ลบบัญชี',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildMenuItem({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressListScreen()),
        );
      },
    );
  }

  Widget _buildMenuItemHistory({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => History()),
        );
      },
    );
  }

  Widget _buildMenuItemHepl({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Help()),
        );
      },
    );
  }

  Widget _buildMenuItemUser({required IconData icon, required String text}) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => AddressListScreen()),
        // );
      },
    );
  }

  // Function to handle the "Logout" action
  Widget _buildMenuItemExit({
    required IconData icon,
    required String text,
    required BuildContext context, // Pass context here
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully logged out')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }

  void _confirmDeletePhone() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            "ยืนยันการลบบัญชี",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "คุณต้องการลบบัญชีนี้หรือไม่?",
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              isDefaultAction: true,
              child: Text(
                "ยกเลิก",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePhone();
              },
              isDestructiveAction: true,
              child: Text("ลบ"),
            ),
          ],
        );
      },
    );
  }

  Future<String?> getPhoneFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  Future<void> _deletePhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = await getPhoneFromPreferences();
    if (phone == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ไม่พบหมายเลขโทรศัพท์")));
      return;
    }
    print('phone : $phone');
    if (phone != null) {
      final deleteUrl = Uri.parse(
          'https://washlover.com/api/member_delete?delete_member=1&phone=${phone}');
      final response = await http.delete(deleteUrl);

      print('response delete :  $response');
      if (response.statusCode == 200) {
        await prefs.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully logged out')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ไม่สามารถลบที่อยู่ได้")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ไม่พบที่อยู่ที่ต้องการลบ")));
    }
  }
}
