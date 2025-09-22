import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'dart:convert';
import 'package:my_flutter_mapwash/Header/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersState createState() => _OrdersState();
}

final TextEditingController _hintController = TextEditingController();
final TextEditingController _noteController = TextEditingController();

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    super.initState();
    stockData = fetchStockData(); // เรียกใช้งานฟังก์ชัน fetchStockData
    _prefs();
    _loadData();
  }

  int? _selectedValueWash = -1;
  int? _selectedValueDryer = -1;
  int? _selectedValue = 0;
  double _progress = 0.01;
  // double _progress = 0.31;
  final int _totalSteps = 11;
  String? selectedItem;
  late Future<Map<String, dynamic>> stockData;
  String? _selectedTemperature = null;

  List<Map<String, dynamic>> products_detergent = [];
  List<Map<String, dynamic>> products_softener = [];
  List<Map<String, dynamic>> products_washing = [];
  List<Map<String, dynamic>> products_temperature = [];
  List<Map<String, dynamic>> products_dryer = [];

  Future<Map<String, dynamic>> fetchStockData() async {
    final response =
        await http.get(Uri.parse('https://washlover.com/api/stock'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      // กรองสินค้าที่มี type เป็น 'detergent' น้ำยาซักผ้า
      products_detergent = List<Map<String, dynamic>>.from(
          data.where((item) => item['type'] == 'detergent'));

      products_softener = List<Map<String, dynamic>>.from(
          data.where((item) => item['type'] == 'softener'));

      products_washing = List<Map<String, dynamic>>.from(
          data.where((item) => item['type'] == 'washing'));

      products_temperature = List<Map<String, dynamic>>.from(
          data.where((item) => item['type'] == 'temperature'));

      products_dryer = List<Map<String, dynamic>>.from(
          data.where((item) => item['type'] == 'dryer'));
      // ตรวจสอบว่า products_detergent มีข้อมูลหรือไม่
      if (products_detergent.isEmpty) {
        print('ไม่พบสินค้า detergent');
      }

      return json.decode(response.body);
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลสินค้าได้');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: Header(), // ตัวนี้จะใช้ Header ที่ไม่มี Icon
      ),
      backgroundColor: Color(0xFFC1E2FD), // ตั้งค่าพื้นหลังให้เป็นสีฟ้า

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (_progress > 0.0 && _progress < 0.1)
                        Column(
                          // ใช้ Column เพื่อห่อทั้ง Text และ Row
                          children: [
                            Text(
                              'เลือกรายการซัก',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF000000),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildImageTile(
                                    imageAsset: 'assets/images/pha1.jpg',
                                    label: 'เสื้อผ้า',
                                    value: 1,
                                  ),
                                ),
                                const SizedBox(
                                    width: 16), // Add spacing between the tiles
                                Expanded(
                                  child: _buildImageTile(
                                    imageAsset: 'assets/images/nuam.png',
                                    label: 'ชุดที่นอน/ผ้านวม',
                                    value: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (_progress > 0.1 && _progress < 0.2)
                        Column(
                          children: [
                            Text(
                              'น้ำยาซักผ้า',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products_detergent.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // จำนวนคอลัมน์
                                mainAxisSpacing: 10, // ระยะห่างแนวตั้ง
                                crossAxisSpacing: 10, // ระยะห่างแนวนอน
                                childAspectRatio: 0.8, // อัตราส่วนของแต่ละไอเทม
                              ),
                              itemBuilder: (context, index) {
                                final product = products_detergent[index];
                                var image = product['image'];
                                var parsedImageList = json.decode(image);
                                String imageUrl = "";
                                if (parsedImageList is List &&
                                    parsedImageList.isNotEmpty) {
                                  imageUrl = parsedImageList[0];
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            height: 120,
                                            width: 120,
                                            // fit: BoxFit.cover,
                                          ),
                                          if (double.parse(product['number']) ==
                                              0)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                child: Center(
                                                  child: Text(
                                                    'สินค้าหมด',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                8), // กำหนด margin ซ้ายและขวาเป็น 5
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 1),
                                        decoration: BoxDecoration(
                                          color:
                                              Color(0xFFD384B1), // สีพื้นหลัง
                                          borderRadius: BorderRadius.circular(
                                              4), // การทำให้มุมของพื้นหลังโค้ง
                                        ),
                                        child: Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow
                                              .ellipsis, // เมื่อข้อความยาวเกินให้แสดงเป็น "..."
                                          maxLines:
                                              1, // จำกัดให้แสดงได้เพียงบรรทัดเดียว
                                        ),
                                      ),

                                      SizedBox(height: 0),
                                      Text(
                                        '${product['price']} บาท',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      // Spacer(),
                                      if (double.parse(product['number']) > 0)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.remove,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    saveOrderToSharedPreferences22();
                                                    if (product['quantity'] ==
                                                        null) {
                                                      product['quantity'] = 0;
                                                    }
                                                    // ลดจำนวนสินค้า
                                                    if (product['quantity'] >
                                                        0) {
                                                      product['quantity']--;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            Text(
                                              '${product['quantity'] ?? 0}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.green,
                                              ),
                                              onPressed: () {
                                                saveOrderToSharedPreferences22();
                                                setState(() {
                                                  if (product['quantity'] ==
                                                      null) {
                                                    product['quantity'] = 0;
                                                  }
                                                  // เพิ่มจำนวนสินค้า
                                                  product['quantity']++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (_progress > 0.2 && _progress < 0.3)
                        Column(
                          children: [
                            Text(
                              'น้ำยาปรับผ้านุ่ม',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products_softener.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // จำนวนคอลัมน์
                                mainAxisSpacing: 10, // ระยะห่างแนวตั้ง
                                crossAxisSpacing: 10, // ระยะห่างแนวนอน
                                childAspectRatio: 0.8, // อัตราส่วนของแต่ละไอเทม
                              ),
                              itemBuilder: (context, index) {
                                final product = products_softener[index];
                                var image = product['image'];
                                var parsedImageList = json.decode(image);
                                String imageUrl = "";
                                if (parsedImageList is List &&
                                    parsedImageList.isNotEmpty) {
                                  imageUrl = parsedImageList[0];
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10),
                                      Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            height: 120,
                                            width: 120,
                                            // fit: BoxFit.cover,
                                          ),
                                          if (double.parse(product['number']) ==
                                              0)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                child: Center(
                                                  child: Text(
                                                    'สินค้าหมด',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                8), // กำหนด margin ซ้ายและขวาเป็น 5
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 1),
                                        decoration: BoxDecoration(
                                          color:
                                              Color(0xFFD384B1), // สีพื้นหลัง
                                          borderRadius: BorderRadius.circular(
                                              4), // การทำให้มุมของพื้นหลังโค้ง
                                        ),
                                        child: Text(
                                          product['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow
                                              .ellipsis, // เมื่อข้อความยาวเกินให้แสดงเป็น "..."
                                          maxLines:
                                              1, // จำกัดให้แสดงได้เพียงบรรทัดเดียว
                                        ),
                                      ),

                                      SizedBox(height: 0),
                                      Text(
                                        '${product['price']} บาท',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      // Spacer(),
                                      if (double.parse(product['number']) > 0)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.remove,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    saveOrderToSharedPreferences22();
                                                    if (product['quantity'] ==
                                                        null) {
                                                      product['quantity'] = 0;
                                                    }
                                                    // ลดจำนวนสินค้า
                                                    if (product['quantity'] >
                                                        0) {
                                                      product['quantity']--;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            Text(
                                              '${product['quantity'] ?? 0}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add,
                                                color: Colors.green,
                                              ),
                                              onPressed: () {
                                                saveOrderToSharedPreferences22();
                                                setState(() {
                                                  if (product['quantity'] ==
                                                      null) {
                                                    product['quantity'] = 0;
                                                  }
                                                  // เพิ่มจำนวนสินค้า
                                                  product['quantity']++;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (_progress > 0.3 && _progress < 0.4)
                        Column(
                          children: [
                            Text(
                              'ขนาดเครื่องซักผ้า',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products_washing.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, index) {
                                final product = products_washing[index];
                                var image = product['image'];
                                var parsedImageList = json.decode(image);
                                String imageUrl = "";
                                if (parsedImageList is List &&
                                    parsedImageList.isNotEmpty) {
                                  imageUrl = parsedImageList[0];
                                }
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedValueWash = index;
                                      print(index);

                                      // ตั้งค่า quantity เป็น 1 เมื่อเลือกสินค้า
                                      products_washing[index]['quantity'] = 1;

                                      // เรียกใช้ฟังก์ชันเพื่อบันทึกข้อมูลคำสั่งซื้อ
                                      saveOrderToSharedPreferences22(); // เพิ่มการเรียกฟังก์ชันนี้หลังจากการเลือกสินค้า
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedValueWash == index
                                          ? Colors.blue.shade50
                                          : Colors.white,
                                      border: Border.all(
                                        color: _selectedValueWash == index
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedValueWash == index
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(
                                                    0.3), // เงาสีฟ้าเบาๆ
                                                spreadRadius: 0,
                                                blurRadius: 6,
                                                offset: Offset(
                                                    0, 1), // เงาจะอยู่ใต้
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 10),
                                        Stack(
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            if (product['number'] == 0)
                                              Positioned.fill(
                                                child: Container(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  child: Center(
                                                    child: Text(
                                                      'สินค้าหมด',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Icon(
                                                _selectedValueWash == index
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _selectedValueWash == index
                                                        ? Colors.blue
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF73ADDD),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            product['name'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(height: 0),
                                        Text(
                                          '${product['price']} บาท',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (_progress > 0.4 && _progress < 0.5)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Image.asset(
                              'assets/images/water2.png',
                            ),
                            const SizedBox(height: 32),
                            Column(
                              children: products_temperature.map((product) {
                                // ตัดคำที่ใช้เป็นชื่ออุณหภูมิ
                                String temperatureKey =
                                    product['code']; // ใช้ code แทน

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      print("Tapped!");
                                      _selectedTemperature =
                                          temperatureKey; // เมื่อคลิกที่ตัวเลือก จะเลือก code ของผลิตภัณฑ์
                                      saveOrderToSharedPreferencestemperature(); // บันทึกข้อมูลลงใน SharedPreferences
                                    });
                                  },
                                  child: _buildRadioOption(temperatureKey,
                                      product['name'], product['price']),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      if (_progress > 0.5 && _progress < 0.6)
                        Column(
                          children: [
                            Text(
                              'ขนาดเครื่องอบผ้า',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products_dryer.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.7,
                              ),
                              itemBuilder: (context, index) {
                                final product = products_dryer[index];
                                var image = product['image'];
                                var parsedImageList = json.decode(image);
                                String imageUrl = "";
                                if (parsedImageList is List &&
                                    parsedImageList.isNotEmpty) {
                                  imageUrl = parsedImageList[0];
                                }
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedValueDryer = index;
                                      print(index);

                                      // ตั้งค่า quantity เป็น 1 เมื่อเลือกสินค้า
                                      products_dryer[index]['quantity'] = 1;

                                      // เรียกใช้ฟังก์ชันเพื่อบันทึกข้อมูลคำสั่งซื้อ
                                      saveOrderToSharedPreferences22(); // เพิ่มการเรียกฟังก์ชันนี้หลังจากการเลือกสินค้า
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedValueDryer == index
                                          ? Colors.blue.shade50
                                          : Colors.white,
                                      border: Border.all(
                                        color: _selectedValueDryer == index
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: _selectedValueDryer == index
                                          ? [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(
                                                    0.3), // เงาสีฟ้าเบาๆ
                                                spreadRadius: 0,
                                                blurRadius: 6,
                                                offset: Offset(
                                                    0, 1), // เงาจะอยู่ใต้
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 10),
                                        Stack(
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              height: 200,
                                              fit: BoxFit.cover,
                                            ),
                                            if (product['number'] == 0)
                                              Positioned.fill(
                                                child: Container(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  child: Center(
                                                    child: Text(
                                                      'สินค้าหมด',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Icon(
                                                _selectedValueDryer == index
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                color:
                                                    _selectedValueDryer == index
                                                        ? Colors.blue
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF73ADDD),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            product['name'],
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        SizedBox(height: 0),
                                        Text(
                                          '${product['price']} บาท',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      if (_progress > 0.6 && _progress < 0.7)
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/donot.png',
                                    width: 180,
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/images/notop.png',
                                    width: 180,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 0),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: const Text(
                                      'หลังจากซัก-อบเสร็จแล้ว ก่อนนำส่งคืน ทางร้านมีบริการพับผ้าให้ฟรี ไม่มีค่าใช้จ่าย หากไม่ต้องการให้พับผ้า สามารถพิมพ์แจ้งไว้ที่หมายเหตุได้เลยครับ หรือหากลูกค้าต้องการให้นำใส่ไม้แขวน สามารถใส่ไม้แขวนมากับตระกร้าก่อนส่งซักได้ครับ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _hintController,
                                    decoration: const InputDecoration(
                                      hintText: 'ไม่จำเป็นต้องระบุ',
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: const Text(
                                      'หมายเหตุถึงคนขับ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      hintText: 'เช่น (วางตะกร้าไว้หน้าบ้าน)',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (_progress > 0.7 && _progress < 0.8)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // รูปภาพของตะกร้าเสื้อผ้า
                            Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/teka.png', // แก้ path ให้ตรงกับรูปภาพของคุณ
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'ถ่ายภาพตะกร้าเสื้อผ้า',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // ปุ่มอัปโหลดไฟล์
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 0),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: เพิ่มฟังก์ชันสำหรับเลือกไฟล์
                                  },
                                  icon: const Icon(
                                    Icons.upload_file,
                                    color:
                                        Colors.white, // เปลี่ยนสีไอคอนเป็นสีขาว
                                  ),
                                  label: const Text('Choose File',
                                      style:
                                          TextStyle(color: Color(0xFFFFFFFF))),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('No file chosen',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      if (_progress > 0.8 && _progress < 0.9)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // รูปภาพของตะกร้าเสื้อผ้า
                            Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/teka.png', // แก้ path ให้ตรงกับรูปภาพของคุณ
                                    height: 250,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      SizedBox(height: 40),
                      Container(
                        height: 10.0, // ความสูงของ Progress Bar
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              56, 255, 193, 92), // สีพื้นหลัง
                          border: Border.all(
                            color:
                                const Color.fromARGB(4, 255, 193, 92), // สีขอบ
                            width: 1.0, // ความหนาของขอบ
                          ),
                          borderRadius:
                              BorderRadius.circular(5.0), // มุมโค้งของขอบ
                        ),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors
                              .transparent, // ใช้เป็นโปร่งใสเพื่อไม่ให้ทับสีพื้นหลัง
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFFC15C)),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_progress > 0.1) {
                                    _progress -= 0.1;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'ย้อนกลับ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (_progress < 1.0) {
                                    _progress += 0.1;
                                  }
                                  print("ขั้นตอน: $_progress");
                                  print("คุณเลือก: $selectedItem");

                                  if (_progress == 0.71) {
                                    _saveData(); // บันทึกข้อมูลเมื่อกดปุ่ม
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('ข้อมูลถูกบันทึกแล้ว')),
                                    );
                                  }
                                  if (_progress > 0.80) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TotalOrder()),
                                    );
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFFC15C),
                                padding: EdgeInsets.symmetric(vertical: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'ถัดไป',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile({
    required String imageAsset,
    required String label,
    required int value,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedValue = value;
        });
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: _selectedValue == value ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: _selectedValue == value ? Colors.blue : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: Icon(
                    _selectedValue == value
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _selectedValue == value ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value, String label, String price) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedTemperature,
          onChanged: (String? newValue) {
            setState(() {
              _selectedTemperature = newValue;
              saveOrderToSharedPreferencestemperature();
            });
          },
          activeColor: _selectedTemperature == value
              ? Color(0xFF73ADDD) // สีของช่องติ๊กเมื่อเลือก
              : Colors.grey, // สีของช่องติ๊กเมื่อไม่เลือก
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedTemperature = value; // เมื่อคลิกที่ข้อความให้เลือกค่า
              saveOrderToSharedPreferencestemperature();
            });
          },
          child: Text(
            "$label", // แสดงชื่อสินค้าและราคา
            style: TextStyle(
              color: _selectedTemperature == value
                  ? Color(0xFF73ADDD) // สีข้อความที่เลือก
                  : Colors.black, // สีข้อความที่ไม่ได้เลือก
              fontWeight: _selectedTemperature == value
                  ? FontWeight.bold
                  : FontWeight.normal, // ทำให้ข้อความตัวหนาเมื่อเลือก
            ),
          ),
        ),
      ],
    );
  }

  // บันทึกข้อมูลลง SharedPreferences
  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('hintText', _hintController.text);
    prefs.setString('noteText', _noteController.text);
  }

  // โหลดข้อมูลจาก SharedPreferences
  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hintController.text = prefs.getString('hintText') ?? '';
      _noteController.text = prefs.getString('noteText') ?? '';
      Set<String> keys = prefs.getKeys();
      for (String key in keys) {
        var value = prefs.get(key); // ดึงค่าของคีย์นั้นๆ
        print('Key: $key, Value: $value');
      }
    });
  }

  // ฟังก์ชันในการบันทึกข้อมูลลงใน SharedPreferences
  void saveOrderToSharedPreferencestemperature() async {
    List<Map<String, dynamic>> orderData = [];
    // อ่านข้อมูลจาก SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingData = prefs.getString('order');
    if (existingData != null) {
      // หากมีข้อมูลเก่า ให้ทำการ decode ข้อมูล JSON
      List<dynamic> existingOrderData = json.decode(existingData);
      orderData = List<Map<String, dynamic>>.from(existingOrderData);
    }

    // ลบสินค้าที่มี type == 'temperature' ออกก่อน
    orderData.removeWhere((product) => product['type'] == 'temperature');

    // เพิ่มสินค้าที่เลือกใหม่เข้าไปใน orderData
    if (_selectedTemperature != null) {
      try {
        print('Selected product code: $_selectedTemperature');
        // ค้นหาผลิตภัณฑ์ที่ตรงกับ code ของ _selectedTemperature
        var selectedProduct = products_temperature.firstWhere(
          (product) =>
              product['code'] ==
              _selectedTemperature, // ใช้ code ในการค้นหาผลิตภัณฑ์
        );

        // เพิ่มสินค้าที่เลือกลงใน orderData
        orderData.add({
          'code': selectedProduct['code'],
          'id': selectedProduct['id'],
          'name': selectedProduct['name'],
          'price': selectedProduct['price'],
          'quantity': 1,
          'image': selectedProduct['image'],
          'type': selectedProduct['type'],
        });
      } catch (e) {
        // ถ้าไม่พบสินค้า ให้แสดงข้อความ error
        print("Error: ${e.toString()}");
      }
    }

    // บันทึกข้อมูลใหม่ลงใน SharedPreferences
    String encodedData = json.encode(orderData);
    await prefs.setString('order', encodedData);
    print('Order saved/updated: $encodedData');
  }

  void saveOrderToSharedPreferences22() async {
    List<Map<String, dynamic>> orderData = [];
    // อ่านข้อมูลจาก SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingData = prefs.getString('order');
    if (existingData != null) {
      // หากมีข้อมูลเก่า ให้ทำการ decode ข้อมูล JSON
      List<dynamic> existingOrderData = json.decode(existingData);
      orderData = List<Map<String, dynamic>>.from(existingOrderData);
    }
    // สมมุติว่าเราเก็บข้อมูลสินค้าที่เลือกในตัวแปร products_detergent
    for (var detergent in products_detergent) {
      // ตรวจสอบว่า quantity มากกว่าศูนย์ก่อนเก็บ
      if (detergent['quantity'] != null && detergent['quantity'] > 0) {
        bool isProductExist = false;
        // ตรวจสอบว่า product นี้มีอยู่แล้วใน orderData หรือไม่
        for (var existingProduct in orderData) {
          if (existingProduct['code'] == detergent['code']) {
            // หากพบให้ทำการอัปเดต quantity
            existingProduct['quantity'] = detergent['quantity'];
            isProductExist = true;
            break;
          }
        }
        // หากยังไม่พบสินค้านั้น ให้เพิ่มสินค้าใหม่
        if (!isProductExist) {
          orderData.add({
            'code': detergent['code'],
            'id': detergent['id'],
            'name': detergent['name'],
            'price': detergent['price'],
            'quantity': detergent['quantity'],
            'image': detergent['image'],
          });
        }
      } else {
        // ถ้า quantity เป็น 0 ให้ไม่ลบสินค้า แต่ทำการบันทึก quantity เป็น 0
        for (var existingProduct in orderData) {
          if (existingProduct['code'] == detergent['code']) {
            // อัปเดต quantity ให้เป็น 0
            existingProduct['quantity'] = 0;
            break;
          }
        }
      }
    }

    for (var softener in products_softener) {
      if (softener['quantity'] != null && softener['quantity'] > 0) {
        bool isProductExist = false;
        for (var existingProduct in orderData) {
          if (existingProduct['code'] == softener['code']) {
            existingProduct['quantity'] = softener['quantity'];
            isProductExist = true;
            break;
          }
        }
        if (!isProductExist) {
          orderData.add({
            'code': softener['code'],
            'id': softener['id'],
            'name': softener['name'],
            'price': softener['price'],
            'quantity': softener['quantity'],
            'image': softener['image'],
          });
        }
      } else {
        for (var existingProduct in orderData) {
          if (existingProduct['code'] == softener['code']) {
            existingProduct['quantity'] = 0;
            break;
          }
        }
      }
    }

    for (var washing in products_washing) {
      if (washing['quantity'] != null && washing['quantity'] > 0) {
        bool isProductExist = false;
        for (var existingProduct in orderData) {
          if (existingProduct['type'] == 'washing') {
            orderData.removeWhere((product) => product['type'] == 'washing');
            isProductExist = true;
            break;
          }
        }
        orderData.add({
          'code': washing['code'],
          'id': washing['id'],
          'name': washing['name'],
          'price': washing['price'],
          'quantity': 1,
          'image': washing['image'],
          'type': washing['type'],
        });
      } else {
        for (var existingProduct in orderData) {
          if (existingProduct['type'] == washing['type']) {
            existingProduct['quantity'] = 0;
            break;
          }
        }
      }
    }

    for (var temperature in products_temperature) {
      orderData.removeWhere((product) => product['type'] == 'temperature');

      if (temperature['quantity'] != null && temperature['quantity'] > 0) {
        bool isProductExist = false;
        for (var existingProduct in orderData) {
          if (existingProduct['type'] == 'temperature' &&
              existingProduct['code'] == temperature['code']) {
            existingProduct['quantity'] = 1;
            isProductExist = true;
            break;
          }
        }
        if (!isProductExist) {
          orderData.add({
            'code': temperature['code'],
            'id': temperature['id'],
            'name': temperature['name'],
            'price': temperature['price'],
            'quantity': 1,
            'image': temperature['image'],
            'type': 'temperature',
          });
        }
      } else {
        for (var existingProduct in orderData) {
          if (existingProduct['type'] == 'temperature' &&
              existingProduct['code'] == temperature['code']) {
            existingProduct['quantity'] = 0;
            break;
          }
        }
      }
    }

    for (var dryer in products_dryer) {
      if (dryer['quantity'] != null && dryer['quantity'] > 0) {
        print('Dryer: $dryer');
        bool isProductExist = false;

        // หาตัวแรกที่มี type เป็น 'dryer' และลบมันออก
        var existingProduct = orderData.firstWhere(
            (product) => product['type'] == 'dryer',
            orElse: () => {} // ใช้ Map ว่างแทนการคืนค่า null
            );

        if (existingProduct.isNotEmpty) {
          orderData.remove(existingProduct); // ลบเฉพาะตัวแรกที่พบ
          isProductExist = true;
        }

        orderData.add({
          'code': dryer['code'],
          'id': dryer['id'],
          'name': dryer['name'],
          'price': dryer['price'],
          'quantity': 1,
          'image': dryer['image'],
          'type': dryer['type'],
        });
      } else {
        for (var existingProduct in orderData) {
          if (existingProduct['type'] == dryer['type']) {
            existingProduct['quantity'] = 0;
            break;
          }
        }
      }
    }

    // บันทึกข้อมูลใหม่ลงใน SharedPreferences
    String encodedData = json.encode(orderData);
    await prefs.setString('order', encodedData);
    print('Order saved/updated: $encodedData');
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("กรุณาเลือก"),
          content: Text("กรุณาเลือกรายการซักก่อนดำเนินการ"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("ปิด"),
            ),
          ],
        );
      },
    );
  }

  void _prefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> keys = prefs.getKeys();
    // ลูปแสดงข้อมูลทั้งหมด
    for (String key in keys) {
      var value = prefs.get(key); // ดึงค่าของคีย์นั้นๆ
      print('Key: $key, Value: $value');
    }
  }
}
