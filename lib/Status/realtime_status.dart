import 'dart:async';
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_mapwash/order_service.dart';
// import '../icon_helper.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // เพิ่มการนำเข้าคลาส dart:math
import 'dart:ui' as ui;
import 'package:timeline_tile/timeline_tile.dart';

class realtime_status extends StatefulWidget {
  final String = 'WL504052635n0V6i';

  // const realtime_status({required this.orderId});

  @override
  _realtime_statusState createState() => _realtime_statusState();
}

class _realtime_statusState extends State<realtime_status> {
  late GoogleMapController mapController;
  String travelTime = 'สถานะ';
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Map<String, dynamic>? _orderDetails;

  final List<Map<String, dynamic>> deliveryStatuses = [
    {
      'status': ['pending', 'accepted'],
      'description': 'ค้นหาไรเดอร์ / ไรเดอร์รับออเดอร์'
    },
    {
      'status': ['receive', 'delivering'],
      'description': 'ไรเดอร์รับของจากลูกค้า'
    },
    {
      'status': ['washing', 'completed', 'success'],
      'description': 'กำลังซัก'
    },
    {
      'status': [
        // 'success',
        'accepted_return',
        'Ready_return',
        'Picked_Up',
        'send_return'
      ],
      'description': 'ไรเดอร์กำลังนำส่งคืนลูกค้า'
    },
    {
      'status': ['return_success'],
      'description': 'ส่งคืนลูกค้าเรียบร้อย'
    },
  ];

  final List<String> statusList = [
    'pending',
    'accepted',
    'receive',
    'delivering',
    'completed',
    'washing',
    'success',
    'accepted_return',
    'Ready_return',
    'Picked_Up',
    'send_return',
    'return_success',
  ];

  // สถานะปัจจุบัน
  String? currentStatus;
  String? statusDescription;
  @override
  void initState() {
    super.initState();
    loadMapData23();
  }

  Map<String, dynamic> orderDetails = {
    "branch": {
      "address":
          "ปาก ซ. เคหะร่มเกล้า 64 แขวงคลองสองต้นนุ่น เขตลาดกระบัง กรุงเทพมหานคร 10520",
      "branch": "สาขาคุณส้มร่มเกล้า60",
      "code": "WASHLOVER03",
      "latitude": "13.766100",
      "longitude": "100.722459",
      "name": "สาขาคุณส้มร่มเกล้า60"
    },
    "code": "WL504052635n0V6i",
    "datetime": "2025-04-05 17:26:35",
    "driverback": {
      "date_end": "2025-05-08 15:55:34",
      "date_start": "2025-05-08 14:14:51",
      "latitude": "13.772925",
      "longitude": "100.70642",
      "name": "Wirun khomsai",
      "phone": "0933697840",
      "status": "send_return",
      "username": "0933697840"
    },
    "driverfirst": {
      "date_end": "2025-04-30 11:54:28",
      "date_start": "2025-04-30 11:54:01",
      "latitude": "13.7731941",
      "longitude": "100.7057937",
      "name": "Wirun khomsai",
      "phone": "0933697840",
      "status": "completed",
      "username": "0933697840"
    },
    "image": "https://washlover.com/image/logo.png?v=6",
    "name": "wi",
    "note": "",
    "order_selects": [
      {
        "code": "PD2999343453",
        "detail": "เอสเซ้นส์ คลีน แอนด์ แคร์",
        "id": "79",
        "image": "assets/images/notag.png",
        "name": "เอสเซ้นส์ คลีน แอนด์ แคร์",
        "price": "5.00",
        "quantity": 2,
        "type": "detergent"
      },
      {
        "code": "PD1652982682",
        "detail": "ดาวน์นี่ สวนดอกไม้ผลิ",
        "id": "83",
        "image": "assets/images/notag.png",
        "name": "ดาวน์นี่ สวนดอกไม้ผลิ",
        "price": "5.00",
        "quantity": 2,
        "type": "softener"
      },
      {
        "code": "PD5540564541",
        "detail": "ขนาด 12 kg.",
        "id": "88",
        "image": "assets/images/sakpa.png",
        "name": "ขนาด 12 kg.",
        "price": "40.00",
        "quantity": 1,
        "type": "washing"
      },
      {
        "code": "PD3251613700",
        "detail": "น้ำเย็น (COOL) +0 บาท",
        "id": "76",
        "image": "assets/images/water03.png",
        "name": "น้ำเย็น (COOL) +0 บาท",
        "price": "0.00",
        "quantity": 1,
        "type": "temperature"
      },
      {
        "code": "PD6425321185",
        "detail": "ขนาด 16 kg. 32 นาที",
        "id": "74",
        "image": "assets/images/ooppa2.png",
        "name": "ขนาด 16 kg.",
        "price": "40.00",
        "quantity": 1,
        "type": "dryer"
      }
    ],
    "phone": "0611211910",
    "price_discount": "99",
    "price_sum": "1.00",
    "status": "send_return",
    "user_location": {
      "detail": "",
      "district": "อำเภอบางพลี",
      "latitude": "13.676105",
      "longitude": "100.71839",
      "name": "Wash",
      "phone": "0611211910",
      "postcode": "10540",
      "province": "สมุทรปราการ",
      "subdistrict": "ตำบลราชาเทวะ"
    }
  };
  Future<void> loadMapData23() async {
    try {
      setState(() {
        _orderDetails = orderDetails;
        currentStatus = orderDetails['status'];
        statusDescription = deliveryStatuses
            .firstWhere((status) => status['status'].contains(currentStatus),
                orElse: () => {'description': 'สถานะไม่พบ'})['description']
            .toString();
      });
    } catch (e) {
      print('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalBeforeDiscount = 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'รายละเอียดออเดอร์',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(16.235080, 103.260404),
              zoom: 16,
            ),
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              setState(() {
                _markers.addAll([
                  Marker(
                    markerId: MarkerId("start"),
                    position: LatLng(16.235080, 103.260404),
                    infoWindow: InfoWindow(title: "จุดเริ่มต้น"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                  Marker(
                    markerId: MarkerId("end"),
                    position: LatLng(16.237000, 103.263000),
                    infoWindow: InfoWindow(title: "จุดสิ้นสุด"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                ]);
                _polylines.add(
                  Polyline(
                    polylineId: PolylineId("route"),
                    color: Colors.blue,
                    width: 5,
                    points: [
                      LatLng(16.235080, 103.260404),
                      LatLng(16.236000, 103.261000),
                      LatLng(16.237000, 103.263000),
                    ],
                  ),
                );
              });
            },
            markers: _markers,
            polylines: _polylines,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                const SizedBox(width: 8.0),
                                Text('$statusDescription : ( $travelTime )'),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            ...deliveryStatuses.map((status) {
                              bool isCurrentOrBefore = _isCurrentOrBefore(
                                  List<String>.from(status['status']!));
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 0.0),
                                child: TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.0,
                                  isFirst: status == deliveryStatuses.first,
                                  isLast: status == deliveryStatuses.last,
                                  indicatorStyle: IndicatorStyle(
                                    color: isCurrentOrBefore
                                        ? Colors.white
                                        : Colors.grey,
                                    iconStyle: IconStyle(
                                      iconData: isCurrentOrBefore
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: isCurrentOrBefore
                                          ? Colors.green
                                          : const Color.fromARGB(
                                              101, 158, 158, 158),
                                      fontSize: 22.0,
                                    ),
                                  ),
                                  beforeLineStyle: LineStyle(
                                    color: isCurrentOrBefore
                                        ? Colors.green
                                        : Colors.grey,
                                    thickness: 2,
                                  ),
                                  endChild: Container(
                                    margin: const EdgeInsets.only(
                                      top: 10.0,
                                      bottom: 0.0,
                                      left: 5.0,
                                      right: 0.0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 7.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Text(status['description']!),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Divider(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // แสดงชื่อสาขา
                            Text(
                              "สาขา: สาขาดอนเมือง",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "ที่อยู่สำหรับการจัดส่ง:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.green[400],
                                  size: 25,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "0987654321 ",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "หทัยราษฎร์-ไทยรามัญ",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "VPW4+XC9 แขวงสามวาตะวันตก เขตคลองสามวา กรุงเทพมหานคร 10510",
                                        softWrap: true,
                                        style: TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = orderDetails["order_selects"][index];

                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(12),
                              leading: Image.asset(
                                product["image"] ?? 'assets/images/default.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image),
                              ),
                              title: Text(
                                product["name"] ?? "ไม่มีชื่อสินค้า",
                                style: TextStyle(fontSize: 14),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                "฿${product["price"] ?? 0} บาท",
                                style: TextStyle(color: Colors.red),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("จำนวน: ${product["qty"] ?? 0}"),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: orderDetails["order_selects"]?.length ?? 0,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // สรุปคำสั่งซื้อ
                            Card(
                              color: Colors.grey[100],
                              elevation: 1, // เพิ่มเงาให้ Card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // ทำมุมโค้งให้ Card
                              ),
                              margin: EdgeInsets.only(
                                  bottom: 16), // เพิ่ม margin ใต้ Card
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "สรุปคำสั่งซื้อ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("ยอดรวมก่อนส่วนลด"),
                                          Text(
                                            "฿${totalBeforeDiscount.toStringAsFixed(2)}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("ค่าจัดส่ง"),
                                          Text(
                                            "ฟรี",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("ส่วนลด"),
                                          Text(
                                            "0.00",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "ยอดชำระ",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "฿0.00",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // การชำระเงิน
                            Card(
                              color: Colors.grey[100],
                              elevation: 1, // เพิ่มเงาให้ Card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // ทำมุมโค้งให้ Card
                              ),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "การชำระเงิน",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("วิธีการชำระเงิน"),
                                          Text("QrCode",
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // หมายเลขออเดอร์
                            Card(
                              color: Colors.grey[100],
                              elevation: 1, // เพิ่มเงาให้ Card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // ทำมุมโค้งให้ Card
                              ),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "หมายเลขออเดอร์",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Spacer(),
                                        Text(
                                          "#sefkeefsef",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.copy),
                                          onPressed: () {
                                            Clipboard.setData(
                                                    ClipboardData(text: 'code'))
                                                .then((_) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'คัดลอกหมายเลขออเดอร์แล้ว'),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("วันที่สั่งออเดอร์"),
                                          Text(
                                            "datetime",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isCurrentOrBefore(List<String> statusList) {
    // เช็คว่า currentStatus อยู่ใน statusList หรือไม่
    if (statusList.contains(currentStatus)) return true;
    // เช็คกรณีที่ deliveryStatuses ไม่ว่างเปล่า
    if (deliveryStatuses.isNotEmpty) {
      // หาค่าของ currentIndex โดยเช็คว่า currentStatus อยู่ใน List ของ 'status'
      int currentIndex = deliveryStatuses.indexWhere(
        (s) => (s['status'] as List<String>).contains(currentStatus),
      );
      // หาค่าของ statusIndex โดยเช็คว่า status ที่ส่งมามีอยู่ใน List ของ 'status'
      int statusIndex = deliveryStatuses.indexWhere(
        (s) => (s['status'] as List<String>)
            .any((item) => statusList.contains(item)),
      );
      // ตรวจสอบว่า statusIndex อยู่ก่อน currentIndex หรือไม่
      return statusIndex <= currentIndex;
    }
    return false;
  }
}
