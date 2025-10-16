import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class History extends StatefulWidget {
  final String userId;

  History({required this.userId});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData(); // ดึง API เมื่อเปิดหน้า
  }

  Future<void> _fetchHistoryData() async {
    try {
      final String url = 'https://yourapi.com/history?userId=${widget.userId}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonBody = json.decode(response.body);
        // สมมุติ API ส่ง {"data": [...]} หรือส่งเป็น list
        List<dynamic> data = [];
        if (jsonBody is Map && jsonBody["data"] != null) {
          data = jsonBody["data"];
        } else if (jsonBody is List) {
          data = jsonBody;
        }
        setState(() {
          _historyData = data;
          _isLoading = false;
        });
      } else {
        // error (status code != 200)
        setState(() {
          _isLoading = false;
        });
        // แสดง error message
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetch history: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "สำเร็จ":
        return Colors.green;
      case 'กำลังดำเนินการ':
        return Colors.orange;
      case "ไม่สำเร็จ":
        return Colors.red;
      case 'washing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ประวัติ',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _historyData.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีประวัติคำสั่งซื้อ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SafeArea(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: _historyData.length,
                    itemBuilder: (context, index) {
                      var item = _historyData[index];
                      String date = item['date'] ?? "Unknown";
                      String time = item['time'] ?? "Unknown";
                      String status = item['status'] ?? "pending";
                      String priceNet = item['price_net']?.toString() ?? '0';
                      String phone = item['phone'] ?? "Unknown";

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 0.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.2),
                          child: Row(
                            children: [
                              // Icon / รูปภาพ
                              Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Color.fromARGB(255, 235, 235, 235),
                                      width: 1.0),
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Icon(
                                        Icons.access_time,
                                        size: 35,
                                        color:
                                            Color.fromARGB(255, 215, 215, 215),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$date $time',
                                        style: TextStyle(color: Colors.grey)),
                                    Text(phone,
                                        style: TextStyle(color: Colors.grey)),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          child: Text(
                                            'washing',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '฿$priceNet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
