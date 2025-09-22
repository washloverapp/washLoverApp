import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ฟังก์ชันคำนวณระยะทางด้วยสูตร Haversine
double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000; // รัศมีโลกในหน่วยเมตร
  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);

  double a = (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          (sin(dLon / 2) * sin(dLon / 2));
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c; // ผลลัพธ์เป็นเมตร
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}

Future<List<Map<String, dynamic>>> fetchBranches() async {
  final response =
      await http.get(Uri.parse('https://washlover.com/api/branch?get=2'));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'success' && data['data'] != null) {
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('ไม่สามารถดึงข้อมูลสาขา');
    }
  } else {
    throw Exception('ไม่สามารถเชื่อมต่อ API');
  }
}

// ฟังก์ชันหาใกล้ที่สุดที่อยู่ในรัศมี
Future<String> findClosestBranch(
    Position currentPosition, BuildContext context) async {
  List<Map<String, dynamic>> branches = await fetchBranches();
  double closestDistance = double.infinity;
  String closestBranch = 'ไม่พบสาขาที่ใกล้ที่สุด';

  for (var branch in branches) {
    double lat = double.parse(branch['latitude']);
    double lon = double.parse(branch['longitude']);
    double distance = haversineDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      lat,
      lon,
    );

    if (distance <= double.parse(branch['distance'])) {
      // เช็คว่าอยู่ในรัศมีที่กำหนด
      if (distance < closestDistance) {
        closestDistance = distance;
        closestBranch = 'สาขา : ${branch['name']}'; // เลือกสาขาที่ใกล้ที่สุด
      }
    }
  }
  return closestBranch;
}

class FindBranchScreen extends StatefulWidget {
  const FindBranchScreen({super.key});

  @override
  _FindBranchScreenState createState() => _FindBranchScreenState();
}

class _FindBranchScreenState extends State<FindBranchScreen> {
  String closestBranch = 'กำลังค้นหาสาขาที่ใกล้ที่สุด...';
  late Position currentPosition;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  // ฟังก์ชันเพื่อรับตำแหน่งปัจจุบัน
  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = position;
    });
    _findClosestBranch();
  }

  // ฟังก์ชันหาสาขาที่ใกล้ที่สุด
  Future<void> _findClosestBranch() async {
    String branch = await findClosestBranch(currentPosition, context);
    setState(() {
      closestBranch = branch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "ค้นหาสาขาที่ใกล้ที่สุด",
          style: TextStyle(
            color: const Color.fromARGB(255, 203, 203, 203),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Text(
          closestBranch,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FindBranchScreen(),
  ));
}
