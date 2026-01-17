import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:my_flutter_mapwash/Home/API/api_account.dart';
import 'package:my_flutter_mapwash/Home/API/api_history.dart';
import 'package:my_flutter_mapwash/Status/API/api_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  static const Color lightBlue = Color(0xFFE8F1FF);
  static const Color primaryBlue = Color(0xFF1E62F9);
  Map<String, String> _priceCache = {};
  List<dynamic> _historyData = [];
 String credit = "Loading...";
  String point_h = "Loading...";

  Future<void> _loadUserData() async {
    var userData = await API_account.fetchapiaccount();
    if (userData != null) {
      setState(() {
        if (userData['credit'] == null) {
          userData['credit'] = 0;
          credit = userData['credit'].toString();
        } else {
          credit = userData['credit'].toString();
        }
        if (userData['points'] == null) {
          userData['points'] = 0;
        } else {
          point_h = userData['points'].toString();
        }
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await api_history.fetchHistory();
      setState(() {
        _historyData = data;
      });
    } catch (e) {
      setState(() => _historyData = []);
    }
  }

  Future<String> _getCartPriceOnce(String deviceId) async {
    if (_priceCache.containsKey(deviceId)) {
      return _priceCache[deviceId]!;
    }

    final price = await ApisCartjob().getCartTotalPrice(deviceId);
    _priceCache[deviceId] = price;
    return price;
  }

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
              gradient: LinearGradient(
                colors: [Color.fromARGB(169, 80, 171, 245), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          ////////////////////////////////////////// ประวัติรายการ //////////////////////////////////////////
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(),

                // ====== หัวข้อส่วนบน ======
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ประวัติรายการ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Color(0xFF1B1B1B),
                        ),
                      ),
                      Text(
                        getCurrentDateThai(), // แสดงวันที่ปัจจุบันแบบเต็ม
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // ====== ส่วนแสดงอัปเดตล่าสุด ======
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'อัปเดตล่าสุดเมื่อ ${getCurrentDateThai()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.2,
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),

                // ====== เนื้อหา ======
                Expanded(
                  child: _historyData.isEmpty
                      ? _buildEmptyHistory()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          itemCount: _historyData.length,
                          itemBuilder: (context, index) {
                            var item = _historyData[index];

                            String deviceId =
                                item['device_id'].toString(); // ✅ เพิ่ม
                            String date = item['set_at'] ?? '-';
                            String time = item['started_at'] ?? '-';
                            String status = (item['status'] ?? '').toString();
                            String price = item['duration_str'] ?? '0.0';

                            Color statusColor = _getStatusColor(status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF8FAFF),
                                    Color(0xFFEFF2FF)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    offset: const Offset(4, 4),
                                    blurRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    offset: const Offset(-4, -4),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () {},
                                  splashColor: statusColor.withOpacity(0.15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // ===== ไอคอน =====
                                        Container(
                                          height: 52,
                                          width: 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                statusColor.withOpacity(0.8),
                                                statusColor,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: statusColor
                                                    .withOpacity(0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.local_laundry_service_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),

                                        const SizedBox(width: 18),

                                        // ===== ข้อมูล =====
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formatThaiDate(date, time),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      statusColor
                                                          .withOpacity(0.85),
                                                      statusColor,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: statusColor
                                                          .withOpacity(0.3),
                                                      blurRadius: 6,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  _getStatusText(status),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ===== ราคา =====
                                        FutureBuilder<String>(
                                          future: _getCartPriceOnce(deviceId),
                                          builder: (context, snapshot) {
                                            String displayPrice =
                                                price; // fallback ใช้ของเดิมก่อน

                                            if (snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData) {
                                              displayPrice = snapshot.data!;
                                            }

                                            return Text(
                                              '฿$displayPrice',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22,
                                                color: statusColor,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                color: Colors.white, // พื้นหลังสีขาวล้วน
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
                          color: Color(0xFF666666), // สีเทาเข้มแบบเรียบๆ
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '฿${credit}',
                    style: TextStyle(
                      color: Colors.grey[800], // สีเทาเข้มหน่อย
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Transform.rotate(
                            angle: -0.3, // หมุนไปทางซ้ายเล็กน้อย
                            child: Image.asset('assets/images/duck.png',
                                width: 80, height: 40),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'คูปอง',
                            style: TextStyle(
                                color: Color(0xFF888888), fontSize: 18),
                          ),
                          const Text(
                            '0',
                            style: TextStyle(
                                color: Color.fromARGB(255, 131, 124, 124),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Transform.rotate(
                            angle: 0.5, // หมุนไปทางขวาเล็กน้อย
                            child: Image.asset('assets/images/duck.png',
                                width: 80, height: 40),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'คะแนนสะสม',
                            style: TextStyle(
                                color: Color(0xFF888888), fontSize: 18),
                          ),
                          Text(
                            '${point_h}',
                            style: TextStyle(
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          // ไม่หมุนเลย ปกติ
                          Image.asset('assets/images/duck.png',
                              width: 80, height: 40),
                          const SizedBox(height: 4),
                          const Text(
                            'เครดิต',
                            style: TextStyle(
                                color: Color(0xFF888888), fontSize: 18),
                          ),
                           Text(
                            '${credit}',
                            style: TextStyle(
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  )
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

  String formatThaiDate(String date, String time) {
    final monthsThai = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];

    try {
      String dateTimeString;
      if (date.contains('T')) {
        dateTimeString = date;
      } else {
        dateTimeString = time.isNotEmpty ? '$date $time' : date;
      }
      DateTime dt = DateTime.parse(dateTimeString).toLocal();
      final buddhistYear = dt.year + 543;
      final thaiMonth = monthsThai[dt.month - 1];
      final formattedTime =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '${dt.day} $thaiMonth $buddhistYear $formattedTime น.';
    } catch (e) {
      return '$date ${time ?? ''}'.trim();
    }
  }

// ฟังก์ชันช่วยสร้างไอเท็มแสดงข้อมูล พร้อมพารามิเตอร์สี
  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color textColor = Colors.black,
    Color labelColor = Colors.black54,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 36,
          color: textColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
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
      const Color.fromARGB(255, 255, 127, 127),
      const Color.fromARGB(255, 129, 186, 255),
      const Color.fromARGB(255, 79, 170, 255),
      const Color.fromARGB(255, 115, 181, 247),
      const Color.fromARGB(255, 48, 162, 255),
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
                color: Color.fromARGB(255, 115, 121, 132), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatThaiDate(date, time),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
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
      case '4': // เสร็จสิ้น
        return const Color(0xFF2ECC71); // เขียวสด
      case '3': // ไม่สำเร็จ
        return const Color(0xFFE74C3C); // แดงเข้ม
      case '2': // คนขับรับงานแล้ว
        return const Color(0xFF3498DB); // ฟ้าน้ำทะเล
      case '1': // รอคนขับ
        return const Color(0xFFF1C40F); // เหลืองทอง
      default:
        return Colors.grey; // เผื่อค่าที่ไม่ตรง
    }
  }

  // สร้างตัวแปรแสดงเดือนปัจจุบันแบบไทย
  String getCurrentDateThai() {
    final monthsThai = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    final now = DateTime.now();
    final day = now.day;
    final month = monthsThai[now.month - 1];
    final year = now.year + 543; // แปลงเป็น พ.ศ.
    return '$day $month $year';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case '4':
        return 'เสร็จสิ้น';
      case '3':
        return 'ไม่สำเร็จ';
      case '2':
        return 'คนขับรับงานแล้ว';
      case '1':
        return 'รอคนขับ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }
}
