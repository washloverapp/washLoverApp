import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class BranchDetailPage2 extends StatefulWidget {
  final String branchCode;
  final String branchName;
  final String branchDistant;
  const BranchDetailPage2(
      {Key? key,
      required this.branchCode,
      required this.branchName,
      required this.branchDistant})
      : super(key: key);
  @override
  _BranchDetailPage2State createState() => _BranchDetailPage2State();
}

class _BranchDetailPage2State extends State<BranchDetailPage2> {
  late String branch;
  late String branchName;
  late String branchDistant;
  List washMachines = [];
  List dryMachines = [];
  bool loading = true;
  Timer? timer;

  List<Map<String, dynamic>> machines = [
    {
      'client_id': 'CL001',
      'isAvailable': true,
      'imageUrl': 'assets/images/sakpa.png',
      'number': 0,
    },
    {
      'client_id': 'CL002',
      'isAvailable': false,
      'imageUrl': 'assets/images/sakpa.png',
      'number': 1,
    },
    {
      'client_id': 'CL003',
      'isAvailable': true,
      'imageUrl': 'assets/images/sakpa.png',
      'number': 2,
    },
  ];

  List<Map<String, dynamic>> dryer = [
    {
      'client_id': 'CL001',
      'isAvailable': true,
      'imageUrl': 'assets/images/ooppa2.png',
      'number': 0,
    },
    {
      'client_id': 'CL002',
      'isAvailable': false,
      'imageUrl': 'assets/images/ooppa2.png',
      'number': 1,
    },
    {
      'client_id': 'CL003',
      'isAvailable': true,
      'imageUrl': 'assets/images/ooppa2.png',
      'number': 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    branch = widget.branchCode;
    branchName = widget.branchName;
    branchDistant = widget.branchDistant;
  }

  @override
  void dispose() {
    timer?.cancel(); // ยกเลิก Timer ตอน widget ถูก dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'รายละเอียดสาขา',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        color: Colors.white, // กำหนดพื้นหลังสีขาวให้ body
        child: SingleChildScrollView(
          child: Column(
            children: [
              // สาขาและระยะทาง
              ListTile(
                leading: Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                title: Text('$branchName'),
                subtitle: Text('$branchDistant กม.'),
                trailing: Icon(
                  Icons.directions,
                  color: Colors.blue,
                ),
              ),

              // รูปภาพสาขา
              Container(
                margin: EdgeInsets.all(10),
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://washlover.com/image/promotion/slid2.png?v=1231',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // คำโปรย
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'สะดวกกว่า อุ่นใจกว่า ให้เราดูแล',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              // รายการเครื่องซัก
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('รายการ (3)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(
                      Icons.wash_outlined,
                      color: Colors.blue,
                    ),
                    Text(' เครื่องซัก'),
                  ],
                ),
              ),

              // Card แสดงเครื่องซัก
              Container(
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: machines.length,
                  itemBuilder: (context, index) {
                    final machine = machines[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: machineCard(
                        'เครื่องซัก',
                        machine['client_id'],
                        machine['isAvailable'],
                        machine['imageUrl'],
                        machine['number'],
                      ),
                    );
                  },
                ),
              ),

              // อบ
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('รายการ (3)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(
                      Icons.hot_tub,
                      color: Colors.orange,
                    ),
                    Text(' เครื่องอบ'),
                  ],
                ),
              ),

              // Card อบ
              Container(
                height: 240,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dryer.length,
                  itemBuilder: (context, index) {
                    final machine = dryer[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: machineCard(
                        'เครื่องอบ',
                        machine['client_id'],
                        machine['isAvailable'],
                        machine['imageUrl'],
                        machine['number'],
                      ),
                    );
                  },
                ),
              ),

              // สิ่งอำนวยความสะดวก
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    facilityIcon(Icons.local_parking, 'ที่จอดรถ'),
                    facilityIcon(Icons.wifi, 'ไวไฟ'),
                    facilityIcon(Icons.videocam, 'CCTV'),
                    facilityIcon(Icons.clean_hands, "ซักอบพับ"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget machineCard(String title, String clientId, bool isAvailable,
      String imageUrl, int number) {
    return Container(
      width: 250,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFE3F2FD), // สีฟ้าอ่อน
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // รูปภาพฝั่งซ้าย
              Image.asset(
                imageUrl,
                width: 90,
                // height: 80,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 12),

              // ข้อความฝั่งขวา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.right,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 30.0), // เพิ่มความสูงด้านบนเล็กน้อย
                      child: Text(
                        clientId,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey, // สีตัวหนังสือเป็นสีเทา
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (isAvailable)
                      Text("ว่าง",
                          style: TextStyle(color: Colors.green, fontSize: 16))
                    else
                      Text("ไม่ว่าง",
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 2,
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget facilityIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
