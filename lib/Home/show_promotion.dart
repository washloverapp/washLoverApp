import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http; // เพิ่ม http package

class select_Promotion extends StatefulWidget {
  const select_Promotion({super.key});
  @override
  _select_PromotionState createState() => _select_PromotionState();
}

class _select_PromotionState extends State<select_Promotion> {
  List<dynamic> promotionData = [];
  bool _isLoading = true;

  void _createMockData() {
    promotionData = [
      {
        "name": "โปรโมชั่นตัวอย่าง",
        "detail": "ส่วนลดพิเศษสำหรับลูกค้าทุกท่าน",
        "image": "https://washlover.com/panel/img/icon-logo.png",
        "percent": "10",
        "id": "mock-01",
        "date_start": "วันนี้",
        "date_end": "สิ้นปี",
        "day": "ทุกวัน",
        "time_start": "00:00",
        "time_end": "23:59",
        "type": "daily",
        "amount": "1",
      }
    ];
  }

  Future<void> fetchPromotionData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://washlover.com/panel/promotion?get_promotion=1&type=daily&more=500'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic>? data = jsonResponse['data'];

        if (data != null && data.isNotEmpty) {
          promotionData = data.map((promo) {
            return {
              "name": promo['name'],
              "detail": promo['detail'],
              "image": promo['image'][0],
              "percent": promo['persen'],
              "id": promo['id'],
              "date_start": promo['date_start'],
              "date_end": promo['date_end'],
              "day": promo['day'],
              "time_start": promo['time_start'],
              "time_end": promo['time_end'],
              "type": promo['type'],
              "amount": promo['amount'],
            };
          }).toList();
        } else {
          _createMockData(); // API returned empty list, so create mock data.
        }
      } else {
        throw Exception('Failed to load promotions');
      }
    } catch (e) {
      print('Error fetching promotions: $e');
      _createMockData(); // On error, create mock data.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPromotionData();
  }

  @override
  Widget build(BuildContext context) {
    // ลิสต์สีที่จะใช้สำหรับพื้นหลัง
    final List<List<Color>> gradientColors = [
      [Color(0xFFD0C4FA), Color(0xFF98C4FB), Color(0xFFB4A0FF)],
      [Color(0xFFFFCA79), Color(0xFFFE9F95), Color(0xFFFA899E)],
      [
        Color(0xFF8FCCFB),
        Color(0xFF45A3F5),
        Color.fromARGB(255, 120, 197, 182)
      ],
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'โปรโมชั่น', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context); // ใช้ Navigator.pop เพื่อย้อนกลับหน้าปัจจุบัน
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: promotionData.length,
              itemBuilder: (context, index) {
                final promo = promotionData[index];
                final colors = gradientColors[index % gradientColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 16.0),
                  child: Stack(
                    children: [
                      // Border Container
                      ClipPath(
                        clipper: CustomTicketClipper(),
                        child: Container(
                          height: 131,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      // Main Ticket Card
                      ClipPath(
                        clipper: CustomTicketClipper(),
                        child: Container(
                          height: 131,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors, // ใช้สีที่เลือกตามลำดับ
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              // Left Strip
                              Container(
                                width: 55,
                                color: const Color(0xFFCF95DA).withOpacity(0.2),
                                child: const Center(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      'ส่วนลด',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Content Area
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '฿${promo['percent']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${promo['detail']} ',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Image.network(
                                              '${promo['image']}',
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                  stackTrace) {
                                                return Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.contain,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // แสดง AlertDialog เมื่อกดปุ่ม "เลือก"
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'โปรโมชั่น'),
                                                      content: const Text(
                                                          'สามารถเลือกรับโปรโมชั่นได้ก่อนทำรายการเลือกชำระเงิน'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // ปิดกล่องข้อความเมื่อกด "ตกลง"
                                                          },
                                                          child: const Text(
                                                              'ตกลง'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        13, 255, 255, 255),
                                              ),
                                              child: const Text(
                                                'เลือก',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class CustomTicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = 16;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.50 - radius);
    path.arcToPoint(
      Offset(size.width, size.height * 0.50 + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height * 0.50 + radius);
    path.arcToPoint(
      Offset(0, size.height * 0.50 - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
