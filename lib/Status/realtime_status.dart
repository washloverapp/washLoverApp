import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_mapwash/DirectionMap/direction_map.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_mapwash/Profile/API/api_profile.dart';
import 'package:my_flutter_mapwash/Status/API/api_realtime_status.dart';
import 'package:timeline_tile/timeline_tile.dart';

class realtime_status extends StatefulWidget {
  final String id;
  final String deviceId;
  final String price;
  final String datetime;

  const realtime_status({
    super.key,
    required this.id,
    required this.deviceId,
    required this.price,
    required this.datetime,
  });

  @override
  _realtime_statusState createState() => _realtime_statusState();
}

class _realtime_statusState extends State<realtime_status> {
  late GoogleMapController mapController;
  String travelTime = 'สถานะ';
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Map<String, dynamic> profileData = {};

  get price => widget.price;
  get deviceId => widget.deviceId;
  get datetime => widget.datetime;

  String placeName = '';

  Timer? _timer;

  Map<String, Future<Map<String, dynamic>?>> _futureCache = {};

  final List<Map<String, dynamic>> deliveryStatuses = [
    {
      'status': [
        'pending',
        'accepted',
        '1',
      ],
      'description': 'ค้นหาไรเดอร์ / ไรเดอร์รับออเดอร์'
    },
    {
      'status': ['receive', 'delivering', '2'],
      'description': 'ไรเดอร์รับของจากลูกค้า'
    },
    {
      'status': ['washing', 'completed', 'success', '3'],
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
      'status': ['return_success', '4'],
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

  List<Map<String, dynamic>> _orderDetails = [];

  String? currentStatus;
  String? statusDescription;
  DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double mapHeight = 0.0;
  @override
  void initState() {
    _sheetController.addListener(() {
      setState(() {
        mapHeight = _sheetController.pixels;
      });
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      startRealtimeUpdates();
      getDetal();
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _timer?.cancel();
    stopRealtimeUpdates();
    super.dispose();
  }

  Future<void> startRealtimeUpdates() async {
    await fetchRealtimeStatus();

    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (mounted) {
        await fetchRealtimeStatus();
      }
    });
  }

  void stopRealtimeUpdates() {
    _timer?.cancel();
  }

  double _lat = 0.0;
  double _long = 0.0;
  double _latdri = 0.0;
  double _longdri = 0.0;

  void _updateMarkersAndPolylines() {
    if (_mapController == null) return;

    double tolerance = 0.00001;
    bool samePoint = ((_lat - _latdri).abs() < tolerance) &&
        ((_long - _longdri).abs() < tolerance);
    setState(() {
      _markers.clear();
      _polylines.clear();
      _markers.addAll([
        Marker(
          markerId: MarkerId("user"),
          position: LatLng(_lat, _long),
          infoWindow: InfoWindow(title: "ผู้ใช้"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: MarkerId("driver"),
          position: LatLng(_latdri, _longdri),
          infoWindow: InfoWindow(title: "คนขับ"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      ]);
      _drawRoute();
    });
    double centerLat, centerLng;
    if ((_lat == 0.0 && _long == 0.0) || (_latdri == 0.0 && _longdri == 0.0)) {
      centerLat = 16.235080;
      centerLng = 103.260404;
    } else if (samePoint) {
      centerLat = _lat;
      centerLng = _long;
    } else {
      centerLat = (_lat + _latdri) / 2;
      centerLng = (_long + _longdri) / 2;
    }

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 16),
    );
  }

  // ฟังก์ชันหลักสำหรับดึงเส้นทางจาก API
  Future<void> _drawRoute() async {
    final directionsService = DirectionsService(
        googleApiKey:
            'AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs'); // ใส่ API Key ของคุณ
    List<LatLng> routePoints = await directionsService.getRouteCoordinates(
      startLat: _latdri,
      startLng: _longdri,
      endLat: _lat,
      endLng: _long,
    );

    if (routePoints.isNotEmpty) {
      _animatePolyline(routePoints); // เรียก animation ทีละจุด
    }
  }

  // ฟังก์ชัน animate Polyline ทีละจุด
  Future<void> _animatePolyline(List<LatLng> routePoints) async {
    List<LatLng> animatedPoints = [];
    for (var point in routePoints) {
      await Future.delayed(Duration(milliseconds: 5)); // delay 100ms ต่อจุด
      animatedPoints.add(point);

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: animatedPoints,
          ),
        );
      });
    }
  }

  Future<void> getDetal() async {
    final apiDetail = ApiDetail();
    final dtDetail = await apiDetail.stDetail(widget.deviceId, widget.id);
    _orderDetails = dtDetail as List<Map<String, dynamic>>;
  }

  Future<void> fetchRealtimeStatus() async {
    final apiCustomer = ApistatusRealtime();
    final apiDriver = ApistatusDriver();
    final data = await apiCustomer.StReal(widget.deviceId, widget.id);
    final dtDri = await apiDriver.stDriver(widget.deviceId, widget.id);
    print(data);
    if (data != null) {
      if (!mounted) return;
      setState(() {
        _lat = data['latitude'];
        _long = data['longitude'];

        _latdri = dtDri!['latitude'];
        _longdri = dtDri['longitude'];

        currentStatus = data['status'].toString();
        statusDescription = deliveryStatuses
            .firstWhere(
              (status) => status['status'].contains(currentStatus),
              orElse: () => {'description': 'สถานะไม่พบ'},
            )['description']
            .toString();
      });
      _updateMarkersAndPolylines();
      placeName = await getPlaceName(_lat, _long);
    }
  }

  Future<void> _loadProfile() async {
    try {
      Map<String, dynamic> data = await api_profile.fetchProfile();
      setState(() {
        profileData = data;
      });
    } catch (e) {
      setState(() {});
    }
  }

  Future<String> getPlaceName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // เลือกฟิลด์ที่ต้องการ
        return "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
    }

    return "ไม่พบสถานที่";
  }

  @override
  Widget build(BuildContext context) {
    double totalBeforeDiscount = 0.0;
    final member = profileData;
    double sizeH = MediaQuery.sizeOf(context).height;
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
          Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(16.235080, 103.260404),
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _updateMarkersAndPolylines();
                  },
                  markers: _markers,
                  polylines: _polylines,
                  rotateGesturesEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
              Container(
                // duration: Duration(milliseconds: 200),
                height: mapHeight > 50 ? mapHeight - 50 : sizeH * .5,
              ),
            ],
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.7,
            minChildSize: 0.2,
            maxChildSize: .9,
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
                              "สาขา: ใกล้เคียง...",
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
                                        member['phone'].toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        placeName,
                                        style: TextStyle(fontSize: 16),
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
                    SliverToBoxAdapter(
                      child: Card(
                        color: Colors.white,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: List.generate(
                              // orderDetails["order_selects"]?.length ?? 0,
                              _orderDetails.length ?? 0,
                              (index) {
                                final product = _orderDetails[index];
                                final int qty = product["qty"] ?? 0;
                                final double price =
                                    (product["price"] ?? 0).toDouble();
                                final double totalPrice = price * qty;

                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Image.asset(
                                        product["image"] ??
                                            'assets/images/default.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
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
                                        "จำนวน: $qty",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "฿${totalPrice.toStringAsFixed(2)}", // ✅ แสดงราคาสุทธิ
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
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
                                            "฿$price",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
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
                                          Text("qrcode",
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
                                    Text(
                                      "หมายเลขออเดอร์",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "$deviceId",
                                            style: TextStyle(fontSize: 14),
                                            maxLines: 2, // แสดงได้ 2 บรรทัด
                                            overflow: TextOverflow
                                                .ellipsis, // แสดง ... เมื่อข้อความยาว
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.copy),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: deviceId ?? ''))
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
                                            datetime,
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
