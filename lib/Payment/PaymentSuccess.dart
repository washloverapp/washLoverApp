import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Status/status.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final String detail;
  final String username;
  final String status;
  final String ref;
  // Constructor to accept values from the previous page
  PaymentSuccessScreen({
    required this.amount,
    required this.detail,
    required this.username,
    required this.status,
    required this.ref,
  });

  Future<String?> convertedSelectedOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedOptions');
  }

  Future<void> removeConvertedSelectedOptions(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedOptions');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainLayout()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text(
                'ชำระเงินสำเร็จแล้ว',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'การทำธุรกรรมของคุณสำเร็จแล้ว',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Divider(color: Colors.white54, thickness: 1, height: 20),
              PaymentDetailRow(
                label: 'จำนวนเงิน',
                value: '฿${(double.tryParse(amount) ?? 0.0).clamp(0.0, double.infinity).toStringAsFixed(2)}',
              ),
              PaymentDetailRow(label: 'คำสั่งซื้อ', value: '$detail'),
              PaymentDetailRow(label: 'หมายเลขอ้างอิง', value: '$ref'),
              PaymentDetailRow(label: 'หมายเหตุ', value: '$username'),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Button background color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  removeConvertedSelectedOptions(context);
                },
                child: Text(
                  'กลับไปยังหน้าหลัก',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;

  PaymentDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
