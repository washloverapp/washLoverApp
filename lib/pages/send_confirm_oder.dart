// send_confirm_order.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Payment/PaymentSuccess.dart';
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';

String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
const List<Color> _kDefaultRainbowColors = const [
  Colors.blue,
];

class BranchInfo {
  final double closestDistance;
  final String closestBranch;
  final String code;
  final String addressbranch;
  final String latitude;
  final String longitude;
  final String branch;
  final String note;
  final String addressuser;

  BranchInfo({
    required this.closestDistance,
    required this.closestBranch,
    required this.code,
    required this.addressbranch,
    required this.latitude,
    required this.longitude,
    required this.branch,
    required this.note,
    required this.addressuser,
  });
}

_showSingleAnimationDialog(
    BuildContext context, Indicator indicator, bool showPathBackground) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (ctx) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(64),
              child: Center(
                child: LoadingIndicator(
                  indicatorType: indicator,
                  colors: _kDefaultRainbowColors,
                  strokeWidth: 4.0,
                  pathBackgroundColor:
                      showPathBackground ? Colors.black45 : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  });
}

List<Map<String, dynamic>> jsonData = [];

Future<void> saveUserData(String idWorking) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('idWorking', idWorking);
}

Future<void> SaveSPFID(String SPFID) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('SPFID', SPFID);
}

Future<String?> convertedSelectedOptions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('convertedSelectedOptions');
}

Future<void> removeConvertedSelectedOptions() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('convertedSelectedOptions');
}

// Future<void> saveOderTo_Member(Map<String, dynamic> dataMember) async {
//   final saveUrl = 'https://washlover.com/api/work';
//   try {
//     final saveResponse = await http.post(
//       Uri.parse(saveUrl),
//       body: json.encode(dataMember),
//     );
//     var decodedResponse = jsonDecode(saveResponse.body);

//     if (saveResponse.statusCode == 200) {
//       if (decodedResponse['status'] == "wait") {}

//       if (decodedResponse['status'] == "success") {}
//       print('dataMember to : $dataMember');
//       SaveSPFID(decodedResponse['id']);
//     } else {}
//   } catch (error) {
//     print('Error saving data: $error');
//   }
// }

// Future<void> ConfirmOrder(
//   String idWorking,
//   String amount,
//   String detail,
//   String username,
//   String image,
//   List<Map<String, dynamic>> addressuser,
//   List<Map<String, dynamic>> addressBranch,
//   String promotionPrice,
//   String payment,
//   BuildContext context,
// ) async {
//   if (idWorking == '') {
//     return;
//   }
//   print('coupon received in ConfirmOrder: $promotionPrice');
//   saveUserData(idWorking);

//   String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? phone = prefs.getString('phone');
//   String? nickName = prefs.getString('name');
//   String? converted = await convertedSelectedOptions();
//   List<dynamic> loadedData = jsonDecode(converted!);
//   List<Map<String, dynamic>> items = [];
//   String? noteData;

//   if (loadedData.isNotEmpty) {
//     var firstItem = loadedData[0];
//     if (firstItem['items'] != null) {
//       items = List<Map<String, dynamic>>.from(firstItem['items']);
//     }

//     if (loadedData.length > 1) {
//       var secondItem = loadedData[1];
//       noteData = secondItem['note'] ?? '';
//     }
//   }

//   final response = await http.put(
//     Uri.parse(
//         'https://android-dcbef-default-rtdb.firebaseio.com/order/$username/WL$idWorking.json'),
//     body: json.encode({
//       'user_location': {
//         'address': addressuser[0]['address'],
//         'latitude': addressuser[0]['latitude'],
//         'longitude': addressuser[0]['longitude'],
//         'name': addressuser[0]['name'],
//         'detail': addressuser[0]['detail'],
//         'phone': addressuser[0]['phone'],
//         'note': addressuser[0]['note'],
//         'subdistrict': addressuser[0]['subdistrict'],
//         'district': addressuser[0]['district'],
//         'province': addressuser[0]['province'],
//         'postcode': addressuser[0]['postcode'],
//       },
//       'branch': addressBranch[0]['branch'],
//       'note': noteData ?? '',
//       'datetime': date,
//       'code': 'WL$idWorking',
//       'price': amount,
//       'coupon': promotionPrice,
//       'imagePath': 'https://washlover.com/image/logo.png?v=6',
//       'name': nickName,
//       'status': 'pending',
//       'username': phone,
//       'branch_location': {
//         'code': addressBranch[0]['code'],
//         'address': addressBranch[0]['address'],
//         'latitude': addressBranch[0]['latitude'],
//         'longitude': addressBranch[0]['longitude'],
//         'branch': addressBranch[0]['branch'],
//         'name': addressBranch[0]['closestBranch'],
//       },
//       'oder_selects': items,
//     }),
//   );

//   print('paycheck : $payment');
//   Map<String, dynamic> OrderDataWait = {
//     'user_location': [
//       {
//         'address': addressuser[0]['address'],
//         'latitude': addressuser[0]['latitude'],
//         'longitude': addressuser[0]['longitude'],
//         'name': addressuser[0]['name'],
//         'detail': addressuser[0]['detail'],
//         'phone': addressuser[0]['phone'],
//         'note': addressuser[0]['note'],
//         'subdistrict': addressuser[0]['subdistrict'],
//         'district': addressuser[0]['district'],
//         'province': addressuser[0]['province'],
//         'postcode': addressuser[0]['postcode'],
//       }
//     ],
//     // 'branch': addressBranch[0]['branch'],
//     'note': noteData ?? '',
//     // 'datetime': date,
//     'code': 'WL$idWorking',
//     'price_sum': amount,
//     // 'coupon': promotionPrice,
//     'image': 'https://washlover.com/image/logo.png?v=6',
//     // 'name': nickName,
//     'status': 'pending',
//     'payment': payment,
//     'phone': phone,
//     'branch': [
//       {
//         'code': addressBranch[0]['code'],
//         'address': addressBranch[0]['address'],
//         'latitude': addressBranch[0]['latitude'],
//         'longitude': addressBranch[0]['longitude'],
//         'branch': addressBranch[0]['branch'],
//         'name': addressBranch[0]['closestBranch'],
//       }
//     ],
//     'oder_selects': items,
//   };

//   await saveOderTo_Member(OrderDataWait);

//   if (response.statusCode == 200) {
//     _showSingleAnimationDialog(context, Indicator.ballScale, true);
//     await Future.delayed(Duration(seconds: 2));
//     Navigator.pop(context);
//     // Navigator.pushAndRemoveUntil(
//     //   context,
//     //   MaterialPageRoute(
//     //     builder: (context) => PaymentSuccessScreen(
//     //       amount: amount,
//     //       detail: detail,
//     //       username: username,
//     //       status: 'สำเร็จ',
//     //       ref: 'WL$idWorking',
//     //     ),
//     //   ),
//     //   (Route<dynamic> route) => false,
//     // );
//   } else {
//     throw Exception('Failed to add data');
//   }
// }
