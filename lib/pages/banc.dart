import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class BranchDetailPage extends StatefulWidget {
  final String address;
  final String branch;
  final String latitude;
  final String longitude;
  final String name;
  final String distance;

  // รับค่าผ่าน constructor
  BranchDetailPage({
    required this.address,
    required this.branch,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.distance,
  });

  @override
  _BranchDetailPage createState() => _BranchDetailPage();
}

class _BranchDetailPage extends State<BranchDetailPage> {
  final Map<String, dynamic> branchData = {
    "name": "ถนนเคหะร่มเกล้า",
    "distance": "1.42 km",
    "description": "สะดวกกว่า อุ่นใจกว่า ใส่ใจบริการยิ่งกว่าเดิม",
    "imageUrl":
        "https://washlover.com/image/promotion/slid2.png?v=1231", // Replace with actual image URL
    "machines": [
      {"name": "เครื่องหมายเลข 1", "status": "กำลังใช้งาน"},
      {"name": "เครื่องหมายเลข 2", "status": "ว่าง"},
      {"name": "เครื่องหมายเลข 2", "status": "ว่าง"},
      {"name": "เครื่องหมายเลข 2", "status": "ว่าง"},
    ],
    "features": [
      {"icon": Icons.local_parking, "label": "ที่จอดรถ"},
      {"icon": Icons.wifi, "label": "ไวไฟ"},
      {"icon": Icons.videocam, "label": "กล้องวงจรปิด"},
      {"icon": LucideIcons.shirt, "label": "ซักอบพับ"},
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'สาขา',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch Info Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${widget.distance} กม.',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 10),
            // Branch Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                branchData["imageUrl"],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              branchData["description"],
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            // Machine List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "รายการ (4)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text("Filter"),
                )
              ],
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: branchData["machines"].length,
                itemBuilder: (context, index) {
                  final machine = branchData["machines"][index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/sakpa2.png'), // ใช้ภาพจากแอสเซ็ท
                        fit: BoxFit.contain, // ทำให้ภาพครอบคลุมทั้งพื้นที่
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 100),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green, // สีพื้นหลังของ badge
                                borderRadius: BorderRadius.circular(
                                    12), // ทำให้ขอบของ badge เป็นโค้ง
                              ),
                              child: Text(
                                machine["name"], // ข้อความของ badge
                                style: TextStyle(
                                  color: Colors.white, // สีของข้อความใน badge
                                  fontSize: 12, // ขนาดตัวอักษร
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Features Section
            const Text(
              "สิ่งอำนวยความสะดวก",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: branchData["features"].map<Widget>((feature) {
                return Column(
                  children: [
                    Icon(
                      feature["icon"],
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature["label"],
                      style: const TextStyle(fontSize: 12),
                    )
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
