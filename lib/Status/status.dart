import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/pages/map_screen.dart';

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  BalanceScreen createState() => BalanceScreen();
}

class BalanceScreen extends State<Status> {
  @override
  void initState() {
    super.initState();
    loadPhoneData();
  }

  String formatDate(String datetime) {
    try {
      print('Datetime received: $datetime'); // ตรวจสอบค่า datetime ที่ได้รับ
      DateTime parsedDate = DateTime.parse(datetime);
      return DateFormat('dd MMMM yyyy, E', 'th_TH').format(parsedDate);
    } catch (e) {
      print("Error formatting date: $e");
      return datetime; // ถ้าผิดพลาดคืนค่ากลับไปเป็น datetime เดิม
    }
  }

  String formatTime(String datetime) {
    try {
      print('Datetime received: $datetime'); // ตรวจสอบค่า datetime ที่ได้รับ
      DateTime parsedDate = DateTime.parse(datetime);
      return DateFormat('HH:mm', 'th_TH').format(parsedDate) + " น.";
    } catch (e) {
      print("Error formatting time: $e");
      return 'ออนไลน์';
    }
  }

  String? phone;
  Future<void> loadPhoneData() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? phonex = prefs.getString('phone');
    String? phonex = '0611211910';

    if (phonex != null) {
      setState(() {
        phone = phonex; // เก็บค่า phone เมื่อโหลดเสร็จ
      });
      fetchOrders(phonex);
    } else {
      print('Phone is not available.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrders(String phone) async {
    final response = await http.get(Uri.parse(
        'https://android-dcbef-default-rtdb.firebaseio.com/order/$phone.json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data == null || data.isEmpty) {
        return [];
      } else {
        return data.entries.map((entry) {
          return {
            'orderId': entry.key,
            'price': entry.value['price_sum'] ?? 'N/A',
            'idwork': entry.value['code'] ?? 'N/A',
            'datetime': entry.value["datetime"] ?? 'N/A',
            'username': entry.value['phone'] ?? 'N/A',
          };
        }).toList();
      }
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "รายการส่งซัก",
          style: TextStyle(
            color: const Color.fromARGB(255, 203, 203, 203),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: phone == null
            ? Center(child: CircularProgressIndicator())
            : // รอให้ phone ถูกโหลด
            FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchOrders(phone!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('ไม่มีข้อมูล'));
                  } else {
                    final orders = snapshot.data!;
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        String formattedDateTime =
                            formatDate(order['datetime']);
                        String formattedTime = formatTime(order['datetime']);
                        return _buildTransactionItem(
                          context,
                          icon: Icons.online_prediction_sharp,
                          color: Colors.green,
                          title: order['orderId'],
                          orderId: order['orderId'],
                          subtitle: formattedDateTime,
                          amount:
                              '฿${(double.tryParse(order['price'] as String) ?? 0.0) < 0 ? 0.0 : (double.tryParse(order['price'] as String) ?? 0.0).toStringAsFixed(2)}',
                          time: formattedTime,
                        );
                      },
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required String orderId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StatusOrder(orderId: orderId), // ส่งค่า amount (orderId)
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount, // แสดง branch
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[500],
                    fontSize: 16),
              ),
              Text(
                time, // แสดง note
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
