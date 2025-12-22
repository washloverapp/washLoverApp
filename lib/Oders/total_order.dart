// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// class SendOrderFutureButton {
 
// /// =======================
// /// SHARED PREFERENCES
// /// =======================
// Future<Map<String, dynamic>> getSelection() async {
//   final prefs = await SharedPreferences.getInstance();
//   String? jsonString = prefs.getString("selection");

//   if (jsonString == null) {
//     final mockData = {};
//     prefs.setString("selection", json.encode(mockData));
//     jsonString = json.encode(mockData);
//   }

//   final Map<String, dynamic> data = json.decode(jsonString);

//   Map<int, int> parseMap(Map<String, dynamic> map) {
//     final result = <int, int>{};
//     map.forEach((k, v) {
//       result[int.parse(k)] = v is String ? int.parse(v) : v;
//     });
//     return result;
//   }

//   return {
//     "washing": data["washing"] is String
//         ? int.parse(data["washing"])
//         : data["washing"],
//     "dryer": data["dryer"] is String ? int.parse(data["dryer"]) : data["dryer"],
//     "temperature": data["temperature"] is String
//         ? int.parse(data["temperature"])
//         : data["temperature"],
//     "detergent": parseMap(data["detergent"]),
//     "softener": parseMap(data["softener"]),
//   };
// }

// /// =======================
// /// LOAD + PROCESS
// /// =======================
// Future<OrderSummary> loadOrderSummary() async {
//   final selection = await getSelection();
//   final mockList = await fetchMockList();

//   final washing = findSingleItem(mockList, "washing", selection["washing"]);
//   final dryer = findSingleItem(mockList, "dryer", selection["dryer"]);
//   final temperature =
//       findSingleItem(mockList, "temperature", selection["temperature"]);

//   final detergents = findMultiItems(
//     mockList,
//     "detergent",
//     Map<int, int>.from(selection["detergent"]),
//   );

//   final softeners = findMultiItems(
//     mockList,
//     "softener",
//     Map<int, int>.from(selection["softener"]),
//   );

//   int totalPrice = 0;
//   if (washing != null) totalPrice += washing.price;
//   if (dryer != null) totalPrice += dryer.price;
//   if (temperature != null) totalPrice += temperature.price;

//   totalPrice += detergents.fold(0, (sum, e) => sum + e.item.price * e.qty) +
//       softeners.fold(0, (sum, e) => sum + e.item.price * e.qty);

//   return OrderSummary(
//     washing: washing,
//     dryer: dryer,
//     temperature: temperature,
//     detergents: detergents,
//     softeners: softeners,
//     totalPrice: totalPrice,
//   );
// }

// /// =======================
// /// FIND FUNCTIONS
// /// =======================
// MockItem? findSingleItem(List<MockItem> list, String type, int id) {
//   try {
//     return list.firstWhere((e) => e.type == type && e.id == id.toString());
//   } catch (_) {
//     return null;
//   }
// }

// List<SelectedItem> findMultiItems(
//     List<MockItem> list, String type, Map<int, int> selected) {
//   return selected.entries.map((entry) {
//     final item =
//         list.firstWhere((e) => e.type == type && e.id == entry.key.toString());
//     return SelectedItem(item: item, qty: entry.value);
//   }).toList();
// }

// /// =======================
// /// API FETCH
// /// =======================
// Future<List<MockItem>> fetchMockList() async {
//   const url =
//       "https://washlover-1bef6-default-rtdb.firebaseio.com/mocklist.json";
//   final response = await http.get(Uri.parse(url));
//   final List data = json.decode(response.body);
//   return data.map((e) => MockItem.fromJson(e)).toList();
// }

// Future<void> clearCart(OrderSummary order) async {
//   var headers = {
//     'Authorization':
//         'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMywicm9sZSI6Im1lbWJlciIsInBob25lIjoiMDk4NzY1NDMyMyIsIm5pY2tuYW1lIjoiUm9sbmFsZG8iLCJkZXZpY2VfaWQiOiJ1c2VyXzcwMWNmN2M0LTQ1NjgtNDk4Yi1iNWZkLWExNTMyMzU2MjUzYSIsImlhdCI6MTc2NjM4MjIzMywiZXhwIjoxNzY2NDY4NjMzfQ.Owqf_l4X_4jNCSpahXU3uti6ZNifIVnySoajjFsx4AU'
//   };

//   var dio = Dio();
//   try {
//     var response = await dio.request(
//       'https://members.washlover.com/api/cart/0987654323',
//       options: Options(
//         method: 'DELETE',
//         headers: headers,
//       ),
//     );

//     if (response.statusCode == 200) {
//       print("ลบ cart เรียบร้อย");
//       // รอให้ส่ง order เสร็จก่อน
//       await sendOrderItems(order);
//     } else {
//       print("Error ลบ cart: ${response.statusMessage}");
//     }
//   } catch (e) {
//     print("Exception ลบ cart: $e");
//   }
// }

// /// =======================
// /// API POST ITEM
// /// =======================
// Future<void> sendItemToCart(MockItem item, {int qty = 1}) async {
//   var headers = {
//     'Content-Type': 'application/json',
//     'Authorization':
//         'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMywicm9sZSI6Im1lbWJlciIsInBob25lIjoiMDk4NzY1NDMyMyIsIm5pY2tuYW1lIjoiUm9sbmFsZG8iLCJkZXZpY2VfaWQiOiJ1c2VyXzcwMWNmN2M0LTQ1NjgtNDk4Yi1iNWZkLWExNTMyMzU2MjUzYSIsImlhdCI6MTc2NjM4MDQwMywiZXhwIjoxNzY2NDY2ODAzfQ.W00ULcX7Z9Q5DlQ6zfgaFXIXq1_U7cjREOCrNQT38OM'
//   };

//   var data = json.encode({
//     "detail": item.detail,
//     "id": item.id,
//     "image": item.image,
//     "name": item.name,
//     "price": item.price,
//     "type": item.type,
//     "qty": qty // ส่ง qty ด้วย
//   });

//   var dio = Dio();

//   try {
//     var response = await dio.request(
//       'https://members.washlover.com/api/cart/0987654323',
//       options: Options(method: 'POST', headers: headers),
//       data: data,
//     );

//     if (response.statusCode == 200) {
//       print("ส่งสำเร็จ: ${json.encode(response.data)}");
//     } else {
//       print("Error: ${response.statusMessage}");
//     }
//   } catch (e) {
//     print("Exception: $e");
//   }
// }

// /// =======================
// /// ส่ง OrderSummary ทั้งหมด
// /// =======================
// Future<void> sendOrderItems(OrderSummary order) async {
//   if (order.washing != null) await sendItemToCart(order.washing!, qty: 1);
//   if (order.dryer != null) await sendItemToCart(order.dryer!, qty: 1);
//   if (order.temperature != null)
//     await sendItemToCart(order.temperature!, qty: 1);

//   for (var e in order.detergents) {
//     await sendItemToCart(e.item, qty: e.qty);
//   }

//   for (var e in order.softeners) {
//     await sendItemToCart(e.item, qty: e.qty);
//   }

//   print("ส่ง Order สำเร็จทั้งหมด");
// }

// }


// /// =======================
// /// MODELS
// /// =======================
// class MockItem {
//   final String id;
//   final String type;
//   final String name;
//   final String detail;
//   final String image;
//   final int price;

//   MockItem({
//     required this.id,
//     required this.type,
//     required this.name,
//     required this.detail,
//     required this.image,
//     required this.price,
//   });

//   factory MockItem.fromJson(Map<String, dynamic> json) {
//     return MockItem(
//       id: json["id"],
//       type: json["type"],
//       name: json["name"],
//       detail: json["detail"],
//       image: json["image"],
//       price: json["price"],
//     );
//   }
// }

// class SelectedItem {
//   final MockItem item;
//   final int qty;

//   SelectedItem({required this.item, required this.qty});
// }

// class OrderSummary {
//   final MockItem? washing;
//   final MockItem? dryer;
//   final MockItem? temperature;
//   final List<SelectedItem> detergents;
//   final List<SelectedItem> softeners;
//   final int totalPrice;

//   OrderSummary({
//     required this.washing,
//     required this.dryer,
//     required this.temperature,
//     required this.detergents,
//     required this.softeners,
//     required this.totalPrice,
//   });
// }
