import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart'; // 🔹 สำหรับแชร์
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class ShareFriendScreen extends StatefulWidget {
  const ShareFriendScreen({super.key});

  @override
  State<ShareFriendScreen> createState() => _ShareFriendScreenState();
}

class _ShareFriendScreenState extends State<ShareFriendScreen> {
  final String referralCode = "TO2642";
  bool showHistory = false; // toggle หน้า

  // ตัวอย่างข้อมูลประวัติ
  final List<Map<String, dynamic>> referralHistory = [
    {"phone": "091-234-5678", "status": "ใช้งานแล้ว", "date": "21 ต.ค. 2025"},
    {"phone": "086-789-1123", "status": "รอใช้งาน", "date": "19 ต.ค. 2025"},
    {"phone": "089-555-3333", "status": "ใช้งานแล้ว", "date": "17 ต.ค. 2025"},
  ];

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("คัดลอกโค้ดเรียบร้อย!")),
    );
  }

  void shareCode() {
    Share.share('แนะนำเพื่อนใช้แอปนี้! โค้ดของฉัน: $referralCode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerOrder(
        title: 'แนะนำเพื่อน',
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ปุ่มด้านบน
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FB),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showHistory = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !showHistory
                              ? const Color(0xFF0D47A1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF0D47A1)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            "รับโค้ด",
                            style: TextStyle(
                              color: !showHistory
                                  ? Colors.white
                                  : const Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => showHistory = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: showHistory
                              ? const Color(0xFF0D47A1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF0D47A1)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            "ประวัติ",
                            style: TextStyle(
                              color: showHistory
                                  ? Colors.white
                                  : const Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // สลับหน้า
            showHistory ? buildHistoryList() : buildInviteSection(),
          ],
        ),
      ),
    );
  }

  // หน้ารับโค้ด
  Widget buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "แนะนำเพื่อน",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const Text(
          "มาใช้ APP",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF06292),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            "https://cdn.pixabay.com/photo/2017/01/31/23/44/woman-2026447_1280.jpg",
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "ชวนเพื่อนมาใช้แอปฯ รับเลยคูปองเงินสด",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "รับคูปองเงินสดเริ่มต้นมูลค่า 10 บาท เมื่อเพื่อนสมัครและใช้งานแอปฯ สำเร็จ",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Referral Code (Tier 1)",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    referralCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: copyToClipboard,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: const Text(
                        "คัดลอก",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: shareCode,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: const Row(
                        children: [
                          Icon(Icons.share, color: Color(0xFF1565C0)),
                          SizedBox(width: 8),
                          Text(
                            "แชร์",
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "*ขอสงวนสิทธิ์การใช้คูปองเพื่อการส่วนบุคคลเท่านั้น",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // หน้าประวัติการใช้งาน
  Widget buildHistoryList() {
    return Column(
      children: [
        const Text(
          "ประวัติการใช้โค้ดของเพื่อน",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: referralHistory.length,
          itemBuilder: (context, index) {
            final data = referralHistory[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF90CAF9)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.phone_android, color: Color(0xFF0D47A1)),
                      const SizedBox(width: 8),
                      Text(
                        data["phone"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data["status"],
                        style: TextStyle(
                          color: data["status"] == "ใช้งานแล้ว"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data["date"],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
