import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

// STEP 1: เลือกธนาคาร
class wallet extends StatelessWidget {
  final List<Map<String, dynamic>> banks = [
    {"name": "K PLUS", "image": "assets/images/scb.jpg"},
    {"name": "SCB", "image": "assets/images/scb.jpg"},
    {"name": "พร้อมเพย์", "image": "assets/images/scb.jpg"},
    {"name": "ทรูวอลเล็ท", "image": "assets/images/scb.jpg"},
    {"name": "กรุงเทพ", "image": "assets/images/scb.jpg"},
    {"name": "Shopee Pay", "image": "assets/images/scb.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0), // เพิ่มระยะห่างด้านล่าง
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "เลือกวิธีเติมเงิน",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 203, 203, 203),
                    ),
                  ),
                ],
              ),
            ),

            // ส่วนของ GridView ที่แสดงรายการ
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AmountSelectionPage(bank: banks[index]["name"]),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 0.4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // การทำมุมโค้ง
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // สีพื้นหลังของวงกลม
                                  shape: BoxShape.circle, // ทำให้เป็นวงกลม
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withOpacity(0.2), // เงาสีเทา
                                      spreadRadius: 2, // ขยายเงาออกไป
                                      blurRadius: 6, // ความเบลอของเงา
                                      offset:
                                          Offset(0, 4), // เลื่อนเงาไปด้านล่าง
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  banks[index]["image"],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              banks[index]["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // ขนาดข้อความ
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 2: เลือกจำนวนเงิน (เรียบหรู ทันสมัย)
class AmountSelectionPage extends StatefulWidget {
  final String bank;
  AmountSelectionPage({required this.bank});

  @override
  _AmountSelectionPageState createState() => _AmountSelectionPageState();
}

class _AmountSelectionPageState extends State<AmountSelectionPage> {
  final TextEditingController _controller = TextEditingController();
  final List<int> amounts = [110, 180, 220, 300, 500, 1000, 1500, 2000];
  int? selectedAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'เลือกจำนวนเงิน',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.bank}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: "กรอกจำนวนเงิน (ขั้นต่ำ 10 บาท)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            SizedBox(height: 24),
            Text(
              "เลือกจำนวนที่ต้องการ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amounts.map((amount) {
                return ChoiceChip(
                  label: Text("฿$amount", style: TextStyle(fontSize: 16)),
                  selected: selectedAmount == amount,
                  selectedColor: Colors.blue.shade600,
                  labelStyle: TextStyle(
                    color:
                        selectedAmount == amount ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selectedAmount = amount;
                      _controller.text = amount.toString();
                    });
                  },
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text("ถัดไป",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SummaryPage(
                        bank: widget.bank,
                        amount: double.parse(_controller.text),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// STEP 3: หน้าสรุป (เรียบหรู)
class SummaryPage extends StatelessWidget {
  final String bank;
  final double amount;

  SummaryPage({required this.bank, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ตรวจสอบข้อมูล',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/scb.jpg",
                    ),
                    radius: 28,
                  ),
                  SizedBox(width: 16),
                  Text(
                    bank,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "จำนวนเงิน",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              trailing: Text(
                "฿${amount.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "ค่าธรรมเนียม",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              trailing: Text(
                "฿0.00",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "ยืนยัน",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("ทำการยืนยันการเติมเงินเรียบร้อย")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
