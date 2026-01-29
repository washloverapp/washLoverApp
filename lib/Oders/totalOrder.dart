import 'dart:convert';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Chat/utils/utils.dart';
import 'package:my_flutter_mapwash/Home/promotion.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:my_flutter_mapwash/Oders/API/api_totalOrder.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TotalOrder extends StatefulWidget {
  @override
  _TotalOrderState createState() => _TotalOrderState();
}

class _TotalOrderState extends State<TotalOrder> {
  Map<String, dynamic> _selection = {};
  List<Map<String, dynamic>> items = [];

  bool _isLoading = true;

  // Mock data for item details
  final Map<String, Map<String, dynamic>> _itemDetails = {
    "0": {"name": "เครื่องซักผ้า", "detail": "ขนาด 12 kg.", "price": 40},
    "1": {"name": "เครื่องซักผ้า", "detail": "ขนาด 16 kg.", "price": 50},
    "2": {"name": "เครื่องซักผ้า", "detail": "ขนาด 21 kg.", "price": 60},
    "3": {"name": "เครื่องอบผ้า", "detail": "ขนาด 12 kg.", "price": 40},
    "4": {"name": "เครื่องอบผ้า", "detail": "ขนาด 16 kg.", "price": 50},
    "5": {"name": "เครื่องอบผ้า", "detail": "ขนาด 21 kg.", "price": 60},
    "6": {"name": "อุณหภูมิน้ำ", "detail": "นำ้เย็น", "price": 0},
    "7": {"name": "อุณหภูมิน้ำ", "detail": "นำ้อุ่น", "price": 10},
    "8": {"name": "อุณหภูมิน้ำ", "detail": "นำ้ร้อน", "price": 20},
    "9": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
    "10": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
    "11": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
    "12": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
    "13": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
    "14": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
    "15": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
    "16": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
  };

  Future<void> _loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final selectionString = prefs.getString('selection');
    if (selectionString != null) {
      setState(() {
        _selection = json.decode(selectionString);
        _isLoading = false;
      });
      print(_selection);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> jsonData = [];
  List<Map<String, dynamic>> address = []; // ประกาศเป็น Map แทน List
  List<Map<String, dynamic>> addressBranch = []; // ประกาศเป็น Map แทน List
  Map<String, dynamic>? selectedCouponPromotion;
  String? selectedPromotionDetail = '';
  double selectedPromotionPrice = 0.0;
  double totalCost = 0;

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
    // _loadCart();
    _loadSelection();
  }

  Future<void> _requestIncognito() async {
    final prefs = await SharedPreferences.getInstance();
    final incognitoValue = prefs.getString('incognito') ?? '';

    // ถ้าเป็นโหมดไม่ระบุตัวตน
    if (incognitoValue.isNotEmpty) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'ไม่สามารถทำรายการได้',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('กรุณาเข้าสู่ระบบก่อนใช้งานฟังก์ชันนี้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด popup
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  Future<Status> _send_update_location() async {
    Status status = Status(status: false, messageJson: {});
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double lat = prefs.getDouble('lat') ?? 0.0;
      double lng = prefs.getDouble('lng') ?? 0.0;
      var succ = await ApiPost.updateLocation(lat: lat, lng: lng);
      if (succ.status) {
        status.messageJson = succ.messageJson;
        status.status = true;
        var job_id = succ.messageJson['device_id'];
        final sender = ApiTotalorder();
        final order = await sender.loadOrderSummary();
        await sender.clearCart(order, job_id);
      } else {
        print('Error loading history: ${json.encode(succ.messageJson)}');
        status.messageJson = succ.messageJson;
      }
    } catch (e) {
      print('Error loading history: $e');
      status.messageJson = {"error": e};
    }
    return status;
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selection.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่มีรายการที่เลือก',
                          style: GoogleFonts.kanit(
                              fontSize: 18, color: Colors.grey[600]),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: _buildOrderDetails(),
                      ),
          ),
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
              // ตรงนี้บวกด้วย selectedCouponPromotion!['amount']
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_num, size: 24),
                      SizedBox(width: 10),
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
                            : 'คูปองส่วนลด',
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
                      "฿$totalCost",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 191, 43, 33),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final incognitoValue = prefs.getString('incognito') ?? '';

                    // ถ้าเป็นโหมดไม่ระบุตัวตน
                    if (incognitoValue.isNotEmpty) {
                      if (!mounted) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Row(
                              children: const [
                                Icon(Icons.lock_outline,
                                    color: Colors.red, size: 28),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'ไม่สามารถทำรายการได้',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'ฟังก์ชันนี้ไม่สามารถใช้งานได้ในโหมดไม่ระบุตัวตน\nกรุณาเข้าสู่ระบบเพื่อดำเนินการต่อ',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            actionsAlignment: MainAxisAlignment.end,
                            actionsPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            actions: [
                              // ปุ่มยกเลิก
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // ปิด popup
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                ),
                                child: const Text(
                                  'ยกเลิก',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),

                              // ปุ่มออกจากโหมดไม่ระบุตัวตน / ออกจากระบบ
                              TextButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();

                                  // ล้างข้อมูลทั้งหมด
                                  await prefs.clear();

                                  if (!mounted) return;

                                  Navigator.pop(context); // ปิด popup

                                  // ไปหน้า Login / หน้าแรก
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LoginPage(), // แก้เป็นหน้าของคุณ
                                    ),
                                    (route) => false,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'ออกจากระบบ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      return;
                    }

                    var succ = await _send_update_location();
                    if (succ.status) {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Qrcode(),
                      //     settings: RouteSettings(
                      //       arguments: {
                      //         'totalPrice': totalCost,
                      //         'address': address ?? 'ไม่พบที่อยู่',
                      //         'addressBranch':
                      //             addressBranch ?? 'ไม่พบสาขาที่ใกล้ที่สุด',
                      //         'coupon': (selectedCouponPromotion?['amount']
                      //                 ?.toString() ??
                      //             '$totalCost'),
                      //         'payment': 'manual',
                      //       },
                      //     ),
                      //   ),
                      // );
                    } else {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Qrcode(),
                      //     settings: RouteSettings(
                      //       arguments: {
                      //         'totalPrice': totalCost,
                      //         'address': address ?? 'ไม่พบที่อยู่',
                      //         'addressBranch':
                      //             addressBranch ?? 'ไม่พบสาขาที่ใกล้ที่สุด',
                      //         'coupon': (selectedCouponPromotion?['amount']
                      //                 ?.toString() ??
                      //             '$totalCost'),
                      //         'payment': 'manual',
                      //       },
                      //     ),
                      //   ),
                      // );
                    }
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

  List<Widget> _buildOrderDetails() {
    double calculatedCost = 0; // ← ใช้ตัวนี้คำนวณแทน totalCost
    final List<Widget> details = [];

    // ⭐ Minimal Card
    Widget buildCard(String title, List<Widget> children) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );
    }

    TextStyle nameStyle = GoogleFonts.kanit(fontSize: 16);
    TextStyle detailStyle =
        GoogleFonts.kanit(fontSize: 13, color: Colors.grey.shade600);
    TextStyle priceStyle = GoogleFonts.kanit(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    // ----------------------------------------------------------
    // ⭐ ประเภทผ้า
    final clothingType = _selection['clothingType'];
    if (clothingType != null && clothingType.toString().isNotEmpty) {
      final item = clothingType == 1 ? "เสื้อผ้า" : "ชุดเครื่องนอน / ผ้านวม";

      details.add(buildCard("ประเภทผ้า", [
        Row(
          children: [
            Icon(Icons.check_circle, size: 20, color: Colors.green.shade600),
            SizedBox(width: 10),
            Text(item, style: nameStyle),
          ],
        )
      ]));
    }

    // ----------------------------------------------------------
    // ⭐ น้ำยาซัก
    final detergents = _selection['detergent'] as Map?;
    if (detergents != null && detergents.isNotEmpty) {
      final items = detergents.entries.map((e) {
        final info = _itemDetails[e.key] ?? {};
        final price = (info['price'] ?? 0) * e.value;

        calculatedCost += price;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(info['name'] ?? '', style: nameStyle),
              Text('${e.value} × ${info['price']} = $price บาท',
                  style: priceStyle),
            ],
          ),
        );
      }).toList();

      details.add(buildCard("น้ำยาซัก", items));
    }

    // ----------------------------------------------------------
    // ⭐ น้ำยาปรับผ้านุ่ม
    final softeners = _selection['softener'] as Map?;
    if (softeners != null && softeners.isNotEmpty) {
      final items = softeners.entries.map((e) {
        final info = _itemDetails[e.key] ?? {};
        final price = (info['price'] ?? 0) * e.value;

        calculatedCost += price;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(info['name'] ?? '', style: nameStyle),
              Text('${e.value} × ${info['price']} = $price บาท',
                  style: priceStyle),
            ],
          ),
        );
      }).toList();

      details.add(buildCard("น้ำยาปรับผ้านุ่ม", items));
    }

    // ----------------------------------------------------------
    // ⭐ รายการแบบเลือกทีละตัว
    final singleSelectionCategories = {
      'washing': 'เครื่องซักผ้า',
      'temperature': 'อุณหภูมิน้ำ',
      'dryer': 'เครื่องอบผ้า',
    };

    singleSelectionCategories.forEach((key, title) {
      final id = _selection[key];
      if (id == null) return;

      final info = _itemDetails[id.toString()];
      if (info == null) return;

      calculatedCost += info['price'];

      details.add(buildCard(title, [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info['name'], style: nameStyle),
                SizedBox(height: 4),
                Text(info['detail'], style: detailStyle),
              ],
            ),
            Text('${info['price']} บาท', style: priceStyle),
          ],
        )
      ]));
    });

    // ----------------------------------------------------------
    // ⭐ TOTAL (แบบเรียบๆ)
    details.add(
      Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ยอดรวมทั้งหมด",
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$calculatedCost บาท",
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey.shade900,
              ),
            ),
          ],
        ),
      ),
    );

    // อัปเดต totalCost ให้เป็นยอดใหม่เสมอ (ไม่บวกเพิ่ม)
    totalCost = calculatedCost;

    return details;
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
