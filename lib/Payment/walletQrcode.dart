import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Payment/PaymentFail.dart';
import 'package:my_flutter_mapwash/Payment/PaymentSuccess.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Qrcode extends StatefulWidget {
  @override
  _QrcodeState createState() => _QrcodeState();
}

const List<Color> _kDefaultRainbowColors = const [
  Colors.blue,
];

class _QrcodeState extends State<Qrcode> {
  String displayMessageStatus = "กำลังดำเนินการ";
  String urlLink = "";
  String idWorking = "";
  String amount = "";
  String detail = "";
  String username = "";
  String image = "";
  String status = "";
  String ref = "";
  String dateStr = "";
  String endtime = "";
  String endtimeCount = "";
  String promotionPrice = "";
  String refID = "";
  String ID = "";
  int _remainingSeconds = 29 * 60;
  List<Map<String, dynamic>> addressuser = [];
  List<Map<String, dynamic>> Branch = [];
  late Timer _timer;
  String payment = '';
  List<Map<String, dynamic>> Conferm_Oder = [];
  List<Map<String, dynamic>> jsonData = [];

  @override
  void initState() {
    super.initState();
    fetchQrcode();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _showSingleAnimationDialog(Indicator indicator, bool showPathBackground) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: false,
          builder: (ctx) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(64),
                child: Center(
                  child: LoadingIndicator(
                    indicatorType: indicator,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    pathBackgroundColor:
                        showPathBackground ? Colors.black45 : null,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Future<void> saveUserData(String idWorking) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('idWorking', idWorking);
  }

  Future<void> SaveSPFID(String SPFID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('SPFID', SPFID);
  }

  Future<String?> convertedSelectedOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('convertedSelectedOptions');
  }

  Future<void> removeConvertedSelectedOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('convertedSelectedOptions');
  }

  Future<String?> _getPhonePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  String _generateRandomString(int length) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    Random rand = Random();
    String randomString = '';
    for (int i = 0; i < length; i++) {
      if (i % 2 == 0) {
        randomString += letters[rand.nextInt(letters.length)];
      } else {
        randomString += digits[rand.nextInt(digits.length)];
      }
    }
    return randomString;
  }

  Future<String?> GetSPFID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('SPFID');
  }

  Future<void> ConfirmOrder(
    String idWorking,
    String amount,
    String detail,
    String username,
    String image,
    List<Map<String, dynamic>> addressuser,
    List<Map<String, dynamic>> addressBranch,
    String promotionPrice,
    String payment,
    BuildContext context,
  ) async {
    if (idWorking == '') {
      return;
    }
    print('coupon received in ConfirmOrder: $promotionPrice');
    saveUserData(idWorking);
    double value = double.tryParse(amount) ?? 0.0;
    if (value < 0) value = 0;

// 3) แปลงกลับเป็น String (ถ้าอยากทศนิยม 2 ตำแหน่ง ใช้ toStringAsFixed(2))
    amount = value.toStringAsFixed(2);
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    String? nickName = prefs.getString('name');
    String? converted = await convertedSelectedOptions();
    List<dynamic> loadedData = jsonDecode(converted!);
    List<Map<String, dynamic>> items = [];
    String? noteData;

    if (loadedData.isNotEmpty) {
      var firstItem = loadedData[0];
      if (firstItem['items'] != null) {
        items = List<Map<String, dynamic>>.from(firstItem['items']);
      }

      if (loadedData.length > 1) {
        var secondItem = loadedData[1];
        noteData = secondItem['note'] ?? '';
      }
    }
    if (payment == 'credit') {
      final response = await http.put(
        Uri.parse(
            'https://android-dcbef-default-rtdb.firebaseio.com/order/$username/WL$idWorking.json'),
        body: json.encode({
          'user_location': {
            'address': addressuser[0]['address'],
            'latitude': addressuser[0]['latitude'],
            'longitude': addressuser[0]['longitude'],
            'name': addressuser[0]['name'],
            'detail': addressuser[0]['detail'],
            'phone': addressuser[0]['phone'],
            'note': addressuser[0]['note'],
            'subdistrict': addressuser[0]['subdistrict'],
            'district': addressuser[0]['district'],
            'province': addressuser[0]['province'],
            'postcode': addressuser[0]['postcode'],
          },
          'note': noteData ?? '',
          'datetime': date,
          'code': 'WL$idWorking',
          'price_sum': amount,
          'price_discount': promotionPrice,
          'image': 'https://washlover.com/image/logo.png?v=6',
          'name': nickName,
          'status': 'pending',
          'phone': phone,
          'branch': {
            'code': addressBranch[0]['code'],
            'address': addressBranch[0]['address'],
            'latitude': addressBranch[0]['latitude'],
            'longitude': addressBranch[0]['longitude'],
            'branch': addressBranch[0]['branch'],
            'name': addressBranch[0]['closestBranch'],
          },
          'oder_selects': items,
        }),
      );
      if (response.statusCode == 200) {
        await Future.delayed(Duration(seconds: 2));
      } else {
        throw Exception('Failed to add data');
      }
    }
  }

  Future<void> fetchQrcode() async {
    String getCurrent() {
      DateTime now = DateTime.now();
      String year = now.year.toString().substring(3);
      String month = now.month.toString().padLeft(2, '0');
      String day = now.day.toString().padLeft(2, '0');
      String minute = now.minute.toString().padLeft(2, '0');
      String second = now.second.toString().padLeft(2, '0');
      String randomString = _generateRandomString(5);
      String formattedDate =
          year + month + day + minute + second + randomString;

      return formattedDate;
    }

    username = await _getPhonePreferences() ?? "";
    if (username.isEmpty) {
      print("ไม่พบ username");
      return;
    }
    String randomDate = getCurrent();
    idWorking = randomDate;
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final totalPrice = arguments['totalPrice'];
    final address = arguments['address'];
    final addressBranch = arguments['addressBranch'];
    final coupon = arguments['coupon'];
    final payMent = arguments['payment'];
    promotionPrice = coupon.toString();
    addressuser = address;
    amount = totalPrice;
    Branch = addressBranch;
    String IDWORK = await GetSPFID() ?? "";
    setState(() {
      ID = IDWORK;
      detail = idWorking;
      ref = 'credit';
    });
    print('payCheck : $payMent');
    ConfirmOrder(idWorking, amount, detail, username, image, addressuser,
        Branch, promotionPrice, payMent, context);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    initializeDateFormatting('th_TH', null).then((_) {});
    String formattedDate = DateFormat('d MMMM yyyy, E', 'th_TH').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Details (#WASH112)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.share, color: Colors.pink),
                  ],
                ),
                SizedBox(height: 4),
                Text("$formattedDate", style: TextStyle(color: Colors.grey)),
                Divider(),
                buildInfoRow(
                    "ยูเซอร์", "0987654321", "สถานะ", "กำลังดำเนินการ"),
                buildInfoRow2("เลขอ้างอิง", "wash876fgtgrk4", "จะหมดเวลา",
                    "${_formatTime(_remainingSeconds)} น."),
                buildInfoRow(
                    "รหัสงาน", "#WASH112", "เวลา", "$formattedTime น."),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("จำนวนเงิน:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("฿ 200.00",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                Image.network(
                  image.isNotEmpty
                      ? image
                      : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR41ht1YjdRUgJ5-jhE-ngXzsDARHIuc3JasMHFCvndLApKv12_kRc9yHBm0Mtz5-MPN3U&usqp=CAU',
                  // width: 300,
                  // height: 250,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "คำเตือน : สามารถสแกน QRCODE ได้เพียงครั้งเดียว ห้ามนำกลับมาใช้ซ้ำเด็ดขาด",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButtonCancle(
                        "ยกเลิก", Colors.grey, Colors.black, context),
                    buildButtonSuccess(
                        "โอนสำเร็จ", Colors.lightGreen, Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInfoColumn(label1, value1),
          buildInfoColumn(label2, value2),
        ],
      ),
    );
  }

  Widget buildInfoRow2(
      String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInfoColumn(label1, value1),
          buildInfoColumn2(label2, value2),
        ],
      ),
    );
  }

  Widget buildInfoColumn2(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }

  Widget buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildButtonCancle(
      String text, Color bgColor, Color textColor, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  Widget buildButtonSuccess(String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainLayout(),
          ),
          (Route<dynamic> route) => false, // 🔥 ลบทุกหน้าเก่าทิ้งทั้งหมด
        );
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  // ฟังก์ชันที่ใช้แสดงการแจ้งเตือน

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('รอดำเนินการ...'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดการแจ้งเตือน
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
