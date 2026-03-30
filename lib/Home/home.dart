import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Help/help.dart';
import 'package:my_flutter_mapwash/Home/API/api_account.dart';
import 'package:my_flutter_mapwash/Home/API/api_sendFcmNotify.dart';
import 'package:my_flutter_mapwash/Home/account.dart';
import 'package:my_flutter_mapwash/Home/affiat.dart';
import 'package:my_flutter_mapwash/Home/history.dart';
import 'package:my_flutter_mapwash/Home/show_promotion.dart';
import 'package:my_flutter_mapwash/Manual/manual.dart';
import 'package:my_flutter_mapwash/Profile/profile.dart';
import 'package:my_flutter_mapwash/Banchs/location_banc.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  String credit = "Loading...";
  String point_h = "Loading...";

  Future<void> _loadUserData() async {
    var userData = await API_account.fetchapiaccount();
    if (userData != null) {
      setState(() {
        if (userData['credit'] == null) {
          userData['credit'] = 0;
          credit = userData['credit'].toString();
        } else {
          credit = userData['credit'].toString();
        }
        if (userData['points'] == null) {
          userData['points'] = 0;
        } else {
          point_h = userData['points'].toString();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF42A5F5),
              Colors.white,
            ],
            stops: [0.1, 0.1], // ด้านบน 10% ฟ้า ด้านล่าง 90% ขาว
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 12),
              // Container(
              //   padding: EdgeInsets.all(20),
              //   margin: EdgeInsets.symmetric(horizontal: 15), // ขยับด้านซ้าย-ขวา
              //   decoration: BoxDecoration(
              //     color: const Color.fromARGB(255, 250, 250, 250),
              //     borderRadius: BorderRadius.circular(10),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black12,
              //         blurRadius: 5,
              //         spreadRadius: 0,
              //         offset: Offset(0, 0),
              //       ),
              //     ],
              //   ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15), // ขยับด้านซ้าย-ขวา
                color: Colors.white,
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _walletItem2(
                        Image.asset(
                          "assets/images/collectionduck/Artboard14.png",
                          width: 60,
                          height: 60,
                        ),
                        "ยอดเงิน",
                        "${credit}฿",
                      ),
                      _walletItem(
                          Image.asset(
                            "assets/images/collectionduck/Artboard21copy5.png",
                            width: 60,
                            height: 60,
                          ),
                          "Points",
                          point_h),
                      _walletItem(
                          Image.asset(
                            "assets/images/collectionduck/Artboard17.png",
                            width: 60,
                            height: 60,
                          ),
                          "คูปอง",
                          "0"),
                      _duckItem(
                          Image.asset(
                            "assets/images/collectionduck/Artboard37copy8.png",
                            width: 60,
                            height: 60,
                          ),
                          "เก็บเวล",
                          "0"),
                    ],
                  ),
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
                        child: Image.asset("assets/images/slid2.png", fit: BoxFit.cover),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.asset("assets/images/slid3.png", fit: BoxFit.cover),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.asset("assets/images/slid1.png", fit: BoxFit.cover),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),

              // InkWell(
              //   onTap: () {
              //     api_sendFcmNotify.sendFcmNotify(
              //       'แจ้งเตือนออเดอร์งานจากลูกค้า',
              //       'งานด่วนลูกค้ารอพนักงานรับผ้า',
              //     );
              //   },
              //   child: Card(
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              //       child: Text(
              //         "ส่งแจ้งเตือน",
              //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),
              // ),

              // Service Section Title
              Card(
                color: Colors.white,
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 15), // ขยับด้านซ้าย-ขวา
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // จัด Text ชิดซ้าย
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                        child: Text(
                          "บริการ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                            Image.asset(
                              "assets/images/collectionduck/Artboard21copy12.png",
                              width: 60,
                              height: 60,
                            ),
                            "ตัวฉัน",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => profile()),
                              );
                            },
                          ),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard1copy4.png",
                                width: 60,
                                height: 60,
                              ),
                              "จุดบริการ", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => location_banc()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard43.png",
                                width: 60,
                                height: 60,
                              ),
                              "แนะนำเพื่อน", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ShareFriendScreen()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard37copy3.png",
                                width: 60,
                                height: 60,
                              ),
                              "โปรโมชั่น", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => select_Promotion()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard17.png",
                                width: 60,
                                height: 60,
                              ),
                              "สะสมแต้ม", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => point()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard24.png",
                                width: 60,
                                height: 60,
                              ),
                              "ประวัติใช้งาน", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => History()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard37.png",
                                width: 60,
                                height: 60,
                              ),
                              "คู่มือใช้งาน", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => manual()),
                            );
                          }),
                          _menuItem(
                              Image.asset(
                                "assets/images/collectionduck/Artboard37copy5.png",
                                width: 60,
                                height: 60,
                              ),
                              "แจ้งปัญหา", () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Help()),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletItem2(Widget img, String title, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: img,
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
          style: TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _walletItem(Widget img, String title, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: img,
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
          style: TextStyle(fontSize: 12, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _duckItem(Widget img, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: img,
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
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _menuItem(Widget img, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color.fromARGB(255, 245, 245, 245),
            child: img,
          ),
          SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildContactButton(String text, Color color, IconData icon, VoidCallback onPressed) {
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

  Widget buildExpansionTile(String title, String content, {bool isExpanded = false}) {
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
        Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
      ],
    );
  }
}
