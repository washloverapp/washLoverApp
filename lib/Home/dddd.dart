// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:my_flutter_mapwash/Home/account.dart';
// import 'package:my_flutter_mapwash/Home/affiat.dart';
// import 'package:my_flutter_mapwash/Home/history.dart';
// import 'package:my_flutter_mapwash/Login/login_page.dart';
// import 'package:my_flutter_mapwash/Home/show_promotion.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:loading_indicator/loading_indicator.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// const List<Color> _kDefaultRainbowColors = const [
//   Colors.blue,
// ];

// class _HomeScreenState extends State<HomeScreen> {
//   _showSingleAnimationDialog(Indicator indicator, bool showPathBackground) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           fullscreenDialog: false,
//           builder: (ctx) {
//             return Scaffold(
//               body: Padding(
//                 padding: const EdgeInsets.all(64),
//                 child: Center(
//                   child: LoadingIndicator(
//                     indicatorType: indicator,
//                     colors: _kDefaultRainbowColors,
//                     strokeWidth: 4.0,
//                     pathBackgroundColor:
//                         showPathBackground ? Colors.black45 : null,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   String phoneT = "Loading...";
//   String username = "Loading...";
//   String userPhone = "Loading...";
//   String credit = "Loading...";
//   String point = "Loading...";
//   String userImageUrl = "https://via.placeholder.com/150";
//   String password = "Loading...";
//   String address = "Loading...";
//   String credit_free = "Loading...";

//   // Future<void> loadPhoneData() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String? phone = prefs.getString('phone');

//   //   if (phone != null) {
//   //     phoneT = phone;
//   //     fetchUserData();
//   //   } else {
//   //     print('Phone is not available.');
//   //   }
//   // }

//   Future<void> fetchUserData() async {
//     _showSingleAnimationDialog(Indicator.ballScale, true);
//     try {
//       final response = await http
//           .get(Uri.parse('https://washlover.com/api/member?phone=$phoneT'));
//       // _showSingleAnimationDialog(Indicator.ballScale, false);

//       if (response.statusCode == 200) {
//         final dataAll = json.decode(response.body);
//         final data = dataAll['data'];
//         setState(() {
//           username = data['nickname'] ?? '';
//           userPhone = data['phone'] ?? '09xxxxxxx';
//           credit = data['credit'].toString();
//           point = data['point'].toString();
//           userImageUrl = data['profile_image_url'] ?? userImageUrl;
//           password = data['password'] ?? password;
//           address = data['address'] ?? address;
//           credit_free = (data['credit_free'] ?? 0).toString();

//           // final rawPhone = data['phone'] ?? '09xxxxxxx';
//           // ตรวจสอบว่าเบอร์มีความยาวพอที่จะแสดง 3 ตัวแรก
//           if (userPhone.length > 3) {
//             userPhone = '${userPhone.substring(0, 3)}xxxxxxx';
//           } else {
//             userPhone = 'xxxxxxx';
//           }
//         });
//       } else {
//         throw Exception('Failed to load user data');
//       }
//     } catch (e) {
//       print(e);
//       setState(() {
//         username = 'Error loading user data';
//         userPhone = 'Please try again later';
//       });
//     }
//     Navigator.pop(context);
//   }

//   @override
//   void initState() {
//     super.initState();
//     // loadPhoneData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100), // กำหนดความสูงของ AppBar
//         child: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           flexibleSpace: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 10), // เพิ่มช่องว่างด้านบน
//               Container(
//                 padding: EdgeInsets.all(10),
//                 margin:
//                     EdgeInsets.symmetric(horizontal: 15), // ขยับด้านซ้าย-ขวา
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 5,
//                       spreadRadius: 2,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     buildInfoItem(
//                         Icons.account_balance_wallet, "ยอดเงิน", "$credit ฿"),
//                     buildInfoItem(Icons.star, "Point", "$credit_free ฿"),
//                     buildInfoItem(Icons.card_giftcard, "สะสมแต้ม", "$point ฿"),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 0), // เพิ่มช่องว่างด้านล่าง
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: CarouselSlider(
//                       options: CarouselOptions(
//                         height: 180,
//                         autoPlay: true,
//                         viewportFraction: 0.9, // ลดระยะห่างระหว่างภาพ
//                       ),
//                       items: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(15.0),
//                           child: Image.asset("assets/images/slid2.png",
//                               fit: BoxFit.cover),
//                         ),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(15.0),
//                           child: Image.asset("assets/images/slid3.png",
//                               fit: BoxFit.cover),
//                         ),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(15.0),
//                           child: Image.asset("assets/images/slid1.png",
//                               fit: BoxFit.cover),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 0),
//                 // Menu
//                 Container(
//                   margin: EdgeInsets.all(16),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 5),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "เมนู",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 0),
//                       GridView.count(
//                         crossAxisCount: 3,
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         children: [
//                           buildMenuItem(Icons.campaign, "โปรโมชั่น", context),
//                           buildMenuItem(
//                               Icons.person_add, "แนะนำเพื่อน", context),
//                           buildMenuItem(
//                               Icons.card_membership, "สะสมแต้ม", context),
//                           buildMenuItem(Icons.history, "ประวัติ", context),
//                           buildMenuItem(
//                               Icons.exit_to_app, "ออกจากระบบ", context),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 0),
//                 // Menu
//                 Container(
//                   margin: EdgeInsets.all(0),
//                   padding: EdgeInsets.all(0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       Image.asset('assets/images/2.png', fit: BoxFit.fitWidth),
//                       Image.asset('assets/images/33.png', fit: BoxFit.fitWidth),
//                       Image.asset('assets/images/44.png', fit: BoxFit.fitWidth),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.all(0),
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color:
//                                         const Color.fromARGB(39, 158, 158, 158),
//                                     width: 1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Image.asset(
//                                   'assets/images/donot.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color:
//                                         const Color.fromARGB(39, 158, 158, 158),
//                                     width: 1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Image.asset(
//                                   'assets/images/notop.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//                 // FAQ Section
//                 Padding(
//                   padding: EdgeInsets.all(0),
//                   child: Column(
//                     children: [
//                       Text(
//                         "คำถามที่พบบ่อย",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Container(
//                         // margin: EdgeInsets.all(0),
//                         // padding: EdgeInsets.all(0),
//                         height: 300,
//                         child: ListView(
//                           children: [
//                             buildExpansionTile(
//                               "ฉันต้องรอพนักงานมารับและส่งผ้าด้วยตนเองหรือไม่",
//                               "คุณสามารถวางตะกร้าผ้าของคุณไว้ตามจุดต่างๆที่พนักงานสามารถเข้าถึงได้ง่าย เช่น บริเวณพื้นที่ด้านล่างที่ได้รับอนุญาติจากหอพัก หรือบริเวณหน้าบ้านของคุณ โดยพนักงานจะไม่มีบริการเข้าไปภายในห้องหรือในตัวบ้านของลูกค้า สามารถระบุรายละเอียดต่างๆไว้ในแบบฟอร์มสั่งจอง",
//                               // isExpanded: true, // ทำให้ Tile แรกเปิดอยู่
//                             ),
//                             buildExpansionTile(
//                               "ช่องทางการชำระเงิน",
//                               "คุณสามารถชำระเงินผ่านบัตรเครดิต, โอนเงิน หรือช่องทางอื่นที่รองรับ",
//                             ),
//                             buildExpansionTile(
//                               "ฉันต้องจ่ายค่าบริการซัก-อบเมื่อไหร่",
//                               "ค่าบริการจะถูกคิดเมื่อการซักเสร็จสิ้น และสามารถชำระผ่านแอป",
//                             ),
//                             buildExpansionTile(
//                               "พนักงานจะรับ-ส่งผ้ากี่โมง",
//                               "พนักงานจะเข้ารับและส่งผ้าตามเวลาที่คุณเลือกในแอป",
//                             ),
//                             buildExpansionTile(
//                               "เปิดเวลากี่โมงถึงกี่โมง",
//                               "เปิดบริการทุกวัน 08:00 - 20:00 น.",
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   margin: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "ติดต่อเรา!",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         "สอบถามเพิ่มเติมได้ที่นี่ ทีมงานของเรายินดีช่วยคุณ",
//                         style: TextStyle(color: Colors.white70),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 10),
//                       buildContactItem(Icons.location_on,
//                           "888/1 หมู่ที่ 3 ตำบลขอนยาง\nอ.กันทรวิชัย จ.มหาสารคาม 44150"),
//                       buildContactItem(Icons.phone, "080-339-6668"),
//                       buildContactItem(Icons.email, "washlover247@gmail.com"),
//                       buildContactItem(Icons.language, "www.washlover.com"),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 0),
//                 Container(
//                   margin: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     children: [
//                       buildContactButton("LINE", Colors.green, Icons.chat, () {
//                         print("เปิด LINE");
//                       }),
//                       buildContactButton(
//                           "FACEBOOK MESSENGER", Colors.blue, Icons.facebook,
//                           () {
//                         print("เปิด Facebook Messenger");
//                       }),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.all(0),
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Image.asset(
//                     'assets/images/facebook.png',
//                     fit: BoxFit.cover,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 16,
//             right: 16,
//             child: FloatingActionButton(
//               onPressed: () {},
//               backgroundColor: Colors.green,
//               child: Icon(Icons.chat, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildContactButton(
//       String text, Color color, IconData icon, VoidCallback onPressed) {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(vertical: 5),
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon, color: Colors.white),
//         label: Text(text, style: TextStyle(color: Colors.white)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           padding: EdgeInsets.symmetric(vertical: 15),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//         ),
//       ),
//     );
//   }

//   Widget buildContactItem(IconData icon, String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.amber, size: 24),
//           SizedBox(width: 10),
//           Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
//         ],
//       ),
//     );
//   }

//   Widget buildExpansionTile(String title, String content,
//       {bool isExpanded = false}) {
//     return ExpansionTile(
//       title: Text(
//         title,
//         style: TextStyle(color: Colors.black),
//       ),
//       initiallyExpanded: isExpanded, // ทำให้ Tile แรกเปิดอยู่
//       children: [
//         Padding(
//           padding: EdgeInsets.all(10),
//           child: Text(content, style: TextStyle(color: Colors.black54)),
//         ),
//       ],
//     );
//   }

//   Widget buildInfoItem(IconData icon, String title, String amount) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.blue[200]),
//         Text(title, style: TextStyle(fontSize: 12, color: Colors.black54)),
//         Text(amount,
//             style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.amber)),
//       ],
//     );
//   }

//   Widget buildMenuItem(IconData icon, String title, BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (title == "โปรโมชั่น") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => select_Promotion()),
//           );
//         }
//         if (title == "แนะนำเพื่อน") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => ShareFriendScreen()),
//           );
//         }
//         if (title == "สะสมแต้ม") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => account()),
//           );
//         }
//         if (title == "ประวัติ") {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => History()),
//           );
//         }
//         if (title == "ออกจากระบบ") {
//           logout(context);
//         }
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 40, color: Colors.blue),
//           SizedBox(height: 5),
//           Text(title, style: TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   void logout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Successfully logged out')),
//     );
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//     );
//   }
// }
