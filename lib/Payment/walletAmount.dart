import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Payment/qraddcredit.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class Amount extends StatefulWidget {
  const Amount({super.key});

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<Amount> {
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ระบุรายละเอียด',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "จำนวนเงิน",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  buildInputField("ระบุจำนวนเงิน", "ขั้นต่า 1 บาท"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      String amount = amountController.text;
                      // print('amount : $amount');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrcodeAddCredit(),
                          settings: RouteSettings(arguments: amount),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => QrcodeAddCredit(),
                      //     settings: RouteSettings(
                      //       arguments: {
                      //         'totalPrice': amount,
                      //       },
                      //     ),
                      //   ),
                      // );
                    },
                    child: Text(
                      "ดำเนินการ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, String hint,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 5),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number, // If you expect number input
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
