import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class ShareFriendScreen extends StatefulWidget {
  const ShareFriendScreen({super.key});

  @override
  State<ShareFriendScreen> createState() => _ShareFriendScreenState();
}

class _ShareFriendScreenState extends State<ShareFriendScreen> {
  final String referralCode = "TO2642";

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("คัดลอกโค้ดเรียบร้อย!")),
    );
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
            // 🔹 ปุ่มด้านบน "รับโค้ด / ประวัติ"
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 243, 246, 251),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTopButton("รับโค้ด", true),
                  const SizedBox(width: 10),
                  buildTopButton("ประวัติ", false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 ส่วนหัว
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

            // 🔹 ภาพกลาง (Dummy image)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/duck1.jpg",
                width: double.infinity,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 ข้อความโปรโมชั่น
            const Text(
              "ชวนเพื่อนมาใช้แอปฯ รับเลยคูปองเงินสด",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "รับคูปองเงินสดเริ่มต้นมูลค่า 10 บาท เมื่อเพื่อนสมัครและใช้งานแอปฯ สำเร็จ",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // 🔹 กล่องโค้ด Referral
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // โค้ด
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

                  // ปุ่มแชร์
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
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "*ขอสงวนสิทธิ์การใช้คูปองเพื่อการส่วนบุคคลเท่านั้น ห้ามนำไปใช้เพื่อการค้าหรือแชร์เพื่อผลกำไร",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildTopButton(String label, bool isActive) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D47A1) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF0D47A1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
