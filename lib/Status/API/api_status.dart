import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class api_status {
  // ดึงประวัติจาก API
  static Future<List<dynamic>> fetchstatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String endpoint = prefs.getString('endpoint') ?? '';

    try {
      final response = await http.get(
        Uri.parse("${endpoint}/api/member/history"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print("$token");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> listData = [];

        if (data is List) {
          listData = data;
        } else if (data is Map && data['data'] != null) {
          listData = data['data'];
        }

        // กรองเอา status ที่ไม่เท่ากับ 4
        final filteredData = listData.where((item) {
          return item['status'] != 4;
        }).toList();

        return filteredData;
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }
}

class ApistatusOrder {
  /// ดึงสถานะปลายทางของอุปกรณ์ (device)
  Future<Map<String, dynamic>?> fetchDestinationStatus(
      String deviceId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint');

    final url = Uri.parse('$endpoint/api/get_destination?device_id=$deviceId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ApisCartjob().getCartTotalPrice(deviceId);
        return data;
      } else {
        print(
            '⚠️ [$id] Error: ${response.statusCode} (${response.reasonPhrase})');
        return null;
      }
    } catch (e) {
      print('❌ [$id] Error fetching destination status: $e');
      return null;
    }
  }
}

class ApisCartjob {
  /// ดึงสถานะปลายทางของอุปกรณ์ (device) แบบไม่ใช้ token
  Future<String> getCartTotalPrice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint');

    final dio = Dio();
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await dio.get(
        '$endpoint/api/cart/$deviceId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List items = data['items'];

        int total = 0;
        for (final item in items) {
          total += (item['price'] as int) * (item['qty'] as int);
        }

        return total.toString(); // << ส่งกลับเป็น String
      }
    } catch (e) {
      print("getCartTotalPrice error: $e");
    }

    return '0';
  }
}
