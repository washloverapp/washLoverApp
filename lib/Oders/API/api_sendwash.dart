import 'dart:convert';
import 'package:http/http.dart' as http;

class API_sendwash {
  // คืนค่า clothing types
  List<Map<String, dynamic>> getClothingTypes() {
    return [
      {
        'image': 'assets/images/pha1.jpg',
        'name': 'เสื้อผ้า',
        'detail': 'เสื้อผ้า',
        'value': 1,
        'quantity': 0,
        'text': '0',
        'price': 0,
      },
      {
        'image': 'assets/images/nuam.png',
        'name': 'ชุดเครื่องนอน/ผ้านวม',
        'detail': 'ชุดเครื่องนอน/ผ้านวม',
        'value': 2,
        'quantity': 0,
        'text': '1',
        'price': 120,
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getDefaultOptions(
      String type) async {
    final url = Uri.parse(
        'https://washlover-1bef6-default-rtdb.firebaseio.com/mocklist.json');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load mock list');
    }
    final data = json.decode(response.body);
    if (data is List) {
      return data
          .where((item) => item['type'] == type)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      return data.values
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => item['type'] == type)
          .toList();
    }
    return [];
  }
}
