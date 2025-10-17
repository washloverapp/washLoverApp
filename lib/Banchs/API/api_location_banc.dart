// branch_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BranchService {
  static Future<List<Map<String, dynamic>>> fetchBranches() async {
    try {
      final response = await http
          .get(Uri.parse('https://washlover.com/api/branch?get=2'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load branches: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final branchData = data['data'];

      if (data['status'] == 'success' &&
          branchData is List &&
          branchData.isNotEmpty) {
        return List<Map<String, dynamic>>.from(branchData);
      } else {
        // API สำเร็จแต่ไม่มีข้อมูล → ใช้ mock
        print('No branches from API. Using mock data.');
        return _createMockBranches();
      }
    } catch (e) {
      print('Error fetching branches: $e. Using mock data.');
      return _createMockBranches();
    }
  }

  static List<Map<String, dynamic>> _createMockBranches() {
    return [
      {
        'id': 'mock_1',
        'name': 'สาขาจำลอง 1 (ลาดกระบัง)',
        'latitude': '13.727895',
        'longitude': '100.775833',
        'code': 'mock001',
        'address': 'ใกล้สถาบันเทคโนโลยีฯ ลาดกระบัง'
      },
      {
        'id': 'mock_2',
        'name': 'สาขาจำลอง 2 (สยาม)',
        'latitude': '13.746242',
        'longitude': '100.534729',
        'code': 'mock002',
        'address': 'ใจกลางสยามสแควร์'
      },
      {
        'id': 'mock_3',
        'name': 'สาขาจำลอง 3 (บางนา)',
        'latitude': '13.668221',
        'longitude': '100.633239',
        'code': 'mock003',
        'address': 'ใกล้เซ็นทรัลบางนา'
      },
    ];
  }
}
