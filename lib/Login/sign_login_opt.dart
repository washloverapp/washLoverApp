import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart'; // ✅ อย่าลืม import หน้านี้

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = Color(0xFF1976D2);
    const Color lightBlue = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🌈 พื้นหลัง gradient ฟ้าอ่อนนวลตา
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🫧 ฟองสบู่โปร่งใสเบาๆ
          Positioned(
            top: 120,
            left: 40,
            child: _bubble(60),
          ),
          Positioned(
            bottom: 180,
            right: 60,
            child: _bubble(90),
          ),
          Positioned(
            bottom: 60,
            left: 100,
            child: _bubble(40),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔙 ปุ่มย้อนกลับ
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, size: 30),
                        color: mainBlue,
                        padding: const EdgeInsets.only(left: 4),
                        tooltip: "กลับ",
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🖼️ โลโก้
                    // Image.asset('assets/images/logo.png', height: 110),
                    // const SizedBox(height: 24),

                    Text(
                      "ยืนยันรหัส OTP",
                      style: GoogleFonts.prompt(
                        color: mainBlue,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "กรอกรหัส 4 หลักที่ส่งไปยังเบอร์\n061 **** 310",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.prompt(
                        color: Colors.grey[700],
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 🧾 กล่อง OTP
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.85),
                            Colors.grey.shade100.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_rounded,
                              size: 48, color: mainBlue),
                          const SizedBox(height: 16),
                          Text(
                            "ยืนยันตัวตน",
                            style: GoogleFonts.prompt(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Text(
                          //   "กรอกรหัส OTP ที่ส่งไปยังหมายเลขของคุณ",
                          //   textAlign: TextAlign.center,
                          //   style: GoogleFonts.prompt(
                          //     fontSize: 14,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                          // const SizedBox(height: 24),

                          // 🔢 OTP Input
                          PinCodeTextField(
                            appContext: context,
                            length: 6,
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              fieldHeight: 55,
                              fieldWidth: 50,
                              activeColor: mainBlue,
                              selectedColor: mainBlue,
                              inactiveColor: Colors.grey.shade400,
                            ),
                            textStyle: GoogleFonts.prompt(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: mainBlue,
                            ),
                            onChanged: (value) {},

                            // 👇 เพิ่มบรรทัดนี้เพื่อเว้นระยะห่างระหว่างช่อง
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            // หรือจะใช้ spacing ถ้ามีในเวอร์ชันของคุณ
                            // spacing: 12, // ระบุค่าระยะห่างเป็น double
                          ),

                          const SizedBox(height: 30),

                          // ✅ ปุ่มยืนยัน
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MainLayout()),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "ยืนยันรหัส OTP",
                                style: GoogleFonts.prompt(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🔁 ขอรหัสใหม่
                    Column(
                      children: [
                        Text(
                          "ยังไม่ได้รับรหัส OTP?",
                          style: GoogleFonts.prompt(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            // TODO: resend OTP
                          },
                          child: Text(
                            "ขอรับรหัสอีกครั้ง",
                            style: GoogleFonts.prompt(
                              color: mainBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // 🔻 โลโก้ล่าง
                    const SizedBox(height: 8),
                    Text(
                      "WASHLOVER",
                      style: GoogleFonts.prompt(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    final icons = [
      Icons.favorite,
      Icons.star_rounded,
      Icons.circle,
    ];
    final icon = (icons..shuffle()).first;

    final colors = [
      const Color.fromARGB(255, 62, 122, 172),
      const Color.fromARGB(255, 68, 191, 207),
      const Color.fromARGB(255, 214, 132, 140),
      const Color.fromARGB(255, 230, 216, 93),
    ];
    final color = (colors..shuffle()).first.withOpacity(0.25);

    final rotation = ([-0.2, 0.1, 0.3]..shuffle()).first;

    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
