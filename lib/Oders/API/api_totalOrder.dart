import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Oders/API/api_saveorder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Status {
  bool status;
  Map<String, dynamic> messageJson;
  Status({required this.status, required this.messageJson});
}

class ApiPost {
  static Future<Status> updateLocation({
    required double lat,
    required double lng,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String endpoint = prefs.getString('endpoint') ?? '';
    Status status = Status(status: false, messageJson: {});

    try {
      Map<String, dynamic> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final dio = Dio();
      String path = '$endpoint/api/member/update_location';
      print(path);
      //
      // print(header);

      final resApi = await dio.post(
        path,
        data: {
          "latitude": lat,
          "longitude": lng,
          "cutomer_id": "0987654322"
        },
        options: Options(headers: header, validateStatus: (_) => true),
      );
      print(resApi);
      print(resApi.statusCode);
      if (resApi.statusCode == 200) {
        status.messageJson = resApi.data;
        status.status = true;
      } else {
        status.messageJson = resApi.data;
      }
    } catch (e) {
      print("Exception: $e");
      status.messageJson = {"error": e};

      // return false;
    }
    return status;
  }

  static Future<bool> deleteCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String endpoint = prefs.getString('endpoint') ?? '';
    String phone = prefs.getString('phone') ?? '';

    if (token.isEmpty || endpoint.isEmpty || phone.isEmpty) {
      print("Missing required data in SharedPreferences");
      return false;
    }

    try {
      final uri = Uri.parse("$endpoint/api/cart/$phone");
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Item deleted successfully");
        return true;
      } else {
        print("Delete failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception while deleting cart item: $e");
      return false;
    }
  }
}

class ApiGetCart {
  /// คืนค่า List ของ cart items หรือ [] ถ้าเกิดข้อผิดพลาด
  static Future<List<dynamic>> getCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String endpoint = prefs.getString('endpoint') ?? '';
    String phone = prefs.getString('phone') ?? '';

    if (token.isEmpty || endpoint.isEmpty || phone.isEmpty) {
      print("Missing required data in SharedPreferences");
      return [];
    }

    try {
      final uri = Uri.parse("$endpoint/api/cart/$phone");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data['items'] != null) {
          return data['items'];
        } else {
          return [];
        }
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
