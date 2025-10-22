import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';

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
            child: Column(
              children: [
                // ✅ ปุ่มย้อนกลับ (custom app bar)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // ✅ เนื้อหา FadeTransition (แยกออกจาก Center)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LOGO
                            Image.asset('assets/images/logo.png', height: 110),
                            const SizedBox(height: 24),
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

                            // card otp
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    animationType: AnimationType.scale,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      borderRadius: BorderRadius.circular(14),
                                      fieldHeight: 55,
                                      fieldWidth: 45,
                                      activeColor: mainBlue,
                                      selectedColor: mainBlue,
                                      inactiveColor: Colors.grey.shade300,
                                      activeFillColor: Colors.white,
                                      selectedFillColor: Colors.white,
                                      inactiveFillColor: Colors.white,
                                    ),
                                    textStyle: GoogleFonts.prompt(
                                      color: mainBlue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    enableActiveFill: true,
                                    onChanged: (value) {},
                                  ),
                                  const SizedBox(height: 24),

                                  // ปุ่มยืนยัน
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const MainLayout()),
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 5,
                                        backgroundColor: mainBlue,
                                        shadowColor: mainBlue.withOpacity(0.4),
                                      ),
                                      child: Text(
                                        "ยืนยันรหัส",
                                        style: GoogleFonts.prompt(
                                          fontSize: 18,
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

                            // ขอรับรหัสอีกครั้ง
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

                            // โลโก้ล่าง
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
                ),
              ],
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
