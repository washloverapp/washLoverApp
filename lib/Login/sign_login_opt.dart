import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF1565C0);
    const Color bgBlue = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: bgBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // 🌟 ดาวตกแต่งพื้นหลัง
            Positioned(
              top: 40,
              left: 30,
              child: Icon(Icons.star_rounded,
                  size: 36, color: Colors.amber.withOpacity(0.25)),
            ),
            Positioned(
              bottom: 120,
              right: 40,
              child: Icon(Icons.star_rounded,
                  size: 42, color: Colors.lightBlueAccent.withOpacity(0.2)),
            ),
            Positioned(
              bottom: 40,
              left: 60,
              child: Icon(Icons.star_rounded,
                  size: 22, color: Colors.lightBlueAccent.withOpacity(0.25)),
            ),

            // 🔹 เนื้อหา
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///////////////////////////////////////// ปุ่มย้อนกลับ /////////////////////////////////////////
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: mainBlue),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ///////////////////////////////////////// หัวเรื่อง /////////////////////////////////////////
                    const Text(
                      "ยืนยันรหัส OTP",
                      style: TextStyle(
                        fontSize: 24,
                        color: mainBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "กรอกรหัส 4 หลักที่ส่งไปยังเบอร์",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "061 **** 310",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),

                    ///////////////////////////////////////// card otp /////////////////////////////////////////
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: mainBlue, size: 50),
                          const SizedBox(height: 10),
                          const Text(
                            "ยืนยันตัวตน",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ช่องกรอก OTP
                          PinCodeTextField(
                            appContext: context,
                            length: 6,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.none,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 60,
                              fieldWidth: 50,
                              activeColor: mainBlue,
                              selectedColor: mainBlue,
                              inactiveColor: Colors.grey.shade300,
                            ),
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 25),

                          // ปุ่มยืนยัน
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainLayout()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: const Text(
                                "ยืนยันรหัส OTP",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    ///////////////////////////////////////// ขอรับรหัสอีกครั้ง /////////////////////////////////////////
                    const Text(
                      "ยังไม่ได้รับรหัส OTP?",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "ขอรับรหัสอีกครั้ง",
                        style: TextStyle(
                          color: mainBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    ///////////////////////////////////////// โลโก้ล่าง /////////////////////////////////////////
                    const Text(
                      "WASHLOVER",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
