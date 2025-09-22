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

  List<Map<String, dynamic>> machines = [];
  List<Map<String, dynamic>> dryer = [];

  Future<void> fetchData() async {
    final String currentBranch = branch;
    final washUrl = Uri.parse('https://cdn.all123th.com/wash');
    final branchUrl = Uri.parse(
        'https://android-dcbef-default-rtdb.firebaseio.com/machines.json');

    try {
      final washResponse = await http.get(washUrl);
      final branchResponse = await http.get(branchUrl);

      if (washResponse.statusCode == 200 && branchResponse.statusCode == 200) {
        final List<dynamic> machineData =
            json.decode(utf8.decode(washResponse.bodyBytes));
        final Map<String, dynamic> branchData =
            json.decode(utf8.decode(branchResponse.bodyBytes));

        branch = currentBranch; // แก้ตรงนี้หากเปลี่ยนสาขา

        if (!branchData.containsKey(branch)) {
          throw Exception('ไม่พบข้อมูลสาขา "$branch"');
        }

        final List<String> washIds =
            (branchData[branch]["wash"] ?? []).whereType<String>().toList();
        final List<String> dryerIds =
            (branchData[branch]["dryer"] ?? []).whereType<String>().toList();

        List<Map<String, dynamic>> machinesTemp = [];
        List<Map<String, dynamic>> dryerTemp = [];

        // แปลง machineData เป็น Map เพื่อเข้าถึงง่ายด้วย client_id
        final Map<String, dynamic> allMachinesMap = {
          for (var item in machineData)
            if (item['client_id'] != null) item['client_id']: item
        };

        // เครื่องซัก (เรียงตามลำดับ client_id จาก Firebase)
        for (int i = 0; i < washIds.length; i++) {
          final id = washIds[i];
          if (id == null || !allMachinesMap.containsKey(id)) continue;

          final item = allMachinesMap[id];
          machinesTemp.add({
            'name': 'เครื่องซัก',
            'isAvailable': (item['status'] == 'Standby' &&
                (item['error_status'] == 'Normal' ||
                    item['error_status'] == 'normal')),
            'imageUrl': item['status'] == 'Autorun'
                ? 'https://cdn.all123th.com/images/autorun2.gif'
                : 'https://washlover.com/uploads/sakpa2.png',
            'number': i + 1,
            'client_id': id,
          });
        }

        // เครื่องอบ (เรียงตามลำดับ client_id จาก Firebase)
        for (int i = 0; i < dryerIds.length; i++) {
          final id = dryerIds[i];
          if (id == null || !allMachinesMap.containsKey(id)) continue;

          final item = allMachinesMap[id];
          dryerTemp.add({
            'name': 'เครื่องอบ',
            'isAvailable': (item['status'] == 'Standby' &&
                (item['error_status'] == 'Normal' ||
                    item['error_status'] == 'normal')),
            'imageUrl': 'https://washlover.com/uploads/ooppa2.png',
            'number': i + 1,
            'client_id': id,
          });
        }

        if (!mounted) return;
        setState(() {
          machines = machinesTemp;
          dryer = dryerTemp;
          loading = false;
        });
      } else {
        throw Exception(
            'โหลดข้อมูลล้มเหลว (${washResponse.statusCode}, ${branchResponse.statusCode})');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
      if (!mounted) return; // หยุดทำงานถ้า widget ถูก dispose แล้ว
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    branch = widget.branchCode;
    branchName = widget.branchName;
    branchDistant = widget.branchDistant;
    fetchData();
    // เรียกซ้ำทุก 5 วินาที
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      fetchData();
    });
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
                    Text('รายการ (${machines.length})',
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
                    Text('รายการ (${dryer.length})',
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
              Image.network(
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
