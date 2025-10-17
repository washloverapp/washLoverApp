import 'dart:convert';
import 'package:http/http.dart' as http;

class API_account {
  static Future<Map<String, dynamic>?> fetchapiaccount() async {
    try {
      final url = Uri.parse("https://washlover-1bef6-default-rtdb.firebaseio.com/users.json");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        if (jsonBody.containsKey('data')) {
          return jsonBody['data'];
        } else {
          return jsonBody;
        }
      } else {
        print("❌ Error ${response.statusCode}: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("❗ Exception while fetching user data: $e");
      return null;
    }
  }

  static Future fetchapipoint() async {}
}
