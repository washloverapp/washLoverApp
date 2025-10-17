// import 'package:firebase_database/firebase_database.dart';
// import 'package:location/location.dart';
// import 'dart:async';

// class FirebaseService {
//   final DatabaseReference _db =
//       FirebaseDatabase.instance.ref(); // เปลี่ยนเป็น ref() แทน reference()

//   late StreamSubscription<LocationData>
//       _locationSubscription; // สำหรับติดตามตำแหน่ง
//   final Location _location = Location();

//   // สตรีมข้อมูลตำแหน่งจาก Firebase
//   Stream<Map<String, dynamic>> get locationStream {
//     return _db.child('locations').onValue.map((event) {
//       Map<String, dynamic> locations = {};
//       DataSnapshot snapshot = event.snapshot;
//       if (snapshot.exists) {
//         Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
//         values.forEach((key, value) {
//           locations[key] = value;
//         });
//       }
//       return locations;
//     });
//   }

//   // อัปเดตตำแหน่งใน Firebase
//   Future<void> updateLocation(
//       String userId, double latitude, double longitude) async {
//     await _db.child('locations').child(userId).set({
//       'latitude': latitude,
//       'longitude': longitude,
//     });
//   }

//   // เริ่มติดตามตำแหน่งผู้ใช้
//   Future<void> startLocationTracking(String userId) async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     // ตรวจสอบสถานะการใช้งาน Location Services
//     serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) {
//         print("Location services are not enabled.");
//         return;
//       }
//     }

//     // ตรวจสอบการอนุญาตให้เข้าถึงตำแหน่ง
//     permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         print("Permission to access location denied.");
//         return;
//       }
//     }

//     // เริ่มติดตามตำแหน่งเมื่ออนุญาตแล้ว
//     _locationSubscription =
//         _location.onLocationChanged.listen((LocationData currentLocation) {
//       updateLocation(
//           userId, currentLocation.latitude!, currentLocation.longitude!);
//     });
//   }

//   // หยุดการติดตามตำแหน่ง
//   void stopLocationTracking() {
//     _locationSubscription.cancel();
//   }
// }
