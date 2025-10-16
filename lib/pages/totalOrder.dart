import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Home/promotion.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;

class TotalOrder extends StatefulWidget {
  @override
  _TotalOrderState createState() => _TotalOrderState();
}

class _TotalOrderState extends State<TotalOrder> {
  List<Map<String, dynamic>> jsonData = [];
  List<Map<String, dynamic>> address = []; // ประกาศเป็น Map แทน List
  List<Map<String, dynamic>> addressBranch = []; // ประกาศเป็น Map แทน List
  Map<String, dynamic>? selectedCouponPromotion;
  String? selectedPromotionDetail = '';
  double selectedPromotionPrice = 0.0;

  String branchName = "กรุณาเลือกที่อยู่สาขา";
  String? note = '';
  String? payment = 'credit';
  double Total_credit = 0;
  final List<Map<String, dynamic>> jsonDataDiscount = [
    {
      "discount": [
        {
          "name": "ส่วนลด",
          "price": 0,
          "detail": "ยังไม่มีรายการส่วนลด",
          "quantity": 1,
          "impag": "https://washlover.com/uploads/sakpa2.png",
        },
      ]
    }
  ];

  void _navigateAndDisplaySelectionPromotion(BuildContext context) async {
    final selectedPromotion = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Promotion(
          selectedCoupons: selectedCouponPromotion ?? {},
        ),
      ),
    );
    setState(() {
      selectedCouponPromotion = selectedPromotion;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  List<Map<String, dynamic>> items = [
    {
      "name": "เครื่องซักผ้า",
      "detail": "ขนาด 16 km.",
      "price": "50",
      "quantity": "2",
      "image": "assets/images/sakpa.png"
    },
    {
      "name": "เครื่องอบผ้า",
      "detail": "ขนาด 16 km.",
      "price": "70",
      "quantity": "1",
      "image": "assets/images/ooppa2.png"
    },
    {
      "name": "น้ำยาซักผ้า",
      "detail": "น้ำยาซักผ้าอย่างอ่อนโยน",
      "price": "120",
      "quantity": "1",
      "image": "assets/images/notag.png"
    },
    {
      "name": "น้ำยาปรับผ้านุ่ม",
      "detail": "น้ำยาอย่างอ่อนโยน",
      "price": "30",
      "quantity": "3",
      "image": "assets/images/notag.png"
    },
    {
      "name": "อุณหภูมิน้ำ",
      "detail": "อุณหภูมิน้ำเย็น",
      "price": "30",
      "quantity": "3",
      "image": "assets/images/water01.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'รายการ',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              print("สาขา");
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey[100],
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.blue[300],
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        branchName.isNotEmpty
                            ? "สาขา : $branchName"
                            : "กรุณาเลือกที่อยู่สาขา",
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.water_drop_sharp,
                      color: Colors.blue[200],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // ฟังก์ชันที่ต้องการเมื่อ Card ถูกคลิก
              print("หมายเหตุ");
            },
            child: Card(
              elevation: 0, // ความลึกเงา
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // มุมโค้ง
              ),
              color: Colors.grey[100], // กำหนดสีพื้นหลังให้กับ Card (สีเทาอ่อน)
              margin: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 0), // เพิ่ม margin ซ้ายขวา
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.note_alt,
                      color: Colors.red[300],
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      // ใช้ Expanded เพื่อให้ Text ใช้พื้นที่ที่เหลือ
                      child: Text(
                        'หมายเหตุ: $note', // ไม่ใช้ const เพราะ note เป็นตัวแปรที่สามารถเปลี่ยนแปลงได้
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Divider(
            color: const Color.fromARGB(5, 0, 0, 0),
            thickness: 3, // ความหนาของเส้น
            indent: 0, // ระยะห่างจากขอบซ้าย
            endIndent: 0, // ระยะห่างจากขอบขวา
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                double price = double.tryParse(item['price'].toString()) ?? 0.0;
                int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
                String imageUrl = item['image'];
                return OrderCard(
                  title: item['name'],
                  subtitle: item['detail'],
                  price: item['price'].toString(),
                  image: imageUrl,
                  quantity: quantity, // ✅ ใช้ตัวที่แปลงเป็น int แล้ว
                  totalPrice: (price * quantity).toInt(),
                );
              },
            ),
          ),
          // New section at the bottom
          Container(
            height: 1, // ความหนาของเส้น
            decoration: BoxDecoration(
              color: const Color.fromARGB(54, 160, 190, 255), // สีของเส้น
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 230, 230, 230)
                      .withOpacity(0.2), // สีเงา
                  blurRadius: 10, // ความเบลอของเงา
                  offset: Offset(0, 2), // ทิศทางของเงา (ด้านล่าง)
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _navigateAndDisplaySelectionPromotion(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_num, size: 24), // ไอคอนคูปอง
                      SizedBox(width: 10), // เว้นระยะห่างระหว่างไอคอนกับข้อความ
                      Text(
                        (selectedCouponPromotion != null &&
                                selectedCouponPromotion!['amount'] != null &&
                                double.tryParse(
                                        selectedCouponPromotion!['amount']) !=
                                    null &&
                                double.parse(
                                        selectedCouponPromotion!['amount']) >
                                    0)
                            ? 'ใช้คูปองส่วนลด ${selectedCouponPromotion!['amount']} บาท'
                            : 'คูปองส่วนลด', // ถ้ามีการเลือกคูปองจะเปลี่ยนข้อความ
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "เลือก", // คำว่า "เลือก"
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 24), // ลูกศร
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(
                top: 0.0, bottom: 40.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "ทั้งหมด ",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 155, 155, 155)),
                    ),
                    Text(
                      "฿0.00",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 191, 43, 33),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Qrcode(),
                        settings: RouteSettings(
                          arguments: {
                            'totalPrice': 0.00,
                            'address': address ?? 'ไม่พบที่อยู่',
                            'addressBranch':
                                addressBranch ?? 'ไม่พบสาขาที่ใกล้ที่สุด',
                            'coupon': (selectedCouponPromotion?['amount']
                                    ?.toString() ??
                                '0.00'),
                            'payment': 'manual',
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "ชำระเงิน",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String image; // Path of image from jsonData
  final int quantity;
  final int totalPrice;

  const OrderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
    required this.quantity,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 0, top: 0, left: 0, right: 0),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: const Color.fromARGB(15, 0, 0, 0),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  image, // ดึงภาพจาก URL ที่เก็บใน jsonData
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image,
                      color: const Color.fromARGB(255, 229, 27, 27),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "จำนวน: ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextSpan(
                              text: "$quantity ",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "(฿$price)",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "฿$totalPrice.00", // แสดงราคาด้านซ้าย
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const double radius = 6371;
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return radius * c * 1000;
}

double _toRadians(double degree) {
  return degree * (pi / 180);
}
