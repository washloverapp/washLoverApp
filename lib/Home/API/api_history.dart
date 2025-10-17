import 'package:flutter/material.dart';

List<Map<String, dynamic>> otherPageHistory = [
  {
    'date': '2025-10-12',
    'time': '11:20',
    'status': 'completed',
    'price_net': 120.50,
    'phone': '0811223344',
    'branch_name': 'สาขา สีลม',
    'address': 'แขวง บางรัก, กรุงเทพมหานคร',
    'imageUrl': 'https://example.com/branch_silom.jpg',
  },
  {
    'date': '2025-10-10',
    'time': '15:45',
    'status': 'completed',
    'price_net': 95.00,
    'phone': '0822334455',
    'branch_name': 'สาขา พญาไท',
    'address': 'แขวง ถนนพญาไท, เขตราชเทวี',
    'imageUrl': 'https://example.com/branch_phayathai.jpg',
  },
  {
    'date': '2025-10-08',
    'time': '08:30',
    'status': 'cancelled',
    'price_net': 0.0,
    'phone': '0833445566',
    'branch_name': 'สาขา จตุจักร',
    'address': 'แขวง จตุจักร, เขตจตุจักร',
    'imageUrl': 'https://example.com/branch_chatuchak.jpg',
  },
];

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติทั้งหมด'),
      ),
      body: ListView.builder(
        itemCount: otherPageHistory.length,
        itemBuilder: (context, index) {
          final h = otherPageHistory[index];
          String date = h['date'] ?? "Unknown";
          String time = h['time'] ?? "Unknown";
          String status = h['status'] ?? "pending";
          double priceNet = (h['price_net'] is num)
              ? (h['price_net'] as num).toDouble()
              : 0.0;
          String phone = h['phone'] ?? "Unknown";
          String branchName = h['branch_name'] ?? "";
          String address = h['address'] ?? "";
          String imageUrl = h['imageUrl'] ?? "";

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปภาพ (ถ้ามี)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  // ข้อความรายละเอียด
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branchName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('วันที่: $date    เวลา: $time'),
                        SizedBox(height: 4),
                        Text('สถานะ: $status'),
                        SizedBox(height: 4),
                        Text('ยอดสุทธิ: ฿${priceNet.toStringAsFixed(2)}'),
                        SizedBox(height: 4),
                        Text('เบอร์โทร: $phone'),
                        SizedBox(height: 4),
                        Text('ที่อยู่: $address'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
