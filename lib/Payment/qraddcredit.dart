import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Payment/PaymentFail.dart';
import 'package:my_flutter_mapwash/Payment/PaymentSuccess.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrcodeAddCredit extends StatefulWidget {
  @override
  _QrcodeAddCreditState createState() => _QrcodeAddCreditState();
}

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
                        "โอนสำเร็จ", Colors.lightGreen, Colors.white, context),
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

  Widget buildButtonSuccess(String text, Color bgColor, Color textColor ,BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainLayout()),
          (Route<dynamic> route) => false,
        );
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
