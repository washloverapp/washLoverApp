import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:shared_preferences/shared_preferences.dart'; // สำหรับแปลง JSON เป็น Dart

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<dynamic> _historyData = [
    {
      'date': '2025-10-15',
      'time': '14:30',
      'status': 'completed',
      'price_net': 150.75,
      'phone': '0812345678',
    },
    {
      'date': '2025-10-14',
      'time': '09:45',
      'status': 'pending',
      'price_net': 200.00,
      'phone': '0898765432',
    },
    {
      'date': '2025-10-13',
      'time': '18:15',
      'status': 'cancelled',
      'price_net': 0.0,
      'phone': '0865432190',
    },
  ];

  bool _isLoading = true; // ตัวแปรเช็คสถานะการโหลดข้อมูล
  String username = "";

  @override
  void initState() {
    super.initState();
    // _fetchHistoryData(); // เรียกใช้ฟังก์ชันดึงข้อมูลจาก API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ประวัติ', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "HISTORY",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 203, 203, 203),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _historyData.length,
                itemBuilder: (context, index) {
                  var branch = _historyData[index];
                  String date = branch['date'] ?? "Unknown";
                  String time = branch['time'] ?? "Unknown";
                  String status = branch['status'] ?? "pending";
                  String price_net = (branch['price_net'] != null)
                      ? branch['price_net'].toString()
                      : '0';
                  String phone = branch['phone'] ?? "Unknown";
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 3.0, horizontal: 0.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.2),
                      child: Row(
                        children: [
                          // ใช้ Image.asset แทน
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Color.fromARGB(255, 235, 235, 235),
                                  width: 1.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(182, 255, 255, 255)
                                      .withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.access_time,
                                    size: 35,
                                    color: Color.fromARGB(255, 215, 215, 215),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 1.0),
                                Text(
                                  '$date $time',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(phone,
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 2.0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        'washing',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
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
                                '\฿${price_net}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4.0),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
