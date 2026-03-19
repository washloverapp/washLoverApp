import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
// import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Oders/API/api_sendwash.dart';
import 'package:my_flutter_mapwash/Oders/address_user.dart';
import 'package:my_flutter_mapwash/Oders/location_helper.dart';
import 'package:my_flutter_mapwash/Oders/screens/laundry_customization_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_mapwash/Oders/utils/laundry_pref_helper.dart';
import 'package:my_flutter_mapwash/Status/API/api_status.dart';
// import 'package:my_flutter_mapwash/Oders/total_order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sendwash extends StatefulWidget {
  const sendwash({super.key});

  @override
  _sendwashState createState() => _sendwashState();
}

class _sendwashState extends State<sendwash> {
  String? selectedType;
  Map<String, dynamic>? _selectedType;
  TextEditingController noteController = TextEditingController();
  final PageController _pageController = PageController();
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

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedType();
    _loadStatus();
    _geoLocator();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSavedType() async {
    final type = await LaundryPrefHelper.loadLaundryType();
    if (type != null) {
      setState(() => selectedType = type);
    }
  }

  Future<void> _loadStatus() async {
    try {
      List<dynamic> data = await api_status.fetchstatus();
      final filtered = data.where((e) => e['status'] == 1).toList();

      print('_loadStatus: ${filtered.isNotEmpty ? filtered[0]['status'] : 'no data'}');

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
          String cleaned = latlngString.replaceAll("LatLng(", "").replaceAll(")", "");
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
    List<Map<String, dynamic>> clothingTypes = API_sendwash().getClothingTypes();
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
                    selectedAddress.isNotEmpty ? selectedAddress : 'กำลังค้นหาตำแหน่ง...',
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
              bool isSelected = selectedOptions['clothingType'] == item['value'];
              return GestureDetector(
                onTap: () async {
                  final value = item['value'];

                  setState(() {
                    selectedOptions['clothingType'] = value;
                    if (value == 1) {
                      selectedType = 'clothes';
                    } else if (value == 2) {
                      selectedType = 'bedding';
                    }
                    _selectedType = item;
                  });

                  if (selectedType != null) {
                    await LaundryPrefHelper.saveLaundryType(selectedType!);
                  }
                },

                // onTap: () {
                //   setState(() {
                //     selectedOptions['clothingType'] = item['value'];
                //     if (selectedOptions['clothingType'] == '1') {
                //       selectedType = 'clothes';
                //     }
                //     if (selectedOptions['clothingType'] == '2') {
                //       selectedType = 'bedding';
                //     }
                //   });
                // },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.blue : const Color.fromARGB(255, 227, 227, 227),
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
                              aspectRatio: 4 / 3, // ✅ กำหนดอัตราส่วนภาพให้เหมาะสม
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                            Icon(Icons.water_drop_sharp, color: Colors.blue[200], size: 16),
                            SizedBox(width: 4),
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
          ),
        ),
      ],
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
          closestBranch == 'ไม่พบสาขาที่ใกล้ที่สุด' ? 'ค้นหาสาขาที่ใกล้ที่สุด' : 'เลือกรายการซัก',
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
              ],
            ),
      bottomNavigationBar: closestBranch == 'ไม่พบสาขาที่ใกล้ที่สุด'
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('ย้อนกลับ'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedType != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LaundryCustomizationPage(
                                    laundryType: _selectedType!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFC15C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[500],
                      ),
                      child: const Text('ถัดไป'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
