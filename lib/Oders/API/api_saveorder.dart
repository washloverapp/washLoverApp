// // lib/services/cart_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APICartSet {
  // ✅ ฟังก์ชันนี้เป็น public (เรียกใช้จากไฟล์อื่นได้)
  static Future<bool> sendCartToSet() async {
    bool ok = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final phone = prefs.getString('phone');
      final endpoint = prefs.getString('endpoint') ?? '';
      String orderJsonString = prefs.getString('current_order') ?? '{}';
      Map<String, dynamic> orderJson = jsonDecode(orderJsonString);

      print('sendCartToSet');
      // print('orderJsonString');
      // print(orderJsonString);
      print(orderJson);
      String device_id = orderJson['device_id'] ?? '';
      if (token == null) {
        print("❌ ไม่พบ Token, กรุณา Login ก่อน");
      }
      if (endpoint.isEmpty) {
        print("❌ ไม่พบ Endpoint ใน SharedPreferences");
      }
      if (phone == null) {
        print("❌ ไม่พบหมายเลขโทรศัพท์ใน SharedPreferences");
      }
      // ✅ ใช้ http.Request แทน http.post
      // final url = Uri.parse('$endpoint/api/cart/$phone');
      var header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final dio = Dio();
      final path = '$endpoint/api/cart/$device_id';
      List listData = [];
      var listJson = orderJson.values.toList();
      print('x-----22');
      print(listJson);
      for (int i = 0; i < listJson.length; i++) {
        if (i > 4) {
          print(listJson[i]['name'].toString());
          print(listJson[i]['price'].toString());
          print(listJson[i]['detail'].toString());
          print('---------dddd');
          var dataJson = {
            "name": listJson[i]['name'],
            "price": listJson[i]['price'],
            "detail": listJson[i]['detail'],
          };
          listData.add(dataJson);
        }
      }
      print('---------listData');
      // print(jsonEncode(listData));
      for (var x in listData) {
        var dataJson = {
          "name": x['name'],
          "price": x['price'],
          "detail": x['detail'],
        };
        print(jsonEncode(dataJson));
        final response = await dio.post(
          path,
          data: jsonEncode(dataJson),
          options: Options(
            headers: header,
            validateStatus: (_) => true,
          ),
        );

        if (response.statusCode == 200) {
          final responseBody = response.data;
          print('responseBody');
          print(responseBody);
          print("✅ ส่งข้อมูลสำเร็จ: $responseBody");
          ok = true;
        } else {
          print("❌ ส่งข้อมูลไม่สำเร็จ (${response.statusCode}): ${response.data}");
        }
      }

      return ok;
    } catch (e) {
      print("⚠️ Error: $e");
      return ok;
    }
  }

  static Future<dynamic> getCart(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final phone = prefs.getString('phone');
      final endpoint = prefs.getString('endpoint') ?? '';
      // String orderJsonString = prefs.getString('current_order') ?? '{}';
      // Map<String, dynamic> orderJson = jsonDecode(orderJsonString);

      print('getCart');
      // print(phone);
      // print('orderJsonString');
      // print(orderJsonString);
      // print(orderJson);
      if (token == null) {
        print("❌ ไม่พบ Token, กรุณา Login ก่อน");
      }
      if (endpoint.isEmpty) {
        print("❌ ไม่พบ Endpoint ใน SharedPreferences");
      }
      if (phone == null) {
        print("❌ ไม่พบหมายเลขโทรศัพท์ใน SharedPreferences");
      }
      // ✅ ใช้ http.Request แทน http.post
      // final url = Uri.parse('$endpoint/api/cart/$phone');
      var header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final dio = Dio();
      final path = '$endpoint/api/cart/$deviceId';
      print(path);
      final response = await dio.get(
        path,
        options: Options(
          headers: header,
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.data;
        print('responseBody');
        print(responseBody);
        print("✅ ส่งข้อมูลสำเร็จ: $responseBody");
        return responseBody;
      } else {
        print("❌ ส่งข้อมูลไม่สำเร็จ (${response.statusCode}): ${response.data}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error: $e");
      return null;
    }
  }
  // static Future<void> sendCartOk(
  //   String device,
  //   List<Map<String, dynamic>> items,
  // ) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');
  //     final endpoint = prefs.getString('endpoint') ?? '';
  //     if (token == null || token.isEmpty) {
  //       print("❌ ไม่พบ Token, กรุณา Login ก่อน");
  //       return;
  //     }
  //     if (endpoint.isEmpty) {
  //       print("❌ ไม่พบ Endpoint ใน SharedPreferences");
  //       return;
  //     }
  //     // ✅ สร้าง URL พร้อม device
  //     final url = Uri.parse('$endpoint/api/cart/$device');
  //     // 🔹 ตั้งค่า Header
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     };
  //     // 🔹 ถ้ามี item เดียว ส่งเป็น object เดียว
  //     // ถ้ามีหลายชิ้น ส่งเป็น {"items": [...]} แทน
  //     final body = items.length == 1 ? items.first : {"items": items};
  //     // ✅ ใช้ http.Request เพื่อควบคุมได้ละเอียด
  //     final request = http.Request('POST', url);
  //     request.body = json.encode(body);
  //     request.headers.addAll(headers);
  //     print("📦 ส่งข้อมูลไปที่: $url");
  //     print("📤 Payload: ${jsonEncode(body)}");
  //     final response = await request.send();
  //     if (response.statusCode == 200) {
  //       final responseBody = await response.stream.bytesToString();
  //       print("✅ ส่งข้อมูลสำเร็จมาก: $responseBody");
  //     } else {
  //       print("❌ ส่งข้อมูลไม่สำเร็จ (${response.statusCode}): ${response.reasonPhrase}");
  //     }
  //   } catch (e) {
  //     print("⚠️ Error: $e");
  //   }
  // }
}
