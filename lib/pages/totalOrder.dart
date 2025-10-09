import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/pages/addressLocation.dart';
import 'package:my_flutter_mapwash/pages/address_list_screen.dart';
import 'package:my_flutter_mapwash/Home/promotion.dart';
import 'package:my_flutter_mapwash/pages/send_confirm_oder.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> loadConvertedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('convertedSelectedOptions');
    String? clothingTypeStr = prefs.getString('selectedOptions');

    if (clothingTypeStr != null) {
      var loadedData = jsonDecode(clothingTypeStr);
      if (loadedData is Map<String, dynamic>) {
        var clothingType = loadedData['clothingType'];
        if (clothingType == 2) {
          // ถ้าเป็นชุดเครื่องนอน
          if (savedData != null) {
            Map<String, dynamic> loadedData = jsonDecode(savedData);
            List<Map<String, dynamic>> items = [];
            String? noteData;

            if (loadedData['items'] != null) {
              List<Map<String, dynamic>> allItems =
                  List<Map<String, dynamic>>.from(loadedData['items']);
              // กรองข้อมูลที่ไม่รวม type = 'washing', 'temperature', หรือ 'dryer'
              items = allItems.where((item) {
                return item['type'] != 'washing' &&
                    item['type'] != 'temperature' &&
                    item['type'] != 'dryer';
              }).toList();
            }
            noteData = loadedData['note'];

            Map<String, dynamic> newItem = {
              'id': 101,
              'code': 'PD9999999999',
              'name': 'ชุดเครื่องนอน/ผ้านวม',
              'detail': 'ชุดเครื่องนอน/ผ้านวม',
              'price': 120.00,
              'type': 'panum',
              'image': 'https://washlover.com/image/nuam22.png',
              'quantity': 1
            };
            items.add(newItem);
            setState(() {
              jsonData = items;
              note = noteData;
            });
          }
        } else {
          // ชุดเสื้อผ้า
          if (savedData != null) {
            Map<String, dynamic> loadedData = jsonDecode(savedData);
            List<Map<String, dynamic>> items = [];
            String? noteData;
            if (loadedData['items'] != null) {
              items = List<Map<String, dynamic>>.from(loadedData['items']);
            }
            noteData = loadedData['note'];

            setState(() {
              jsonData = items;
              note = noteData;
            });
          }
        }
      } else {}
    } else {}
  }

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

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressListScreen(),
      ),
    );

    if (selectedAddress != null) {
      // _showSingleAnimationDialog(Indicator.ballScale, true);
      setState(() {
        address = [selectedAddress];
      });
      var result = await findClosestBranch(address);
      setState(() {
        branchName = result['closestBranch'] ?? "ไม่พบสาขาที่ใกล้ที่สุด";
        addressBranch = [
          {
            'closestDistance': result['closestDistance'],
            'closestBranch': result['closestBranch'],
            'code': result['code'],
            'address': result['address'],
            'latitude': result['latitude'],
            'longitude': result['longitude'],
            'branch': result['branch'],
          }
        ];
      });
      // Navigator.pop(context);
    }
  }

  Future<String?> getPhoneFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  Future<Map<String, dynamic>?> getAddressFromApi(String phone) async {
    final response = await http.get(
        Uri.parse('https://washlover.com/api/getaddress/phone?phone=$phone'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'success') {
        return data['data'] != null && data['data'].isNotEmpty
            ? data['data'][0]
            : null;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> CheckUserCredit() async {
    String? phone = await getPhoneFromPreferences();
    final response = await http
        .get(Uri.parse('https://washlover.com/api/member?phone=$phone'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data);
      if (data['status'] == 'success') {
        double credit =
            double.tryParse(data['data']['credit']?.toString() ?? '') ?? 0.0;
        Total_credit = credit;

        return data['data'] != null && data['data'].isNotEmpty
            ? data['data'][0]
            : null;
      }
    }
    return null;
  }

  void fetchData() async {
    // _showSingleAnimationDialog(Indicator.ballScale, true);
    String? phone = await getPhoneFromPreferences();
    if (phone != null) {
      var addressFromApi = await getAddressFromApi(phone);
      if (addressFromApi != null) {
        setState(() {
          address = [addressFromApi];
        });
        var result = await findClosestBranch(address);
        setState(() {
          branchName = result['closestBranch'] ?? "ไม่พบสาขาที่ใกล้ที่สุด";
          addressBranch = [
            {
              'closestDistance': result['closestDistance'],
              'closestBranch': result['closestBranch'],
              'code': result['code'],
              'address': result['address'],
              'latitude': result['latitude'],
              'longitude': result['longitude'],
              'branch': result['branch'],
            }
          ];
        });
      } else {}
    } else {
      print("Phone number not found.");
    }
    // Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadConvertedData();
    fetchData();
    CheckUserCredit();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = jsonData.isNotEmpty ? jsonData : [];
    List<Map<String, dynamic>> discount = jsonDataDiscount[0]["discount"];

    double totalPrice = items.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
      return sum + (price * quantity);
    });

    double totalPrice_discount = discount.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      return sum + (price + totalPrice);
    });

    if (selectedCouponPromotion != null &&
        selectedCouponPromotion!['amount'] != null &&
        selectedCouponPromotion!['amount'] != '0.0') {
      totalPrice_discount -= double.parse(selectedCouponPromotion!['amount']);
    }

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
              _navigateAndDisplaySelection(context);
              print("ที่อยู่");
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey[100],

              margin: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // ลดระยะห่างตรงนี้
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.green[400],
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address.isNotEmpty
                            ? "${address[0]['name']}, ${address[0]['detail']}, ${address[0]['subdistrict']}, ${address[0]['district']}, ${address[0]['province']}, ${address[0]['postcode']}"
                            : "กรุณาเลือกที่อยู่",
                        style: TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red[300],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
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

          // List of orders dynamically generated from jsonData
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];

                double price = double.tryParse(item['price'].toString()) ?? 0.0;
                int quantity = int.tryParse(item['quantity'].toString()) ?? 0;

                String imageUrl = item['image'];
                // String imageUrlCount = 'assets/images/pha1.jpg';
                return OrderCard(
                  title: item['name'], // ชื่อสินค้าจาก jsonData
                  subtitle: item['detail'], // รายละเอียดสินค้า
                  price: item['price'].toString(), // ราคาสินค้า
                  image: imageUrl, // ใช้ path ของภาพที่อยู่ใน jsonData
                  quantity: item['quantity'], // จำนวน
                  totalPrice: (price * quantity).toInt(), // คำนวณราคาทั้งหมด
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
                      "฿${(totalPrice_discount < 0 ? 0.0 : totalPrice_discount).toStringAsFixed(2)}",
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
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิด dialog
                      },
                      child: Text('ตกลง'),
                    );
                    if (address != null || address.isEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Qrcode(),
                          settings: RouteSettings(
                            arguments: {
                              'totalPrice':
                                  totalPrice_discount.toStringAsFixed(2) ??
                                      0.00,
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
                    } else {
                      if (Total_credit < totalPrice_discount) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Qrcode(),
                            settings: RouteSettings(
                              arguments: {
                                'totalPrice':
                                    totalPrice_discount.toStringAsFixed(2) ??
                                        0.00,
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
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Qrcode(),
                            settings: RouteSettings(
                              arguments: {
                                'totalPrice':
                                    totalPrice_discount.toStringAsFixed(2),
                                'address': address,
                                'addressBranch': addressBranch,
                                'coupon': (selectedCouponPromotion?['amount']
                                        ?.toString() ??
                                    '0.00'),
                                'payment': 'credit',
                              },
                            ),
                          ),
                        );
                      }
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
                child: Image.network(
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

Future<Map<String, dynamic>> findClosestBranch(dynamic address) async {
  double closestDistance = double.infinity;
  String closestBranch = '';
  String code = '';
  String addressbranch = '';
  String latitude = '';
  String longitude = '';
  String branch = '';
// ข้อมูลตำแหน่งของคุณ
  double myLat = double.parse('${address[0]['latitude']}');
  double myLon = double.parse('${address[0]['longitude']}');
  // print('addresssssssss: ${address[0]['latitude']}');
  if (address.isNotEmpty) {
    double myLat = double.parse('${address[0]['latitude']}');
    double myLon = double.parse('${address[0]['longitude']}');
  }

  final response =
      await http.get(Uri.parse('https://washlover.com/api/branch?get=2'));
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success' && jsonData['data'] != null) {
      List<Map<String, dynamic>> branches =
          List<Map<String, dynamic>>.from(jsonData['data']);
      for (var currentBranch in branches) {
        double distance = haversineDistance(
          myLat,
          myLon,
          double.parse(currentBranch['latitude']),
          double.parse(currentBranch['longitude']),
        );
        if (distance < closestDistance) {
          closestDistance = distance;
          closestBranch = currentBranch['name'];
          code = currentBranch['code'];
          addressbranch = currentBranch['address'];
          latitude = currentBranch['latitude'];
          longitude = currentBranch['longitude'];
          branch = currentBranch['branch'];
        }
      }
      return {
        'closestDistance': closestDistance,
        'closestBranch': closestBranch,
        'code': code,
        'address': addressbranch,
        'latitude': latitude,
        'longitude': longitude,
        'branch': branch,
      };
    } else {
      print('ไม่สามารถดึงข้อมูลสาขาได้');
    }
  } else {
    throw Exception('ไม่สามารถดึงข้อมูลจาก API');
  }
  return {};
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
