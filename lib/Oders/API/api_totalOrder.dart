import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
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
    String phone = prefs.getString('phone') ?? '';

    /// 🔥 ดึง order JSON ที่ save ไว้
    String orderJsonString = prefs.getString('current_order') ?? '{}';

    Map<String, dynamic> orderJson = jsonDecode(orderJsonString);

    Status status = Status(status: false, messageJson: {});
    try {
      final header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final dio = Dio();
      final path = '$endpoint/api/member/update_location';

      final resApi = await dio.post(
        path,
        data: {
          "latitude": lat,
          "longitude": lng,
          "device_id": orderJson['device_id'] ?? 'not_device_id',
          "oder_app": orderJsonString, // ✅ ส่ง order เต็ม ๆ
          "total_price": orderJson['total_price'], // ราคาทั้งหมด
        },
        options: Options(
          headers: header,
          validateStatus: (_) => true,
        ),
      );

      if (resApi.statusCode == 200) {
        status.status = true;
      }

      status.messageJson = resApi.data;
    } catch (e) {
      status.messageJson = {"error": e.toString()};
    }

    return status;
  }
}

class ApiGetCart {
  /// คืนค่า List ของ cart items หรือ [] ถ้าเกิดข้อผิดพลาด
  static Future<List<dynamic>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint') ?? '';
    final phone = prefs.getString('phone') ?? '';

    if (token.isEmpty || endpoint.isEmpty || phone.isEmpty) {
      print("Missing required data in SharedPreferences");
      return [];
    }

    try {
      final dio = Dio();

      final resApi = await dio.get(
        '$endpoint/api/cart/$phone',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (resApi.statusCode == 200) {
        final data = resApi.data;

        if (data is List) {
          return data;
        } else if (data is Map && data['items'] != null) {
          return data['items'];
        }
      } else {
        print("Error: ${resApi.statusCode}");
        print("Response: ${resApi.data}");
      }
    } on DioException catch (e) {
      print("Dio error: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
    } catch (e) {
      print("Exception: $e");
    }

    return [];
  }
}

class ApiTotalorder {
  Future<Map<String, dynamic>> getSelection() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("selection");

    if (jsonString == null) {
      final mockData = {};
      prefs.setString("selection", json.encode(mockData));
      jsonString = json.encode(mockData);
    }

    final Map<String, dynamic> data = json.decode(jsonString);

    Map<int, int> parseMap(Map<String, dynamic> map) {
      final result = <int, int>{};
      map.forEach((k, v) {
        result[int.parse(k)] = v is String ? int.parse(v) : v;
      });
      return result;
    }

    return {
      "washing": data["washing"] is String
          ? int.parse(data["washing"])
          : data["washing"],
      "dryer":
          data["dryer"] is String ? int.parse(data["dryer"]) : data["dryer"],
      "temperature": data["temperature"] is String
          ? int.parse(data["temperature"])
          : data["temperature"],
      "detergent": parseMap(data["detergent"]),
      "softener": parseMap(data["softener"]),
    };
  }

  /// =======================
  /// LOAD + PROCESS
  /// =======================
  Future<OrderSummary> loadOrderSummary() async {
    final selection = await getSelection();
    final mockList = await fetchMockList();

    final washing = findSingleItem(mockList, "washing", selection["washing"]);
    final dryer = findSingleItem(mockList, "dryer", selection["dryer"]);
    final temperature =
        findSingleItem(mockList, "temperature", selection["temperature"]);

    final detergents = findMultiItems(
      mockList,
      "detergent",
      Map<int, int>.from(selection["detergent"]),
    );

    final softeners = findMultiItems(
      mockList,
      "softener",
      Map<int, int>.from(selection["softener"]),
    );

    int totalPrice = 0;
    if (washing != null) totalPrice += washing.price;
    if (dryer != null) totalPrice += dryer.price;
    if (temperature != null) totalPrice += temperature.price;

    totalPrice += detergents.fold(0, (sum, e) => sum + e.item.price * e.qty) +
        softeners.fold(0, (sum, e) => sum + e.item.price * e.qty);

    return OrderSummary(
      washing: washing,
      dryer: dryer,
      temperature: temperature,
      detergents: detergents,
      softeners: softeners,
      totalPrice: totalPrice,
    );
  }

  /// =======================
  /// FIND FUNCTIONS
  /// =======================
  MockItem? findSingleItem(List<MockItem> list, String type, int id) {
    try {
      return list.firstWhere((e) => e.type == type && e.id == id.toString());
    } catch (_) {
      return null;
    }
  }

  List<SelectedItem> findMultiItems(
      List<MockItem> list, String type, Map<int, int> selected) {
    return selected.entries.map((entry) {
      final item = list
          .firstWhere((e) => e.type == type && e.id == entry.key.toString());
      return SelectedItem(item: item, qty: entry.value);
    }).toList();
  }

  /// =======================
  /// API FETCH
  /// =======================
  Future<List<MockItem>> fetchMockList() async {
    const url =
        "https://washlover-1bef6-default-rtdb.firebaseio.com/mocklist.json";
    final response = await http.get(Uri.parse(url));
    final List data = json.decode(response.body);
    return data.map((e) => MockItem.fromJson(e)).toList();
  }

  Future<void> clearCart(OrderSummary order, String job_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String endpoint = prefs.getString('endpoint') ?? '';
    var headers = {'Authorization': 'Bearer $token'};

    var dio = Dio();
    try {
      var response = await dio.request(
        '$endpoint/api/cart/$job_id',
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        print("ลบ cart เรียบร้อย");
        // รอให้ส่ง order เสร็จก่อน
        await sendOrderItems(order, job_id);
      } else {
        print("Error ลบ cart: ${response.statusMessage}");
      }
    } catch (e) {
      print("Exception ลบ cart: $e");
    }
  }

  /// =======================
  /// API POST ITEM
  /// =======================
  Future<void> sendItemToCart(String job_id, MockItem item,
      {int qty = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = prefs.getString('endpoint') ?? '';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var data = json.encode({
      "detail": item.detail,
      "id": item.id,
      "image": item.image,
      "name": item.name,
      "price": item.price,
      "type": item.type,
      "qty": qty // ส่ง qty ด้วย
    });

    var dio = Dio();

    try {
      var response = await dio.request(
        '$endpoint/api/cart/$job_id',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print("ส่งสำเร็จ: ${json.encode(response.data)}");
      } else {
        print("Error: ${response.statusMessage}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  /// =======================
  /// ส่ง OrderSummary ทั้งหมด
  /// =======================
  Future<void> sendOrderItems(OrderSummary order, String job_id) async {
    if (order.washing != null)
      await sendItemToCart(job_id, order.washing!, qty: 1);
    if (order.dryer != null) await sendItemToCart(job_id, order.dryer!, qty: 1);
    if (order.temperature != null)
      await sendItemToCart(
        job_id,
        order.temperature!,
        qty: 1,
      );

    for (var e in order.detergents) {
      await sendItemToCart(job_id, e.item, qty: e.qty);
    }

    for (var e in order.softeners) {
      await sendItemToCart(job_id, e.item, qty: e.qty);
    }

    print("ส่ง Order สำเร็จทั้งหมด");
  }
}

/// =======================
/// MODELS
/// =======================
class MockItem {
  final String id;
  final String type;
  final String name;
  final String detail;
  final String image;
  final int price;

  MockItem({
    required this.id,
    required this.type,
    required this.name,
    required this.detail,
    required this.image,
    required this.price,
  });

  factory MockItem.fromJson(Map<String, dynamic> json) {
    return MockItem(
      id: json["id"],
      type: json["type"],
      name: json["name"],
      detail: json["detail"],
      image: json["image"],
      price: json["price"],
    );
  }
}

class SelectedItem {
  final MockItem item;
  final int qty;

  SelectedItem({required this.item, required this.qty});
}

class OrderSummary {
  final MockItem? washing;
  final MockItem? dryer;
  final MockItem? temperature;
  final List<SelectedItem> detergents;
  final List<SelectedItem> softeners;
  final int totalPrice;

  OrderSummary({
    required this.washing,
    required this.dryer,
    required this.temperature,
    required this.detergents,
    required this.softeners,
    required this.totalPrice,
  });
}
