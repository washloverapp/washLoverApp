import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NO_account_Wallet extends StatefulWidget {
  const NO_account_Wallet({super.key});

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<NO_account_Wallet> {
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    // loadPhoneData();
  }

  String phoneT = "Loading...";
  String Credit = "Loading...";
  String firstname = "Loading...";
  String lastname = "Loading...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ส่วนแสดงเครดิตคงเหลือ

            // ใช้ Expanded เพื่อให้ ListView ขยายเต็มพื้นที่
            SizedBox(height: 100),
            Center(
              child: Text(
                "กรุณาเข้าสู่ระบบ",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "เมื่อมีการเข้าสู่ระบบระบบ จะให้คุณเปิดตำแหน่งเพื่อในการส่งซัก ทางเราจะได้ทราบที่ท่านระบุตำแหน่งนั้นถูกต้อง เพื่อพนักงานของเราจะเข้าไปรับผ้าท่านได้ถูกต้อง",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )

            // Expanded(
            //   child: transactions.isEmpty
            //       ? Center(
            //           child: CircularProgressIndicator()) // Loading indicator
            //       : ListView.builder(
            //           itemCount: transactions.length,
            //           itemBuilder: (context, index) {
            //             var transaction = transactions[index];
            //             return _buildTransactionItem(
            //               icon: Icons.credit_card,
            //               color: Colors.green,
            //               title: "${transaction['Username']}",
            //               subtitle: transaction['AddTime'],
            //               amount: "฿${transaction['Deposit']}",
            //               time: "เติมเงิน",
            //             );
            //           },
            //         ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.4),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400],
                  fontSize: 16),
            ),
            Text(
              time,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
