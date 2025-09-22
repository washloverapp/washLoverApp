import 'package:firebase_database/firebase_database.dart';

class OrderService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  get http => null;

  // ดึงข้อมูล Order จาก Firebase
  Future<Map<String, dynamic>> getOrderDetails(String username, String orderId) async {
    final DataSnapshot snapshot = await _db.child('order').child(username).child(orderId).get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      print('Order not found for orderId: $orderId');
      throw Exception('Order not found');
    }
  }

  // รับข้อมูลสำหรับแสดงในแผนที่
  Future<Map<String, dynamic>> getMapData(String username, String orderId) async {
    Map<String, dynamic> orderDetails = await getOrderDetails(username, orderId);
    double driverLat = 0.0;
    double driverLon = 0.0;
    double BackdriverLat = 0.0;
    double BackdriverLon = 0.0;
    if (orderDetails.containsKey('driverfirst') && orderDetails['driverfirst'] != 'null') {
      driverLat = double.parse(orderDetails['driverfirst']['latitude'].toString());
      driverLon = double.parse(orderDetails['driverfirst']['longitude'].toString());
      BackdriverLat = orderDetails['driverback'] != null && orderDetails['driverback']['latitude'] != null ? double.tryParse(orderDetails['driverback']['latitude'].toString()) ?? 0.0 : 0.0;
      BackdriverLon = orderDetails['driverback'] != null && orderDetails['driverback']['longitude'] != null ? double.tryParse(orderDetails['driverback']['longitude'].toString()) ?? 0.0 : 0.0;
    } else {
      print('Driver not assigned yet or data unavailable');
    }
    // สร้างข้อมูลที่จะใช้แสดงในแผนที่

    Map<String, dynamic> mapData = {
      'driverLat': driverLat,
      'driverLon': driverLon,
      'BackdriverLat': BackdriverLat,
      'BackdriverLon': BackdriverLon,
      'orderLat': double.parse(orderDetails['user_location']['latitude'].toString()),
      'orderLon': double.parse(orderDetails['user_location']['longitude'].toString()),
      'branchLat': double.parse(orderDetails['branch']['latitude'].toString()),
      'branchLon': double.parse(orderDetails['branch']['longitude'].toString()),
    };
    print('Map data generated: $mapData');
    return {
      'driverLat': driverLat,
      'driverLon': driverLon,
      'orderLat': double.parse(orderDetails['user_location']['latitude'].toString()),
      'orderLon': double.parse(orderDetails['user_location']['longitude'].toString()),
      'branchLat': double.parse(orderDetails['branch']['latitude'].toString()),
      'branchLon': double.parse(orderDetails['branch']['longitude'].toString()),
    };
  }
}
