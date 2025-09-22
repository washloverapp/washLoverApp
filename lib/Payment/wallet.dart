import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Payment/walletAmount.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<Wallet> {
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    loadPhoneData();
  }

  String phoneT = "Loading...";
  String Credit = "Loading...";
  String firstname = "Loading...";
  String lastname = "Loading...";

  Future<void> loadPhoneData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');

    if (phone != null) {
      phoneT = phone;
      fetchTransactions();
    } else {
      print('Phone is not available.');
    }
  }

  fetchTransactions() async {
    final response = await http
        .get(Uri.parse('https://washlover.com/api/member?phone=$phoneT'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'] != null) {
        setState(() {
          Credit = data['data']['credit'];
          firstname = data['data']['firstname']?? '';
          lastname = data['data']['lastname']?? '';
        });
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "เติมเครดิต",
          style: TextStyle(
            color: const Color.fromARGB(255, 203, 203, 203),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.wallet, color: Colors.blue[200]),
          ),
          SizedBox(width: 16),
        ],
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ส่วนแสดงเครดิตคงเหลือ
            Text(
              "เครดิตคงเหลือ",
              style: TextStyle(
                color: const Color.fromARGB(255, 182, 182, 182),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 0),
            Text(
              "฿ $Credit",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$firstname $lastname",
              style: TextStyle(
                color: const Color.fromARGB(255, 182, 182, 182),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity, // ให้ปุ่มขยายเต็มความกว้าง
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Amount()),
                  );
                },
                child: Text(
                  'เติมเงิน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // ส่วนแสดงรายการประวัติการเติมเครดิต
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ประวัติเติมเครดิต",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500]),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "ทั้งหมด",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // ใช้ Expanded เพื่อให้ ListView ขยายเต็มพื้นที่
            SizedBox(height: 100),
            Text(
              "ไม่มีข้อมูล",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
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
