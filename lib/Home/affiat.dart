import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShareFriendScreen extends StatefulWidget {
  @override
  _ShareFriendScreenState createState() => _ShareFriendScreenState();
}

class _ShareFriendScreenState extends State<ShareFriendScreen> {
  final String shareLink = "https://washlover.com/register";
  int _selectedTab = 0; // 0: แชร์เพื่อน, 1: สมาชิก

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: shareLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("คัดลอกลิงก์สำเร็จ!")),
    );
  }

  void share() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("แชร์ลิงก์สำเร็จ!")),
    );
  }

  void onTabSelected(int index) {
    setState(() {
      _selectedTab = index; // เปลี่ยนสถานะแท็บที่ถูกเลือก
    });
  }

  List<Map<String, dynamic>> data = []; // เปลี่ยนประเภทเป็น dynamic

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String phone = prefs.getString('phone') ??
          'defaultPhone'; // ค่า defaultPhone เป็นค่า fallback
      if (phone == 'defaultPhone') {
        print('ไม่พบหมายเลขโทรศัพท์ใน SharedPreferences');
        return;
      }
      final String apiUrl = 'https://washlover.com/api/affiliate?phone=$phone';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> jsonData = jsonResponse['data'];
          print(jsonData);
          setState(() {
            data = jsonData.map((item) {
              return {
                'name': '${item['firstname']} ${item['lastname']}',
                'date': item['date'] ?? '',
                // 'point': item['point']?.toString() ?? '0',
              };
            }).toList();
          });
        } else {
          throw Exception('Failed to load data');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerOrder(
        title: 'แนะนำเพื่อน',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Tabs
            Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.orange, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildTabItem(Icons.share, "แชร์เพื่อน", _selectedTab == 0, 0),
                  buildTabItem(Icons.person, "สมาชิก", _selectedTab == 1, 1),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_selectedTab == 0) ...[
              // Content for "แชร์เพื่อน" Tab
              SizedBox(height: 20),
              buildShareContent(),
              SizedBox(height: 0),
              Text("แชร์ไปยัง . . .",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildSocialIcon("assets/images/fb.png"),
                  SizedBox(width: 15),
                  buildSocialIcon("assets/images/twitter.png"),
                  SizedBox(width: 15),
                  buildSocialIcon("assets/images/line-icon.png"),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "ทุกการเติมเงินของเพื่อน รับ Point ทันที แชร์ให้เพื่อนสมัคร เพื่อนสมัครแล้วฝากแรก รับ Point ทันที",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ] else if (_selectedTab == 1) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "ทุกการเติมเงินของเพื่อน รับ Point ทันที แชร์ให้เพื่อนสมัคร เพื่อนสมัครแล้วฝากแรก รับ Point ทันที",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "สมาชิกเพื่อนที่แนะนำ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 0),
              Expanded(
                child: data.isEmpty
                    ? Center(
                        child:
                            CircularProgressIndicator()) // แสดง loading เมื่อยังไม่ได้ข้อมูล
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index]['name']!),
                            subtitle: Text(data[index]['date']!),
                            leading:
                                Icon(Icons.person, color: Colors.grey[400]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.monetization_on,
                                    color: Colors.amber[400]),
                                SizedBox(width: 5),
                                Text(
                                  '0',
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            // trailing: Row(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: [
                            //     Icon(Icons.monetization_on,
                            //         color: Colors.amber),
                            //     SizedBox(width: 5),
                            //     Text(data[index]['point']!,
                            //         style: TextStyle(
                            //             color: Colors.amber,
                            //             fontWeight: FontWeight.bold,
                            //             fontSize: 16)),
                            //   ],
                            // ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildTabItem(IconData icon, String text, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => onTabSelected(index), // เมื่อกดแท็บจะเปลี่ยนสถานะ
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.orange : Colors.black54),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialIcon(String assetPath) {
    return GestureDetector(
      onTap: () => print("แชร์ไปยัง $assetPath"),
      child: Image.asset(assetPath, width: 40),
    );
  }

  // Content for "แชร์เพื่อน" Tab
  Widget buildShareContent() {
    return Column(
      children: [
        // Share Link Box
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: shareLink,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: copyToClipboard,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text("คัดลอก", style: TextStyle(color: Colors.black)),
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
