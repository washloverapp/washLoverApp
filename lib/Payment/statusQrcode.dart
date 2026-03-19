import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusQrcodePage extends StatefulWidget {
  final String deviceId;
  final double totalPrice;
  final String id;

  const StatusQrcodePage({
    Key? key,
    required this.deviceId,
    required this.totalPrice,
    required this.id,
  }) : super(key: key);

  @override
  _StatusQrcodePageState createState() => _StatusQrcodePageState();
}

class _StatusQrcodePageState extends State<StatusQrcodePage> {
  String? qrImage;
  String? paymentStatus;
  String phone = '';
  int _remainingSeconds = 5 * 60;
  bool isCheck = false;
  late Timer _timer;
  String apiKey = "DRIVER";

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _loadPhone();
    loadStatus(); // เรียก loadStatus หลัง initState
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0)
            _remainingSeconds--;
          else
            timer.cancel();
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phone = prefs.getString('phone') ?? '';
    });
  }

  Future<void> loadStatus() async {
    try {
      if (!isCheck) {
        await _generateQR(widget.deviceId);
      } else {
        await _checkPaymentStatus(widget.deviceId);
      }
      isCheck = true;
    } catch (e) {
      setState(() {
        paymentStatus = "เกิดข้อผิดพลาด";
      });
    }
  }

  Future<void> _generateQR(String orderId) async {
    final url =
        "https://payment.washlover.com/create-payment-qr?amount=${widget.totalPrice}&order_id=$orderId&ref4=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        qrImage = data["image2"];
        paymentStatus = "กรุณาสแกนเพื่อชำระเงิน";
      });
    } else {
      setState(() {
        paymentStatus = "สร้าง QR ไม่สำเร็จ";
      });
    }
  }

  Future<void> _checkPaymentStatus(String orderId) async {
    final url = "https://payment.washlover.com/api/check-payment?ref1=$orderId&ref4=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["data"]["status"] == "success") {
        setState(() {
          paymentStatus = "🎉 ชำระเงินเรียบร้อยแล้ว";
        });

        MainLayout.initialIndex = 4;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainLayout()),
          (route) => false,
        );
      } else {
        setState(() {
          paymentStatus = data["data"]["msg"] ?? "รอการชำระเงิน";
        });
      }
    } else {
      setState(() {
        paymentStatus = "เช็คสถานะไม่สำเร็จ";
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('th_TH', null);
    final formattedDate = DateFormat('d MMMM yyyy, E', 'th_TH').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.share, color: Colors.pink),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("รหัสงาน: ${widget.deviceId}", style: TextStyle(color: Colors.grey)),
                    Divider(),

                    // Info rows
                    _buildInfoRow("ยูเซอร์", phone, "สถานะ", paymentStatus ?? "-"),
                    _buildInfoRow("วันที่", formattedDate, "จะหมดเวลา", "${_formatTime(_remainingSeconds)} น."),
                    _buildInfoRow("หมายเลขอ้างอิง", widget.deviceId, "", ""),

                    Divider(),

                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("จำนวนเงิน:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("฿ ${widget.totalPrice}",
                            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),

                    // QR Code
                    qrImage == null ? Text("กำลังสร้าง QRCODE...") : Image.network(qrImage!, width: 300, height: 300),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "คำเตือน: สามารถสแกน QRCODE ได้ครั้งเดียว ห้ามนำกลับมาใช้ซ้ำ",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildButton("ยกเลิก", Colors.grey, Colors.black, () {
                          MainLayout.initialIndex = 4;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => MainLayout()),
                            (route) => false,
                          );
                        }),
                        _buildButton("โอนสำเร็จ", Colors.lightGreen, Colors.white, () {
                          loadStatus();
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoColumn(label1, value1),
          _buildInfoColumn(label2, value2),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
