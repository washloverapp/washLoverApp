import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Status/status.dart';

class PaymentFailScreen extends StatelessWidget {
  final String amount;
  final String detail;
  final String username;
  final String status;
  final String ref;
  // Constructor to accept values from the previous page
  PaymentFailScreen({
    required this.amount,
    required this.detail,
    required this.username,
    required this.status,
    required this.ref,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text(
                'ชำระเงินไม่สำเร็จ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'การทำธุรกรรมของคุณไม่สำเร็จ',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Divider(color: Colors.white54, thickness: 1, height: 20),
              PaymentDetailRow(label: 'จำนวนเงิน', value: '$amount'),
              PaymentDetailRow(label: 'คำสั่งซื้อ', value: '$detail'),
              PaymentDetailRow(label: 'หมายเลขอ้างอิง', value: '$ref'),
              PaymentDetailRow(label: 'หมายเหตุ', value: '$username'),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainLayout()),
                    (Route<dynamic> route) => false,
                  );
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
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
