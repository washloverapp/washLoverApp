import 'dart:convert';
import 'package:http/http.dart' as http;

class API_sendwash {
  // คืนค่า clothing types
  List<Map<String, dynamic>> getClothingTypes() {
    return [
      {
        'image': 'assets/images/pha1.jpg',
        'name': 'เสื้อผ้า',
        'value': 1,
        'quantity': 0,
        'text': '0',
        'price': 0,
      },
      {
        'image': 'assets/images/nuam.png',
        'name': 'ชุดเครื่องนอน/ผ้านวม',
        'value': 2,
        'quantity': 0,
        'text': '1',
        'price': 120,
      },
    ];
  }

  List<Map<String, dynamic>> getDefaultOptions(String type) {
    return List.generate(6, (index) {
      return {
        'id': 'sample_${index + 1}',
        'name': 'กรุณาเพิ่มจากหลังบ้าน',
        'image': 'assets/images/notag.png',
        'price': 5,
        'type': type,
      };
    });
  }
}
