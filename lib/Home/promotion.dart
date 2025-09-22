import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // เพิ่ม http package

class Promotion extends StatefulWidget {
  // final String price;
  // final String detail;

  // Promotion({Key? key, required this.price, required this.detail})
  //     : super(key: key);
  final Map<String, dynamic>? selectedCoupons; // ใช้ Map ที่รองรับค่าที่เป็น null

  Promotion({this.selectedCoupons}); // ไม่มีค่าเริ่มต้นกำหนด

  @override
  _PromotionState createState() => _PromotionState();
}

Future<String?> prefsCODE() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? codebranch = prefs.getString('prefsCODE');
  return codebranch;
}

class _PromotionState extends State<Promotion> {
  Map<String, dynamic>? selectedCoupon;
  List<dynamic> promotionData = [];

 Future<void> fetchPromotionData() async {
    try {
      String? phcodebranchone = await prefsCODE() ?? '';
      final response = await http.get(Uri.parse(
          'https://washlover.com/panel/promotion?get_promotion=1&type=daily&more=500&code=$phcodebranchone'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];

        if (data != null && data is List && data.isNotEmpty) {
          setState(() {
            promotionData = (data as List).map((promo) {
              String imageUrl = 'https://washlover.com/img/logo_app.png';
              if (promo['image'] is List &&
                  (promo['image'] as List).isNotEmpty) {
                imageUrl = promo['image'][0];
              }
              return {
                "name": promo['name'],
                "detail": promo['detail'],
                "image": imageUrl,
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
          });
        } else {
          _setMockPromotion();
        }
      } else {
        _setMockPromotion();
      }
    } catch (e) {
      print('Error fetching promotions: $e');
      _setMockPromotion();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPromotionData();

    if (widget.selectedCoupons != null && widget.selectedCoupons!.isNotEmpty) {
      setState(() {
        selectedCoupon = widget.selectedCoupons;
      });
    }
  }

  Future<void> fetchSelectedCoupon() async {
    final Map<String, dynamic>? receivedCoupon = await Navigator.push(context, MaterialPageRoute(builder: (context) => TotalOrder())); // หน้า OrderSummary เป็นหน้าก่อนหน้า
    print('coupondsesclc  : $widget.selectedCoupons');
    if (widget.selectedCoupons != null) {
      setState(() {
        selectedCoupon = widget.selectedCoupons; // เก็บคูปองที่เลือก
      });
    }
  }

  void selectCoupon(Map<String, dynamic> coupon) {
    setState(() {
      selectedCoupon = coupon; // ตั้งค่าคูปองที่เลือก
    });
  }

  void cancelCoupon() {
    setState(() {
      selectedCoupon = null; // ยกเลิกคูปองที่เลือก
    });
  }

  void _setMockPromotion() {
    setState(() {
      promotionData = [
        {
          "name": "คูปองส่วนลด 20 บาท",
          "detail": "สำหรับลูกค้าทุกท่าน (ตัวอย่าง)",
          "image": "https://washlover.com/img/logo_app.png",
          "percent": "0",
          "id": "MOCK01",
          "date_start": "2024-01-01",
          "date_end": "2024-12-31",
          "day": "ทุกวัน",
          "time_start": "00:00",
          "time_end": "23:59",
          "type": "daily",
          "amount": "20.00",
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // ลิสต์สีที่จะใช้สำหรับพื้นหลัง
    final List<List<Color>> gradientColors = [
      [Color(0xFFD0C4FA), Color(0xFF98C4FB), Color(0xFFB4A0FF)],
      [Color(0xFFFFCA79), Color(0xFFFE9F95), Color(0xFFFA899E)],
      [Color(0xFF8FCCFB), Color(0xFF45A3F5), Color.fromARGB(255, 120, 197, 182)],
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'โปรโมชั่น', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context, selectedCoupon); // ส่งคูปองที่เลือกกลับไป
        },
      ),
      body: Column(
        children: [
          // แสดงคูปองที่เลือกแล้ว (ถ้ามี)
          if (selectedCoupon != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ใช้คูปองส่วนลด: ${selectedCoupon!['amount']} บาท',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: cancelCoupon, // ยกเลิกการเลือกคูปอง
                    child: Text('ยกเลิก'),
                  ),
                ],
              ),
            ),
          // ถ้าไม่มีการเลือกคูปองแสดงให้เลือก
          Expanded(
            child: promotionData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: promotionData.length,
                    itemBuilder: (context, index) {
                      final promo = promotionData[index];
                      final colors = gradientColors[index % gradientColors.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
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
                                    colors: colors,
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '฿${promo['amount']}',
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Image.network(
                                                    '${promo['image']}',
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      if (selectedCoupon == null) {
                                                        selectCoupon(promo); // เลือกคูปอง
                                                      } else {
                                                        // ถ้ามีคูปองอยู่แล้วแสดงปุ่ม "ใช้"
                                                        print('คูปองถูกใช้');
                                                      }
                                                      // Navigator.pop(context, {
                                                      //   'price':
                                                      //       promo['amount'],
                                                      //   'detail': {
                                                      //     promo['detail']
                                                      //   }
                                                      // });
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      foregroundColor: Colors.black,
                                                      backgroundColor: const Color.fromARGB(13, 255, 255, 255),
                                                    ),
                                                    child: Text(
                                                      selectedCoupon != null && selectedCoupon!['id'] == promo['id'] ? 'ใช้' : 'เลือก', // เปลี่ยนปุ่มจาก "เลือก" เป็น "ใช้"
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
          ),
        ],
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
