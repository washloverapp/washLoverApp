import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApistatusRealtime {
  Future<Map<String, dynamic>?> StReal(String deviceId, String id) async {
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
        return data;
      } else {
        print('⚠️ [$id] Error: ${response.statusCode} (${response.reasonPhrase})');
        return null;
      }
    } catch (e) {
      print('❌ [$id] Error fetching destination status: $e');
      return null;
    }
  }
}

class ApistatusDriver {
  Future<Map<String, dynamic>?> stDriver(String deviceId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint');
    final url = Uri.parse('$endpoint/api/get_last_location?device_id=$deviceId');

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
        return data;
      } else {
        print('⚠️ [$id] Error: ${response.statusCode} (${response.reasonPhrase})');
        return null;
      }
    } catch (e) {
      print('❌ [$id] Error fetching destination status: $e');
      return null;
    }
  }
}

class ApiDetail {
  Future<List<dynamic>> stDetail(String deviceId, String id) async {
    print('stDetail');
    print(deviceId);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint');
    final phone = prefs.getString('phone');
    final url = Uri.parse('$endpoint/api/cart/$phone');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('data---0');
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('data');
        print(data);

        // if (data is Map && data['items'] is List) {
        //   return List<Map<String, dynamic>>.from(data['items']);
        // } else {
        //   print("⚠️ Unexpected response format: $data");
        //   return [];
        // }
      } else {
        print('⚠️ Error: ${response.statusCode} (${response.reasonPhrase})');
        return [];
      }

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   return data['items'];
      // } else {
      //   print(
      //       '⚠️ [$id] Error: ${response.statusCode} (${response.reasonPhrase})');
      //   return null;
      // }
      return [];
    } catch (e) {
      print('❌ [$id] Error fetching destination status: $e');
      return [];
    }
  }
}
