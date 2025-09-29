import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class LaundrySelection extends StatefulWidget {
  const LaundrySelection({super.key});

  @override
  _LaundrySelectionState createState() => _LaundrySelectionState();
}

const List<Color> _kDefaultRainbowColors = const [
  Colors.blue,
];

Future<void> printAllSharedPreferencesKeys() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<String> keys = prefs.getKeys();
  print("All keys in SharedPreferences:");
  keys.forEach((key) {
    var value = prefs.get(key);
    print('Key: $key, Value: $value');
  });
}

class _LaundrySelectionState extends State<LaundrySelection> {
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
    // getCurrentLocation();

    loadSavedData();
  }

  @override
  void dispose() {
    // noteController.dispose(); // เมื่อ widget ถูกทิ้ง ให้ทำการลบ controller
    super.dispose();
  }

  // ฟังก์ชันคำนวณระยะทางด้วยสูตร Haversine
  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // รัศมีโลกในหน่วยเมตร
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // ผลลัพธ์เป็นเมตร
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  Future<List<Map<String, dynamic>>> fetchBranches() async {
    final response =
        await http.get(Uri.parse('https://android-dcbef-default-rtdb.firebaseio.com/branch.json'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      print(response.body);
      fetchData(codeBranch);
      if (data['status'] == 'success' && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('ไม่สามารถดึงข้อมูลสาขา');
      }
    } else {
      throw Exception('ไม่สามารถเชื่อมต่อ API');
    }
  }

// ฟังก์ชันหาใกล้ที่สุดที่อยู่ในรัศมี
  Future<String> findClosestBranch(
      Position currentPosition, BuildContext context) async {
    List<Map<String, dynamic>> branches = await fetchBranches();
    double closestDistance = double.infinity;
    closestBranch = 'ไม่พบสาขาที่ใกล้ที่สุด';

    for (var branch in branches) {
      double lat = double.parse(branch['latitude']);
      double lon = double.parse(branch['longitude']);
      double distance = haversineDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        lat,
        lon,
      );

      if (distance <= double.parse(branch['distance'])) {
        // เช็คว่าอยู่ในรัศมีที่กำหนด
        if (distance < closestDistance) {
          closestDistance = distance;
          closestBranch = '${branch['name']}';
          codeBranch = branch['code'];
          print("code : ${branch['code']}");
          fetchData(codeBranch);
        }
      }
    }
    return closestBranch;
  }

  /// ตรวจสอบและขอ permission ก่อน
  Future<Position> _determinePosition() async {
    // 1. service ต้องเปิดอยู่
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error('Location services are disabled.');
    }
    // 2. เช็คสถานะ permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    // 3. ถ้า deniedForever ต้องให้ไปตั้งค่าเอง
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied. Please enable them in Settings.');
    }
    // 4. ถ้าอนุญาตแล้ว ก็ปล่อยให้ getCurrentPosition()
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      // _showSingleAnimationDialog(Indicator.ballScale, true);
      // Position position = await _determinePosition();
      // … ใช้งานตำแหน่งต่อ
      setState(() {
        isLoading = true;
      });
      Position position = await _determinePosition(
          // desiredAccuracy: LocationAccuracy.high,
          );

      setState(() {
        currentPosition = position;
        isLoading = false;
      });

      _findClosestBranch();
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      if (e.toString().contains('permanently')) {
        // แสดงไดอะล็อกพร้อมปุ่มพาไป Settings
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('ต้องการสิทธิ์ตำแหน่ง'),
            content: Text('คุณได้ปฏิเสธการขอสิทธิ์ตำแหน่งแบบถาวรแล้ว\n'
                'กรุณาไปที่ Settings > Privacy & Security > Location Services > MyApp แล้วเปิดเป็น “While Using” หรือ “Always”'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  bool opened = await Geolocator.openAppSettings();
                  if (!opened) {
                    // กรณีเปิด Settings ไม่สำเร็จ
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ไม่สามารถเปิด Settings ได้')));
                  }
                },
                child: Text('ไปที่ Settings'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
            ],
          ),
        );
      } else {
        // จัดการกรณีอื่น ๆ (เช่น denied ปกติ หรือ service ปิด)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ฟังก์ชันหาสาขาที่ใกล้ที่สุด
  Future<void> _findClosestBranch() async {
    String branch = await findClosestBranch(currentPosition, context);
    print('branch : $branch');
    setState(() {
      closestBranch = branch;
    });
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> fetchData(String code) async {
    final response = await http
        .get(Uri.parse('https://washlover.com/api/stock?branch=$code'));
    print(response);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = jsonDecode(response.body)['data'];
      prefs.setString('prefsCODE', code);
      setState(() {
        _items = data.map((item) {
          List<dynamic> imageList = [];
          if (item['image'] != null && item['image'].isNotEmpty) {
            try {
              imageList = jsonDecode(item['image']);
            } catch (e) {
              print("Error parsing image string: $e");
            }
          }

          return {
            'id': item['id'],
            'code': item['code'],
            'name': item['name'],
            'detail': item['detail'],
            'price': item['price'],
            'type': item['type'],
            'image': imageList.isNotEmpty ? imageList[0] : '',
          };
        }).toList();
      });
    }
  }

  Future<void> loadConvertedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('convertedSelectedOptions');
    if (savedData != null) {
      List<dynamic> loadedData = jsonDecode(savedData);
      print(loadedData);
    }
  }

  Future<void> loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('selectedOptions');
    if (savedData != null) {
      setState(() {
        selectedOptions = jsonDecode(savedData);
      });
    }
    print('Loaded selectedOptions: $selectedOptions');
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedOptions', jsonEncode(selectedOptions));
  }

  Future<void> removeSharedSelect(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRemoved = await prefs.remove('convertedSelectedOptions');
    bool isRemoved2 = await prefs.remove('clothingType');
    if (isRemoved && isRemoved2) {
    } else {}
    prefs = await SharedPreferences.getInstance();
    bool isConvertedSelectedOptionsRemoved =
        prefs.getString('convertedSelectedOptions') == null;
    bool isSelectedOptionsRemoved = prefs.getString('selectedOptions') == null;
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
      setState(() {
        removeSharedSelect(context);
      });
    }
    if (_currentPage < 8) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => _currentPage++);
      saveData();
    }
    // กรณีเลือกชุดเครื่องนอน
    if (selectedOptions['clothingType'] == 2 && _currentPage == 5) {
      saveConvertedData();
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
      saveConvertedData();
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
      saveData();
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

  Map<String, dynamic> _convertSelectedOptionsToJson() {
    List<Map<String, dynamic>> items = [];

    const nonItemKeys = {'clothingType', 'note', 'basketImage'};

    selectedOptions.forEach((key, value) {
      if (nonItemKeys.contains(key)) {
        return; // Skip non-item keys
      }

      if (value is Map) {
        // For options with quantities (detergent, softener)
        value.forEach((itemId, quantity) {
          if (quantity is int && quantity > 0) {
            final item = _items.firstWhere((item) => item['id'] == itemId,
                orElse: () => null);
            if (item != null) {
              items.add({
                'id': item['id'],
                'code': item['code'],
                'name': item['name'],
                'detail': item['detail'],
                'price': item['price'],
                'type': item['type'],
                'image': item['image'] ?? '',
                'quantity': quantity,
              });
            }
          }
        });
      } else if (value is String && value.isNotEmpty) {
        // For single-selection options
        final item = _items.firstWhere((item) => item['id'] == value,
            orElse: () => null);
        if (item != null) {
          items.add({
            'id': item['id'],
            'code': item['code'],
            'name': item['name'],
            'detail': item['detail'],
            'price': item['price'],
            'type': item['type'],
            'image': item['image'] ?? '',
            'quantity': 1,
          });
        }
      }
    });

    final Map<String, dynamic> result = {
      'items': items,
    };

    final note = selectedOptions['note'];
    if (note is String && note.isNotEmpty) {
      result['note'] = note;
    }

    return result;
  }

  Future<void> saveConvertedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> convertedData = _convertSelectedOptionsToJson();
    await prefs.setString(
        'convertedSelectedOptions', jsonEncode(convertedData));
    print('data: $convertedData');
  }

  Widget _buildClothingType() {
    List<Map<String, dynamic>> clothingTypes = [
      {
        'image': 'assets/images/pha1.jpg',
        'name': 'เสื้อผ้า',
        'value': 1,
        'quantity': 0,
        'text': '0',
        'price': 0,
      },
      {
        'image': 'assets/images/nuam.png',
        'name': 'ชุดเครื่องนอน/ผ้านวม',
        'value': 2,
        'quantity': 0,
        'text': '1',
        'price': 120,
      },
    ];

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
              print(item['value']);
              print(selectedOptions['clothingType']);
              saveConvertedData();
              removeSharedSelect(context);
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
      options = [
        {
          'id': 'sample_1',
          'name': 'กรุณาเพิ่มจากหลังบ้าน',
          'image': 'assets/images/notag.png',
          'price': 0,
          'type': type,
        },
        {
          'id': 'sample_2',
          'name': 'กรุณาเพิ่มจากหลังบ้าน',
          'image': 'assets/images/notag.png',
          'price': 0,
          'type': type,
        },
        {
          'id': 'sample_3',
          'name': 'กรุณาเพิ่มจากหลังบ้าน',
          'image': 'assets/images/notag.png',
          'price': 0,
          'type': type,
        },
        {
          'id': 'sample_4',
          'name': 'กรุณาเพิ่มจากหลังบ้าน',
          'image': 'assets/images/notag.png',
          'price': 0,
          'type': type,
        },
      ];
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
        int quantity = (selectedOptions[key][item['id']] is int)
            ? selectedOptions[key][item['id']]
            : 0;

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
                    : Image.asset(item['image'],
                        width: 120, height: 120, fit: BoxFit.contain),
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
                    icon: Icon(Icons.remove),
                    onPressed: item['id'].toString().startsWith('sample_')
                        ? null
                        : () => _updateQuantity(key, item['id'], -1),
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: item['id'].toString().startsWith('sample_')
                        ? null
                        : () => _updateQuantity(key, item['id'], 1),
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
      String sampleImage;
      switch (type) {
        case 'washing':
          sampleImage = 'assets/images/sakpa.png';
          break;
        case 'temperature':
          sampleImage = 'assets/images/water01.png';
          break;
        case 'dryer':
          sampleImage = 'assets/images/ooppa2.png';
          break;
        default:
          sampleImage = 'assets/images/notag.png';
      }
      options = List.generate(
          4,
          (index) => {
                'id': 'sample_${index + 1}',
                'name': 'กรุณาเพิ่มจากหลังบ้าน',
                'image': sampleImage,
                'price': 0,
                'type': type,
              });
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
