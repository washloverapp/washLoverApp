import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Oders/API/api_sendwash.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class sendwash extends StatefulWidget {
  const sendwash({super.key});

  @override
  _sendwashState createState() => _sendwashState();
}

class _sendwashState extends State<sendwash> {
  TextEditingController noteController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<dynamic> _items = [];
  Map<String, dynamic> selectedOptions = {
    'clothingType': '',
    'detergent': {},
    'softener': {},
    'washingMachine': '',
    'temperature': '',
    'dryer': '',
    'note': '',
    'basketImage': '',
  };
  String closestBranch = 'กำลังค้นหาสาขาที่ใกล้ที่สุด...';
  String codeBranch = '';
  bool isLoading = true; // สถานะการโหลด
  late Position currentPosition;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // noteController.dispose(); // เมื่อ widget ถูกทิ้ง ให้ทำการลบ controller
    super.dispose();
  }

  bool isImagePickerActive = false;
  Future<void> _pickImage() async {
    if (isImagePickerActive) {
      return;
    }

    final ImagePicker _picker = ImagePicker();
    setState(() {
      isImagePickerActive = true;
    });

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedOptions['basketImage'] = pickedFile.path;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    } finally {
      setState(() {
        isImagePickerActive = false;
      });
    }
  }

  void _nextPage() {
    print(_currentPage);
    if (selectedOptions['clothingType'] == 2) {
      setState(() {});
    }
    if (_currentPage < 8) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage++);
    }
    // กรณีเลือกชุดเครื่องนอน
    if (selectedOptions['clothingType'] == 2 && _currentPage == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TotalOrder()),
      ).then((_) {
        setState(() {
          _currentPage = 4;
        });
        _pageController.jumpToPage(7);
      });
    }
    // เสื้อผ้าปกติ
    if (_currentPage == 8) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TotalOrder()),
      ).then((_) {
        // เมื่อกลับมาจาก TotalOrder ให้รีเซ็ตหน้า
        setState(() {
          _currentPage = 7; // รีเซ็ตไปที่หน้าแรก
        });
        _pageController.jumpToPage(7); // เลื่อนไปหน้าแรก
      });
    }
  }

  void _prevPage() {
    print(_currentPage);
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage--);
    }
  }

  void _updateQuantity(String key, String itemId, int change) {
    setState(() {
      if (!selectedOptions[key].containsKey(itemId)) {
        selectedOptions[key][itemId] = 0;
      }
      int currentQuantity = selectedOptions[key][itemId] is int
          ? selectedOptions[key][itemId]
          : 0;
      selectedOptions[key][itemId] = (currentQuantity + change).clamp(0, 99);
    });
  }

  Widget _buildClothingType() {
    // ✅ เรียกจากไฟล์ api_sendwash.dart
    List<Map<String, dynamic>> clothingTypes =
        API_sendwash().getClothingTypes();
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: clothingTypes.length,
      itemBuilder: (context, index) {
        var item = clothingTypes[index];
        bool isSelected = selectedOptions['clothingType'] == item['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedOptions['clothingType'] = item['value'];
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : const Color.fromARGB(255, 227, 227, 227),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.asset(
                        item['image'],
                        width: 200,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              if (item['text'] != '1')
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop_sharp,
                          color: Colors.blue[200], size: 16),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          closestBranch,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetergentSoftenerList(String type, String key) {
    List<dynamic> options =
        _items.where((item) => item['type'] == type).toList();

    if (options.isEmpty) {
      // เรียกใช้เมท็อดจากคลาส
      options = API_sendwash().getDefaultOptions(type);
    }

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        var item = options[index];
        int quantity = selectedOptions[key]?[item['id']] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: item['image'].toString().startsWith('http')
                    ? Image.network(
                        item['image'],
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        item['image'],
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.only(left: 8),
                          padding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                          decoration: BoxDecoration(
                            color: item['type'] == 'softener'
                                ? Colors.pink[300]
                                : Colors.blue[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '${item['price']} บาท',
                style: TextStyle(color: Colors.green[700], fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color: quantity > 0 ? Colors.red : Colors.grey,
                    ),
                    onPressed: quantity > 0
                        ? () => _updateQuantity(key, item['id'], -1)
                        : null,
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    onPressed: () => _updateQuantity(key, item['id'], 1),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionList(String type, String key) {
    List<dynamic> options =
        _items.where((item) => item['type'] == type).toList();

    if (options.isEmpty) {
      options = API_sendwash().getwashing(type);
    }

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        var item = options[index];
        bool isSelected = selectedOptions[key] == item['id'];

        return GestureDetector(
          onTap: item['id'].toString().startsWith('sample_')
              ? null
              : () {
                  setState(() {
                    selectedOptions[key] = item['id'];
                  });
                },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              border: Border.all(
                color: isSelected
                    ? Colors.blue
                    : const Color.fromARGB(255, 233, 233, 233),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0), // เพิ่ม padding ด้านบน
                    child: item['image'].toString().startsWith('http')
                        ? Image.network(
                            item['image'],
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  '${item['price']} บาท',
                  style: TextStyle(color: Colors.green[700], fontSize: 14),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNote() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "หมายเหตุ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          TextField(
            controller:
                noteController, // ใช้ TextEditingController ที่สร้างขึ้น
            onChanged: (value) {
              setState(() {
                selectedOptions['note'] = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "กรุณาใส่หมายเหตุ",
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBasketImage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "เลือกรูปตระกร้าผ้า",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: selectedOptions['basketImage'] != ''
                  ? Image.file(
                      File(selectedOptions['basketImage']),
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        'เลือกภาพตระกร้าผ้า',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          closestBranch == 'ไม่พบสาขาที่ใกล้ที่สุด'
              ? 'ค้นหาสาขาที่ใกล้ที่สุด'
              : 'เลือกรายการซัก',
          style: TextStyle(
            color: const Color.fromARGB(255, 203, 203, 203),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: closestBranch == 'ไม่พบสาขาที่ใกล้ที่สุด'
          ? Center(
              child: Text(
                closestBranch,
                style: TextStyle(fontSize: 20),
              ),
            )
          : PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildClothingType(),
                if (selectedOptions['clothingType'] != 2) ...[
                  _buildDetergentSoftenerList('detergent', 'detergent'),
                  _buildDetergentSoftenerList('softener', 'softener'),
                  _buildOptionList('washing', 'washingMachine'),
                  _buildOptionList('temperature', 'temperature'),
                  _buildOptionList('dryer', 'dryer'),
                  _buildNote(),
                  _buildBasketImage(),
                ],
                if (selectedOptions['clothingType'] != 1) ...[
                  _buildDetergentSoftenerList('detergent', 'detergent'),
                  _buildDetergentSoftenerList('softener', 'softener'),
                  _buildNote(),
                  _buildBasketImage()
                ],
              ],
            ),
      bottomNavigationBar: closestBranch == 'ไม่พบสาขาที่ใกล้ที่สุด'
          ? null
          : Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _currentPage > 0 ? _prevPage : null,
                    child: Text(
                      "ย้อนกลับ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFC15C),
                      padding: EdgeInsets.symmetric(vertical: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _currentPage < 9 ? _nextPage : null,
                    child: Text(
                      "ถัดไป",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
