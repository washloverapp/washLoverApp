import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Payment/PaymentFail.dart';
import 'package:my_flutter_mapwash/Payment/PaymentSuccess.dart';
import 'package:my_flutter_mapwash/pages/send_confirm_oder.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrcodeAddCredit extends StatefulWidget {
  @override
  _QrcodeAddCreditState createState() => _QrcodeAddCreditState();
}

const List<Color> _kDefaultRainbowColors = const [
  Colors.blue,
];

class _QrcodeAddCreditState extends State<QrcodeAddCredit> {
  String displayMessageStatus = "รอดำเนินการ...";

  @override
  void initState() {
    super.initState();
    fetchQrcode();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          // fetchAmount();
        }
      });
    });
    Timer.periodic(Duration(seconds: 10), (timer) {
      // CheckPayment();
    });
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

  Future<void> CheckPayment() async {
    String ref_no = refID;
    final url = Uri.parse(
        'https://api.all123th.com/payment-swiftpay/' + ref_no + '?type=json');
    try {
      // ส่ง HTTP GET request ไปยัง URL
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data']['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                amount: amount,
                detail: detail,
                username: username,
                status: status,
                ref: ref,
              ),
            ),
          );
        } else {
          _showErrorDialog(context, 'กรุณาชำระเงิน');
        }
        // if (data['data']['status'] == 'failed') {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PaymentFailScreen(
        //         amount: amount,
        //         detail: detail,
        //         username: username,
        //         status: status,
        //         ref: ref,
        //       ),
        //     ),
        //   );
        // }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error555: $e');
    }
  }

  String urlLink = "";
  String idWorking = "";
  String amount = "";
  String detail = "";
  String username = "";
  String image = "";
  String status = "";
  String ref = "";
  String endtime = "";
  String endtimeCount = "";
  String promotionPrice = "";
  String refID = "";
  int _remainingSeconds = 05 * 60;
  List<Map<String, dynamic>> addressuser = [];
  List<Map<String, dynamic>> Branch = [];
  late Timer _timer;

  Future<void> _saveUrlToPreferences(String url, String refId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('url', url); // เก็บ url เป็น String
    await prefs.setString('refID', refId); // เก็บ url เป็น String
  }

  Future<String?> _getUrlFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('url');
  }

  Future<String?> _getrefIDFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refID');
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
      // สลับกันระหว่างตัวอักษรและตัวเลข
      if (i % 2 == 0) {
        randomString += letters[rand.nextInt(letters.length)]; // ตัวอักษร
      } else {
        randomString += digits[rand.nextInt(digits.length)]; // ตัวเลข
      }
    }

    return randomString;
  }

  Future<void> fetchQrcode() async {
    _showSingleAnimationDialog(Indicator.ballScale, true);
    String getCurrent() {
      DateTime now = DateTime.now(); // ดึงวันที่และเวลาปัจจุบัน
      String year =
          now.year.toString().substring(3); // ปี (เอาแค่ 2 หลักสุดท้าย)
      String month = now.month.toString().padLeft(2, '0'); // เดือน
      String day = now.day.toString().padLeft(2, '0'); // วัน
      String minute = now.minute.toString().padLeft(2, '0'); // นาที
      String second = now.second.toString().padLeft(2, '0'); // วินาที
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
    final arguments = ModalRoute.of(context)?.settings.arguments;
    // String amount = '';
    if (arguments is String) {
      amount = arguments;
      print('Received amount: $amount');
    } else {
      print('Invalid argument format');
    }
    final response = await http.get(Uri.parse(
        'https://merchant.all123th.com/api?amount=$amount&Agent=WASH&username=$username'));

    print('response : $response');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      refID = data['refId'];
      setState(() {
        amount = data['amount'];
        detail = data['ref1'];
        username = data['username'];
        image = data['img'];
        ref = data['ref1'];
      });
      _saveUrlToPreferences(data['url'], data['refId']);
    } else {
      throw Exception('Failed to load data');
    }
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm').format(now);
    if (status == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            amount: amount,
            detail: detail,
            username: username,
            status: status,
            ref: ref,
          ),
        ),
      );
    }

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
                      "Payment Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.share, color: Colors.pink),
                  ],
                ),
                SizedBox(height: 4),
                Divider(),
                buildInfoRow(
                    "ยูเซอร์", "$username", "สถานะ", "$displayMessageStatus"),
                buildInfoRow2("เลขอ้างอิง", "$detail", "จะหมดเวลา",
                    "${_formatTime(_remainingSeconds)} น."),
                buildInfoRow("วันที่", "", "เวลา", "$formattedTime น."),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("จำนวนเงิน:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("฿ $amount",
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
                      : 'https://washlover.com/image/promotion/slid3.png?v=1231',
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
        CheckPayment();
        // if (displayMessageStatus == '"Success"') {
        // } else {
        //   _showErrorDialog(context, 'กรุณาชำระเงิน');
        // }
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
