import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
// import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Oders/API/api_sendwash.dart';
import 'package:my_flutter_mapwash/Oders/API/api_saveorder.dart';
import 'package:my_flutter_mapwash/Oders/address_user.dart';
import 'package:my_flutter_mapwash/Oders/location_helper.dart';
import 'package:my_flutter_mapwash/Oders/totalOrder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_mapwash/Status/API/api_status.dart';
// import 'package:my_flutter_mapwash/Oders/total_order.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
    'washing': '',
    'temperature': '',
    'dryer': '',
    'note': '',
    'basketImage': '',
  };
  String closestBranch = 'กำลังค้นหาสาขาที่ใกล้ที่สุด...';
  String codeBranch = '';
  bool isLoading = true; // สถานะการโหลด
  String selectedAddress = ''; // ✅ ตัวแปรที่อยู่
  LatLng? selectedLatLng; // ✅ ตัวแปรพิกัด (nullable)


  String mapType(String type) {
    if (type == 'detergent') return 'detergent';
    if (type == 'softener') return 'softener';
    if (type == 'washing') return 'washing';
    if (type == 'temperature') return 'temperature';
    if (type == 'dryer') return 'dryer';
    return type;
  }


  List<Map<String, dynamic>> detergentOptions = [];
  List<Map<String, dynamic>> softenerOptions = [];
  List<Map<String, dynamic>> washingOptions = [];
  List<Map<String, dynamic>> temperatureOptions = [];
  List<Map<String, dynamic>> dryerOptions = [];


  bool loading = true;


  Future<void> loadOptions() async {
    detergentOptions = await API_sendwash.getDefaultOptions('detergent');
    softenerOptions = await API_sendwash.getDefaultOptions('softener');
    washingOptions = await API_sendwash.getDefaultOptions('washing');
    temperatureOptions = await API_sendwash.getDefaultOptions('temperature');
    dryerOptions = await API_sendwash.getDefaultOptions('dryer');
    if (!mounted) return;
    setState(() => loading = false);
  }


  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selection', json.encode(selectedOptions));
  }


  @override
  void initState() {
    super.initState();
    _loadStatus();
    _geoLocator();
    loadOptions();
  }


  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _loadStatus() async {
    try {
      List<dynamic> data = await api_status.fetchstatus();
      final filtered = data.where((e) => e['status'] == 1).toList();


      print(
          '_loadStatus: ${filtered.isNotEmpty ? filtered[0]['status'] : 'no data'}');


      if (filtered.isNotEmpty) {
        if (!mounted) return;
        MainLayout.initialIndex = 4;
        // 🔥 1. แสดง AlertDialog
        await showDialog(
          context: context,
          barrierDismissible: true, // ห้ามกดนอกปิด
          builder: (context) {
            return AlertDialog(
              title: const Text("แจ้งเตือน"),
              content: const Text(
                  "พบออเดอร์ที่ยังรอพนังงานรับผ้าของท่าน\nหรือลบออกเดร์ของท่านและเลือกรายการใหม่\nรอพนักงานของเราไปรับผ้าของคุณ"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainLayout()),
                    (Route<dynamic> route) => false,
                  ),
                  child: const Text("ตกลง"),
                ),
              ],
            );
          },
        );


        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Error loading status: $e');
    }
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
      _saveSelection();
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
      _saveSelection();
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


  void _updateQuantity(
    String key,
    String itemId,
    int change,
  ) {
    setState(() {
      selectedOptions.putIfAbsent(key, () => {});


      // เลือกได้หลายตัว
      selectedOptions[key]!.putIfAbsent(itemId, () => 0);
      int currentQuantity = selectedOptions[key]![itemId] ?? 0;
      int newQuantity = (currentQuantity + change).clamp(0, 99);


      if (newQuantity == 0) {
        selectedOptions[key]!.remove(itemId);
      } else {
        selectedOptions[key]![itemId] = newQuantity;
      }
    });
  }


  Future<void> _geoLocator() async {
    try {
      final result = await location_helper.getCurrentLocationUser();
      final prefs = await SharedPreferences.getInstance();
      if (result != null) {
        setState(() {
          selectedAddress = result['address'];
          selectedLatLng = result['latlng'];
        });
        double lat;
        double lng;
        if (result['latlng'] is String) {
          String latlngString = result['latlng'];
          String cleaned =
              latlngString.replaceAll("LatLng(", "").replaceAll(")", "");
          List<String> parts = cleaned.split(',');
          lat = double.parse(parts[0]);
          lng = double.parse(parts[1]);
        } else {
          lat = result['latlng'].latitude;
          lng = result['latlng'].longitude;
        }
        await prefs.setDouble('lat', lat);
        await prefs.setDouble('lng', lng);
      } else {
        print("⚠️ ไม่พบข้อมูลจาก location_helper");
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดใน _geoLocator: $e");
    }
  }


  Widget _buildClothingType() {
    // ✅ ดึงข้อมูลประเภทเสื้อผ้า
    List<Map<String, dynamic>> clothingTypes =
        API_sendwash().getClothingTypes();
    return Column(
      children: [
        // ✅ ที่อยู่ (GestureDetector)
        GestureDetector(
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => address_user(
                  onLocationPicked: (String address, LatLng location) {
                    setState(() {
                      selectedAddress = address;
                      selectedLatLng = location;
                    });
                  },
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedAddress.isNotEmpty
                        ? selectedAddress
                        : 'กำลังค้นหาตำแหน่ง...',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[200]),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
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
              bool isSelected =
                  selectedOptions['clothingType'] == item['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOptions['clothingType'] = item['value'];
                  });
                  // List<Map<String, dynamic>> items = [item];
                  // APICartSet.sendCartToSet(items);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: AspectRatio(
                              aspectRatio:
                                  4 / 3, // ✅ กำหนดอัตราส่วนภาพให้เหมาะสม
                              child: Image.asset(
                                item['image'],
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
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
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    if (item['text'] != '1')
                      Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.water_drop_sharp,
                                color: Colors.blue[200], size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                closestBranch,
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
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
          ),
        ),
      ],
    );
  }


  Widget _buildDetergentSoftenerList(String type, String key) {
    String apiType = mapType(type);
    List<Map<String, dynamic>> options = _items
        .where((item) => item['type'] == apiType)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    if (options.isEmpty) {
      if (apiType == 'detergent') {
        options = detergentOptions;
      } else if (apiType == 'softener') {
        options = softenerOptions;
      }
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
                          margin: EdgeInsets.only(left: 0),
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


  Map<String, dynamic> selectedItems = {}; // เก็บ item ที่เลือก


  Widget _buildOptionList(String type, String key) {
    String apiType = mapType(type);
    List<Map<String, dynamic>> options = _items
        .where((item) => item['type'] == apiType)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
    // if (options.isEmpty) {
    if (apiType == 'washing') {
      options = washingOptions;
    } else if (apiType == 'dryer') {
      options = dryerOptions;
    } else if (apiType == 'temperature') {
      options = temperatureOptions;
    }
    // }
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
          onTap: () {
            setState(() {
              selectedOptions['washingMachine'] = item['value'];
              selectedOptions[key] = item['id'];
              selectedItems[item['id']] = item;
            });
            // List<Map<String, dynamic>> items = [item];
            // APICartSet.sendCartToSet(items);
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
                  padding: const EdgeInsets.all(0.0),
                  child: Text(
                    item['detail'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
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
              // List<Map<String, dynamic>> items = [selectedOptions];
              // APICartSet.sendCartToSet(items);
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
                  _buildOptionList('washing', 'washing'),
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



