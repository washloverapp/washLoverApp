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
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

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

  final List<Map<String, dynamic>> expiringPoints = [
    {"points": 120, "expireDate": "31 ต.ค. 2025"},
    {"points": 50, "expireDate": "15 พ.ย. 2025"},
    {"points": 30, "expireDate": "1 ธ.ค. 2025"},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: headerOrder(
        title: 'คะแนนสะสม',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 175, 230, 255),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          ...List.generate(20, (index) {
            final random = index * 37.3;
            final top = (random * 7) % screenSize.height;
            final left = (random * 13) % screenSize.width;
            final size = 16 + (random % 28);
            return Positioned(
              top: top,
              left: left,
              child: _bubble(size),
            );
          }),

          Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1.2,
                      color: const Color.fromARGB(80, 212, 175, 55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 248, 248, 255),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userPhone,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A237E),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFFFFC107),
                                      Color(0xFFFFD54F)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: const Icon(Icons.stars_rounded,
                                      color: Colors.white, size: 26),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "$point Points",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(
                              "$point คะแนน • หมดอายุ 31 ต.ค. 2025",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFBBDEFB),
                                  Color(0xFFE3F2FD),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2.5),
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  const AssetImage('assets/images/duck2.jpg'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "คะแนน ที่จะหมดอายุ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C48B5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: expiringPoints.length,
                            itemBuilder: (context, index) {
                              final item = expiringPoints[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.blueAccent.shade100),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_filled,
                                            color: Colors.orange, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${item['points']} คะแนน",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "หมดอายุ ${item['expireDate']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.redAccent,
                                        fontStyle: FontStyle.italic,
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
                ),
              ),
            ],
          ),
        ],
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
      const Color.fromARGB(255, 62, 122, 172),
      const Color.fromARGB(255, 68, 191, 207),
      const Color.fromARGB(255, 214, 132, 140),
      const Color.fromARGB(255, 230, 216, 93),
    ];
    final color = (colors..shuffle()).first.withOpacity(0.25);

    final rotation = ([-0.3, 0.2, 0.4]..shuffle()).first;

    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
