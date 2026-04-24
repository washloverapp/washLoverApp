import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class api_config {
  static String endpoint = ''; // ค่าเริ่มต้น

  /// โหลด endpoint จาก cache หรือ server
  static Future<void> loadEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    String cached = prefs.getString('endpoint') ?? '';
    // ✅ ถ้าไม่มีค่าใน cache → ยิง API ไปโหลด
    try {
      final url = Uri.parse('https://washlover.com/endpoint/gps');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['endpoint'] != null) {
          endpoint = data['endpoint'];
          await prefs.setString('endpoint', endpoint);
          print('🌐 โหลด endpoint ใหม่: $endpoint');
        } else {
          print('❌ API ตอบกลับไม่ถูกต้อง: $data');
        }
      } else {
        print('❌ API status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ โหลด endpoint ไม่สำเร็จ: $e');
    }
  }

  static Future<Map<String, dynamic>> saveTokenFcmApi() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('phone');
    final tokenMobile = await FirebaseMessaging.instance.getToken() ?? '';
    final dio = Dio();
    String path = 'https://fcm.washlover.com/api/add-subscription';
    var platform = 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = 'ios';
    }

    print('tokenMobile');
    print(tokenMobile);
    var subData = {
      'endpoint': "app://${platform}",
      'keys': {'auth': "", 'p256dh': ""},
      'token': tokenMobile,
      'platform': platform,
    };
    var dataJson = {'customer_id': username, 'subscription_json': subData};
    final resApi = await dio.post(
      path,
      data: dataJson,
      options: Options(validateStatus: (_) => true),
    );
    Map<String, dynamic> res = Map<String, dynamic>();
    if (resApi.statusCode == 200) {
      res = resApi.data;
    }
    return {};
  }
}
