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
  static const Color lightBlue = Color(0xFFE8F1FF);
  static const Color primaryBlue = Color(0xFF1E62F9);

  List<dynamic> _historyData = [
    {
      'date': '2025-10-15',
      'time': '14:30',
      'status': 'completed',
      'price_net': 150.75,
      // 'phone': '0812345678',
    },
    {
      'date': '2025-10-14',
      'time': '09:45',
      'status': 'pending',
      'price_net': 200.00,
      // 'phone': '0898765432',
    },
    {
      'date': '2025-10-13',
      'time': '18:15',
      'status': 'cancelled',
      'price_net': 0.0,
      // 'phone': '0865432190',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: headerOrder(
        title: 'ประวัติการทำรายการ',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/news.png'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
          ),
          ////////////////////////////////////////// ประวัติรายการ //////////////////////////////////////////
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ประวัติรายการ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'ต.ค. 2568',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 50, right: 50, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'อัปเดตล่าสุดเมื่อ 21 ต.ค. 2568 เวลา 18:45',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                ////////////////////////////////////////// รายการ //////////////////////////////////////////
                Expanded(
                  child: _historyData.isEmpty
                      ? _buildEmptyHistory()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _historyData.length,
                          itemBuilder: (context, index) {
                            var item = _historyData[index];
                            String date = item['date'] ?? '-';
                            String time = item['time'] ?? '-';
                            String status = item['status'] ?? '-';
                            // String phone = item['phone'] ?? '-';
                            double price = item['price_net'] ?? 0.0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 46,
                                    width: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFDDEBFF),
                                          Color(0xFFF4F8FF)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.local_laundry_service_rounded,
                                      color: Color(0xFF1E62F9),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  ////////////////////////////////////////// รายการ //////////////////////////////////////////
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$date  $time',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        // Text(
                                        //   phone,
                                        //   style: const TextStyle(
                                        //     fontSize: 14.5,
                                        //     fontWeight: FontWeight.w500,
                                        //     color: Colors.black87,
                                        //   ),
                                        // ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status)
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getStatusText(status),
                                            style: TextStyle(
                                              color: _getStatusColor(status),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  ////////////////////////////////////////// ราคา //////////////////////////////////////////
                                  Text(
                                    '฿${price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryList() {
    return ListView.builder(
      itemCount: _historyData.length,
      itemBuilder: (context, index) {
        final item = _historyData[index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue, // แบล็คกราวน์สีน้ำเงิน
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${item['date']}',
                  style: TextStyle(color: Colors.white)),
              Text('Time: ${item['time']}',
                  style: TextStyle(color: Colors.white)),
              Text('Status: ${item['status']}',
                  style: TextStyle(color: Colors.white)),
              Text('Price Net: \$${item['price_net']}',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF21409A),
                    Color(0xFF21409A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/news.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 6),
                      Text(
                        'ยอดเงินคงเหลือ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '฿0.00',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ใช้รูป duck.png แทนไอคอนคูปอง
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/duck.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'คูปอง',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16),
                          ),
                          Text(
                            '0',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),

                      // ส่วนอื่นยังใช้ Icon ตามเดิม
                      _buildInfoItem(
                          Icons.star_outline_rounded, 'คะแนนสะสม', '0'),
                      _buildInfoItem(Icons.credit_card_outlined, 'เครดิต', '0'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(top: 10, left: 20, child: _bubble(50)),
            Positioned(top: 40, right: 50, child: _bubble(30)),
            Positioned(bottom: 30, left: 30, child: _bubble(45)),
            Positioned(bottom: 20, right: 20, child: _bubble(30)),
            Positioned(top: 80, left: 100, child: _bubble(35)),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size) {
    final icons = [
      Icons.favorite,
      Icons.star_rounded,
      Icons.circle,
    ];
    final icon = (icons..shuffle()).first;

    final colors = [
      const Color(0xFFFFFFFF),
      const Color.fromARGB(255, 198, 220, 247),
      const Color.fromARGB(255, 155, 201, 245),
      const Color.fromARGB(255, 115, 181, 247),
      const Color.fromARGB(255, 166, 212, 250),
    ];
    final color = (colors..shuffle()).first.withOpacity(0.12);
    final rotation = ([-0.2, 0.1, 0.3]..shuffle()).first;
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      ],
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String date = item['date'];
    String time = item['time'];
    String status = item['status'];
    // String phone = item['phone'];
    double price = item['price_net'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[50],
            ),
            child: const Icon(Icons.access_time,
                color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$date  $time',
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
                // Text(phone,
                //     style:
                //         const TextStyle(color: Colors.black87, fontSize: 14)),
                // const SizedBox(height: 4),
                Row(
                  children: [
                    _statusChip(status, _getStatusColor(status)),
                    const SizedBox(width: 6),
                    _statusChip("washing", Colors.blueAccent),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '฿${price.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildEmptyHistory() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 100,
              height: 60,
            ),
            const SizedBox(height: 10),
            Text(
              'ไม่มีประวัติการใช้งาน',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'สำเร็จ';
      case 'pending':
        return 'กำลังดำเนินการ';
      case 'cancelled':
        return 'ไม่สำเร็จ';
      default:
        return status;
    }
  }
}
