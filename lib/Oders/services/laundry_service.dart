import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Oders/models/laundry_item.dart';

class LaundryService {
  static const String baseUrl =
      'https://washlover-1bef6-default-rtdb.firebaseio.com/mocklist.json';

  Future<List<LaundryItem>> fetchLaundryItems() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => LaundryItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load laundry items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching laundry items: $e');
    }
  }

  List<LaundryItem> getItemsByType(List<LaundryItem> items, String type) {
    return items.where((item) => item.type == type).toList();
  }
}
