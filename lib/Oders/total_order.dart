
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class TotalOrder extends StatefulWidget {
//   const TotalOrder({super.key});

//   @override
//   _TotalOrderState createState() => _TotalOrderState();
// }

// class _TotalOrderState extends State<TotalOrder> {
//   Map<String, dynamic> _selection = {};
//   bool _isLoading = true;

//   // Mock data for item details
//   final Map<String, Map<String, dynamic>> _itemDetails = {
//     "0": {"name": "เครื่องซักผ้า", "detail": "ขนาด 12 kg.", "price": 40},
//     "1": {"name": "เครื่องซักผ้า", "detail": "ขนาด 16 kg.", "price": 50},
//     "2": {"name": "เครื่องซักผ้า", "detail": "ขนาด 21 kg.", "price": 60},
//     "3": {"name": "เครื่องอบผ้า", "detail": "ขนาด 12 kg.", "price": 40},
//     "4": {"name": "เครื่องอบผ้า", "detail": "ขนาด 16 kg.", "price": 50},
//     "5": {"name": "เครื่องอบผ้า", "detail": "ขนาด 21 kg.", "price": 60},
//     "6": {"name": "อุณหภูมิน้ำ", "detail": "นำ้เย็น", "price": 0},
//     "7": {"name": "อุณหภูมิน้ำ", "detail": "นำ้อุ่น", "price": 10},
//     "8": {"name": "อุณหภูมิน้ำ", "detail": "นำ้ร้อน", "price": 20},
//     "9": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
//     "10": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
//     "11": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
//     "12": {"name": "น้ำยาซัก", "detail": "รายการน้ำยาซัก", "price": 5},
//     "13": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
//     "14": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
//     "15": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
//     "16": {"name": "ปรับผ้านุ่ม", "detail": "ปรับผ้านุ่ม", "price": 5},
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadSelection();
//   }

//   Future<void> _loadSelection() async {
//     final prefs = await SharedPreferences.getInstance();
//     final selectionString = prefs.getString('selection');
//     if (selectionString != null) {
//       setState(() {
//         _selection = json.decode(selectionString);
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           'สรุปรายการ',
//           style: GoogleFonts.kanit(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _selection.isEmpty
//               ? Center(
//                   child: Text(
//                     'ไม่มีรายการที่เลือก',
//                     style: GoogleFonts.kanit(fontSize: 18, color: Colors.grey[600]),
//                   ),
//                 )
//               : ListView(
//                   padding: const EdgeInsets.all(16.0),
//                   children: _buildOrderDetails(),
//                 ),
//     );
//   }

//   List<Widget> _buildOrderDetails() {
//     final List<Widget> details = [];
//     double totalCost = 0;

//     // Helper to build a card for a section
//     Widget buildCard(String title, List<Widget> children) {
//       return Card(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: GoogleFonts.kanit(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Divider(height: 20, thickness: 1),
//               ...children,
//             ],
//           ),
//         ),
//       );
//     }

//     // Clothing Type
//     final clothingType = _selection['clothingType'];
//     if (clothingType != null && clothingType.toString().isNotEmpty) {
//       final itemDetail = clothingType == 1
//           ? {"name": "เสื้อผ้า"}
//           : {"name": "ชุดเครื่องนอน/ผ้านวม"};
//       details.add(buildCard('ประเภทผ้า', [
//         ListTile(
//           leading: const Icon(Icons.check_circle_outline, color: Colors.green),
//           title: Text(
//             itemDetail["name"]!,
//             style: GoogleFonts.kanit(fontSize: 16),
//           ),
//         )
//       ]));
//     }

//     // Detergent and Softener (Multiple selections)
//     final detergents = _selection['detergent'] as Map?;
//     if (detergents != null && detergents.isNotEmpty) {
//       final items = detergents.entries.map((e) {
//         final itemInfo = _itemDetails[e.key] ?? {'name': 'Unknown', 'price': 0};
//         final price = itemInfo['price'] * e.value;
//         totalCost += price;
//         return ListTile(
//           title: Text(itemInfo['name']!, style: GoogleFonts.kanit()),
//           trailing: Text('${e.value} x ${itemInfo['price']} = $price บาท', style: GoogleFonts.lato()),
//         );
//       }).toList();
//       details.add(buildCard('น้ำยาซัก', items));
//     }

//     final softeners = _selection['softener'] as Map?;
//     if (softeners != null && softeners.isNotEmpty) {
//       final items = softeners.entries.map((e) {
//         final itemInfo = _itemDetails[e.key] ?? {'name': 'Unknown', 'price': 0};
//         final price = itemInfo['price'] * e.value;
//         totalCost += price;
//         return ListTile(
//           title: Text(itemInfo['name']!, style: GoogleFonts.kanit()),
//           trailing: Text('${e.value} x ${itemInfo['price']} = $price บาท', style: GoogleFonts.lato()),
//         );
//       }).toList();
//       details.add(buildCard('น้ำยาปรับผ้านุ่ม', items));
//     }

//     // Single selection items
//     final singleSelectionKeys = {
//       'washingMachine': 'เครื่องซักผ้า',
//       'temperature': 'อุณหภูมิน้ำ',
//       'dryer': 'เครื่องอบผ้า'
//     };

//     singleSelectionKeys.forEach((key, title) {
//       final selectedId = _selection[key];
//       if (selectedId != null && selectedId.toString().isNotEmpty) {
//         final itemInfo = _itemDetails[selectedId.toString()];
//         if (itemInfo != null) {
//           totalCost += itemInfo['price'];
//           details.add(buildCard(title, [
//             ListTile(
//               title: Text(itemInfo['name']!, style: GoogleFonts.kanit()),
//               subtitle: Text(itemInfo['detail']!, style: GoogleFonts.kanit()),
//               trailing: Text('${itemInfo['price']} บาท', style: GoogleFonts.lato()),
//             ),
//           ]));
//         }
//       }
//     });

//     // Total Cost
//     details.add(
//       Card(
//         margin: const EdgeInsets.symmetric(vertical: 8.0),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         color: Colors.blueAccent,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'ยอดรวมทั้งหมด',
//                 style: GoogleFonts.kanit(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 '$totalCost บาท',
//                 style: GoogleFonts.lato(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     return details;
//   }
// }
