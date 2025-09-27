import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 15), // ขยับด้านซ้าย-ขวา
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 250, 250, 250),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _walletItem(
                    Icons.account_balance_wallet,
                    "ยอดเงิน",
                    "0฿",
                  ),
                  _walletItem(Icons.star_border, "Points", "0"),
                  _walletItem(Icons.card_giftcard, "คูปอง", "0"),
                  _walletItem(Icons.leak_remove_outlined, "เก็บเวล", "0"),
                ],
              ),
            ),

            // Banner
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    viewportFraction: 0.9, // ลดระยะห่างระหว่างภาพ
                  ),
                  items: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset("assets/images/slid2.png",
                          fit: BoxFit.cover),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset("assets/images/slid3.png",
                          fit: BoxFit.cover),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.asset("assets/images/slid1.png",
                          fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Service Section Title
            Container(
              margin: EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 250, 250, 250),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // จัด Text ชิดซ้าย
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 16),
                      child: Text(
                        "บริการ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _menuItem(
                            Icons.local_laundry_service_outlined, "ซัก อบ พับ"),
                        _menuItem(Icons.check_circle_outline, "เช็คสถานะ"),
                        _menuItem(Icons.group_add_outlined, "แนะนำเพื่อน"),
                        _menuItem(Icons.history, "ประวัติการใช้งาน"),
                        _menuItem(
                            Icons.local_shipping_outlined, "บริการรีดผ้า"),
                        _menuItem(Icons.report_problem, "แจ้งปัญหา"),
                        _menuItem(Icons.phone, "ติดต่อเรา"),
                        _menuItem(Icons.card_membership_outlined, "พี่วัวคลับ"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/2.png', fit: BoxFit.fitWidth),
                  Image.asset('assets/images/33.png', fit: BoxFit.fitWidth),
                  Image.asset('assets/images/44.png', fit: BoxFit.fitWidth),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(39, 158, 158, 158),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/donot.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(39, 158, 158, 158),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/notop.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            // FAQ Section
            Padding(
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  Text(
                    "คำถามที่พบบ่อย",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    // margin: EdgeInsets.all(0),
                    // padding: EdgeInsets.all(0),
                    height: 300,
                    child: ListView(
                      children: [
                        buildExpansionTile(
                          "ฉันต้องรอพนักงานมารับและส่งผ้าด้วยตนเองหรือไม่",
                          "คุณสามารถวางตะกร้าผ้าของคุณไว้ตามจุดต่างๆที่พนักงานสามารถเข้าถึงได้ง่าย เช่น บริเวณพื้นที่ด้านล่างที่ได้รับอนุญาติจากหอพัก หรือบริเวณหน้าบ้านของคุณ โดยพนักงานจะไม่มีบริการเข้าไปภายในห้องหรือในตัวบ้านของลูกค้า สามารถระบุรายละเอียดต่างๆไว้ในแบบฟอร์มสั่งจอง",
                          // isExpanded: true, // ทำให้ Tile แรกเปิดอยู่
                        ),
                        buildExpansionTile(
                          "ช่องทางการชำระเงิน",
                          "คุณสามารถชำระเงินผ่านบัตรเครดิต, โอนเงิน หรือช่องทางอื่นที่รองรับ",
                        ),
                        buildExpansionTile(
                          "ฉันต้องจ่ายค่าบริการซัก-อบเมื่อไหร่",
                          "ค่าบริการจะถูกคิดเมื่อการซักเสร็จสิ้น และสามารถชำระผ่านแอป",
                        ),
                        buildExpansionTile(
                          "พนักงานจะรับ-ส่งผ้ากี่โมง",
                          "พนักงานจะเข้ารับและส่งผ้าตามเวลาที่คุณเลือกในแอป",
                        ),
                        buildExpansionTile(
                          "เปิดเวลากี่โมงถึงกี่โมง",
                          "เปิดบริการทุกวัน 08:00 - 20:00 น.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "ติดต่อเรา!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "สอบถามเพิ่มเติมได้ที่นี่ ทีมงานของเรายินดีช่วยคุณ",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  buildContactItem(Icons.location_on,
                      "888/1 หมู่ที่ 3 ตำบลขอนยาง\nอ.กันทรวิชัย จ.มหาสารคาม 44150"),
                  buildContactItem(Icons.phone, "080-339-6668"),
                  buildContactItem(Icons.email, "washlover247@gmail.com"),
                  buildContactItem(Icons.language, "www.washlover.com"),
                ],
              ),
            ),
            SizedBox(height: 0),
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  buildContactButton("LINE", Colors.green, Icons.chat, () {
                    print("เปิด LINE");
                  }),
                  buildContactButton(
                      "FACEBOOK MESSENGER", Colors.blue, Icons.facebook, () {
                    print("เปิด Facebook Messenger");
                  }),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/images/facebook.png',
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _walletItem(IconData icon, String title, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.blue[800]),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          child: Icon(
            icon,
            color: Colors.blue[800],
            size: 30, // <<< กำหนดขนาดของไอคอนที่นี่
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildContactButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget buildExpansionTile(String title, String content,
      {bool isExpanded = false}) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      initiallyExpanded: isExpanded, // ทำให้ Tile แรกเปิดอยู่
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(content, style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Widget buildInfoItem(IconData icon, String title, String amount) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[200]),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)),
        Text(amount,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.amber)),
      ],
    );
  }
}
