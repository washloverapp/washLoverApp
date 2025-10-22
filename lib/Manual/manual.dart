import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class manual extends StatelessWidget {
  const manual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'คู่มือการใช้งาน', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(
            context,
          ); // ส่งคูปองที่เลือกกลับไป
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionTitle("🧼 วิธีใช้งานแอป WASHLOVER"),
          _stepText("1. สมัครสมาชิก หรือเข้าสู่ระบบด้วยเบอร์โทรศัพท์"),
          _stepText("2. เลือกบริการที่คุณต้องการ เช่น ซักผ้า อบผ้า"),
          _stepText("3. เลือกสถานที่และเวลารับ-ส่งผ้า"),
          _stepText("4. ยืนยันรายการและชำระเงิน"),
          _stepText("5. รอรับบริการถึงหน้าบ้าน"),
          const SizedBox(height: 32),
          _sectionTitle("📦 การติดตามสถานะ"),
          _stepText("• สามารถตรวจสอบสถานะผ้าของคุณได้ในหน้า 'สถานะ'"),
          _stepText("• ระบบจะแจ้งเตือนเมื่อสถานะเปลี่ยนแปลง"),
          const SizedBox(height: 32),
          _sectionTitle("💳 การชำระเงิน"),
          _stepText(
              "• รองรับการชำระผ่านบัตรเครดิต/เดบิต และโอนผ่านธนาคาร หรือเติมเป็นเครดิต"),
          _stepText("• หลังชำระเงินจะได้รับใบเสร็จอัตโนมัติ"),
          const SizedBox(height: 32),
          _sectionTitle("📞 ติดต่อทีมงาน"),
          _stepText(
              "• หากพบปัญหา สามารถติดต่อฝ่ายบริการลูกค้าได้ที่เมนู 'ช่วยเหลือ'"),
          _stepText("• เวลาทำการ: ทุกวัน 09:00 - 18:00"),
          const SizedBox(height: 32),
          Center(
            child: Text(
              "ขอบคุณที่ใช้บริการ WASHLOVER!",
              style: GoogleFonts.prompt(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _stepText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.prompt(
          fontSize: 15,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}
