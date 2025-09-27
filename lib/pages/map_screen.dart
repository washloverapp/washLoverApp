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


class StatusOrder extends StatefulWidget {
  final String orderId;

  const StatusOrder({required this.orderId});

  @override
  _StatusOrderState createState() => _StatusOrderState();
}

const List<Color> _kDefaultRainbowColors = const [
  Colors.blue,
];

class _StatusOrderState extends State<StatusOrder> {
  _showSingleAnimationDialog(Indicator indicator, bool showPathBackground) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: false,
          builder: (ctx) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(64),
                child: Center(
                  child: LoadingIndicator(
                    indicatorType: indicator,
                    colors: _kDefaultRainbowColors,
                    strokeWidth: 4.0,
                    pathBackgroundColor: showPathBackground ? Colors.black45 : null,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  late GoogleMapController mapController;
  String travelTime = 'สถานะ';
  String travelDistance = 'กำลังคำนวณระยะทาง...';
  Set<Polyline> _polylines = {};
  LatLng driverLocation = LatLng(16.243998, 103.249047);
  LatLng driverLocationBack = LatLng(16.243998, 103.249047);
  LatLng orderLocation = LatLng(16.243998, 103.249047);
  LatLng branLocation = LatLng(16.243998, 103.249047);
  late GoogleMapController _mapController;
  // final OrderService _orderService = OrderService();
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
  late Timer _timer; // ประกาศตัวแปร Timer
  @override
  void initState() {
    super.initState();
    // loadPhoneData();
    // เรียกครั้งแรกเมื่อเปิดหน้าจอ
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      loadPhoneData(); // เรียก _loadMapData() ทุกๆ 15 วินาที
    });
  }

  String? phone;

  Future<void> loadPhoneData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phonex = prefs.getString('phone');

    if (!mounted) return; // ป้องกัน setState() หรือการเรียก method อื่นถ้า widget ถูก dispose แล้ว
    if (phonex != null) {
      setState(() {
        phone = phonex;
      });

      if (mounted) {
        // _loadMapData();
      }
    } else {
      print('Phone is not available.');
    }
  }

  // Future<void> _loadMapData() async {
  //   // _showSingleAnimationDialog(Indicator.ballScale, true);

  //   try {
  //     Map<String, dynamic> mapData = await _orderService.getMapData(phone!, widget.orderId);
  //     print('mapData : $mapData');
  //     Map<String, dynamic> orderDetails = await _orderService.getOrderDetails(phone!, widget.orderId);

  //     setState(() {
  //       _orderDetails = orderDetails;
  //       currentStatus = orderDetails['status'];
  //       statusDescription = deliveryStatuses.firstWhere((status) => status['status'].contains(currentStatus), orElse: () => {'description': 'สถานะไม่พบ'})['description'].toString();
  //       LatLngBounds? bounds;
  //       // ตำแหน่งของคนขับ
  //       if (currentStatus == 'pending' || currentStatus == 'accepted' || currentStatus == 'receive' || currentStatus == 'delivering') {
  //         if (mapData['driverLat'] != null && mapData['driverLon'] != null) {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('driver'),
  //             position: LatLng(
  //               double.tryParse(mapData['driverLat'].toString()) ?? 0.0,
  //               double.tryParse(mapData['driverLon'].toString()) ?? 0.0,
  //             ),
  //             infoWindow: const InfoWindow(title: 'Driver Location'),
  //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //           ));
  //         } else {
  //           print('Driver location not available');
  //         }
  //       }
  //       if (currentStatus == 'accepted_return' || currentStatus == 'Ready_return' || currentStatus == 'Picked_Up' || currentStatus == 'send_return') {
  //         if (mapData['BackdriverLat'] != null && mapData['BackdriverLon'] != null) {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('driver'),
  //             position: LatLng(
  //               double.tryParse(mapData['BackdriverLat'].toString()) ?? 0.0,
  //               double.tryParse(mapData['BackdriverLon'].toString()) ?? 0.0,
  //             ),
  //             infoWindow: const InfoWindow(title: 'Driver Location'),
  //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //           ));
  //         } else {
  //           print('Driver location not available');
  //         }
  //       }

  //       // ตำแหน่งของคำสั่ง
  //       if (currentStatus == 'accepted' || currentStatus == 'receive' || currentStatus == 'accepted_return') {
  //         _markers.removeWhere((marker) => marker.markerId == const MarkerId('order'));
  //         if (currentStatus == 'accepted') {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('order'),
  //             position: LatLng(
  //               double.parse(mapData['orderLat'].toString()),
  //               double.parse(mapData['orderLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'Order Location'),
  //           ));
  //         }
  //         if (currentStatus == 'receive') {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('order'),
  //             position: LatLng(
  //               double.parse(mapData['branchLat'].toString()),
  //               double.parse(mapData['branchLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'Order Location'),
  //           ));
  //         }
  //         if (currentStatus == 'accepted_return') {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('order'),
  //             position: LatLng(
  //               double.parse(mapData['branchLat'].toString()),
  //               double.parse(mapData['branchLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'Order Location'),
  //           ));
  //           _markers.add(Marker(
  //             markerId: const MarkerId('order'),
  //             position: LatLng(
  //               double.parse(mapData['orderLat'].toString()),
  //               double.parse(mapData['orderLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'Order Location'),
  //           ));
  //         }
  //       } else {
  //         print('Order location not available');
  //       }
  //       // คำนวณ LatLngBounds หากมีทั้งตำแหน่ง driver และ order
  //       if (mapData['driverLat'] != null && mapData['driverLon'] != null && mapData['orderLat'] != null && mapData['orderLon'] != null) {
  //         LatLng driverPosition = LatLng(
  //           double.parse(mapData['driverLat'].toString()),
  //           double.parse(mapData['driverLon'].toString()),
  //         );
  //         LatLng orderPosition = LatLng(
  //           double.parse(mapData['orderLat'].toString()),
  //           double.parse(mapData['orderLon'].toString()),
  //         );
  //         LatLng branPosition = LatLng(
  //           double.parse(mapData['branchLat'].toString()),
  //           double.parse(mapData['branchLon'].toString()),
  //         );
  //         LatLng backdriverPosition = LatLng(
  //           double.tryParse(mapData['BackdriverLat']?.toString() ?? '') ?? 0.0,
  //           double.tryParse(mapData['BackdriverLon']?.toString() ?? '') ?? 0.0,
  //         );

  //         double minLat = min(driverPosition.latitude, orderPosition.latitude);
  //         double maxLat = max(driverPosition.latitude, orderPosition.latitude);
  //         double minLon = min(driverPosition.longitude, orderPosition.longitude);
  //         double maxLon = max(driverPosition.longitude, orderPosition.longitude);

  //         double minLatBran = min(driverPosition.latitude, branPosition.latitude);
  //         double maxLatBran = max(driverPosition.latitude, branPosition.latitude);
  //         double minxLonBran = min(driverPosition.longitude, branPosition.longitude);
  //         double maxnLonBran = max(driverPosition.longitude, branPosition.longitude);

  //         double minLatDBack = min(branPosition.latitude, orderPosition.latitude);
  //         double maxLatDBack = max(branPosition.latitude, orderPosition.latitude);
  //         double minLonDBack = min(branPosition.longitude, orderPosition.longitude);
  //         double maxLonDBack = max(branPosition.longitude, orderPosition.longitude);

  //         bounds = LatLngBounds(
  //           southwest: LatLng(minLat, minLon),
  //           northeast: LatLng(maxLat, maxLon),
  //         );
  //         if (currentStatus == 'receive' || currentStatus == 'delivering') {
  //           bounds = LatLngBounds(
  //             southwest: LatLng(minLatBran, minxLonBran),
  //             northeast: LatLng(maxLatBran, maxnLonBran),
  //           );
  //         }
  //         if (currentStatus == 'Ready_return') {
  //           bounds = LatLngBounds(
  //             southwest: LatLng(minLatDBack, minLonDBack),
  //             northeast: LatLng(maxLatDBack, maxLonDBack),
  //           );
  //         }
  //         driverLocation = LatLng(driverPosition.latitude, driverPosition.longitude);
  //         driverLocationBack = LatLng(backdriverPosition.latitude, backdriverPosition.longitude);
  //         orderLocation = LatLng(orderPosition.latitude, orderPosition.longitude);
  //         branLocation = LatLng(branPosition.latitude, branPosition.longitude);
  //       } else if (mapData['orderLat'] != null && mapData['orderLon'] != null) {
  //         // ถ้าไม่มีตำแหน่งของ driver ให้ตั้งค่า bounds สำหรับแค่ order
  //         LatLng orderPosition = LatLng(
  //           double.parse(mapData['orderLat'].toString()),
  //           double.parse(mapData['orderLon'].toString()),
  //         );
  //       }

  //       setState(() {
  //         this.driverLocation = driverLocation;
  //         this.orderLocation = orderLocation;
  //         if (orderDetails['status'] == 'receive' || orderDetails['status'] == 'delivering') {
  //           this.orderLocation = branLocation;
  //         }

  //         if (currentStatus == 'Ready_return' || currentStatus == 'Picked_Up') {
  //           this.driverLocation = branLocation;
  //           this.orderLocation = orderLocation;
  //         }
  //       });
  //       if (orderDetails['status'] != 'pending') {
  //         if (currentStatus == 'Ready_return') {
  //           _markers.add(Marker(
  //             markerId: const MarkerId('order'),
  //             position: LatLng(
  //               double.parse(mapData['orderLat'].toString()),
  //               double.parse(mapData['orderLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'order Location'),
  //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //           ));
  //         }
  //         if (currentStatus == 'completed' || currentStatus == 'success' || currentStatus == 'accepted_return') {
  //           this.travelTime = 'สถานะ';
  //           _removePolyline();
  //           _markers.removeWhere((marker) => marker.markerId == const MarkerId('order'));
  //           _markers.removeWhere((marker) => marker.markerId == const MarkerId('driver'));
  //           _markers.add(Marker(
  //             markerId: const MarkerId('branch'),
  //             position: LatLng(
  //               double.parse(mapData['branchLat'].toString()),
  //               double.parse(mapData['branchLon'].toString()),
  //             ),
  //             infoWindow: const InfoWindow(title: 'branch Location'),
  //             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //           ));
  //           _mapController.animateCamera(
  //             CameraUpdate.newLatLngZoom(
  //               LatLng(double.parse(mapData['branchLat'].toString()), double.parse(mapData['branchLon'].toString())),
  //               16.0,
  //             ),
  //           );
  //         } else {
  //           _calculateDistanceAndTime();
  //           if (bounds != null) {
  //             _mapController.animateCamera(
  //               CameraUpdate.newLatLngBounds(bounds, 80.0),
  //             );
  //             print('Zooming to show both markers or order only');
  //           } else {
  //             _mapController.animateCamera(
  //               CameraUpdate.newLatLngZoom(
  //                 LatLng(0.0, 0.0),
  //                 5.0,
  //               ),
  //             );
  //           }
  //         }
  //       } else {
  //         _markers.add(Marker(
  //           markerId: const MarkerId('order'),
  //           position: LatLng(
  //             double.parse(mapData['orderLat'].toString()),
  //             double.parse(mapData['orderLon'].toString()),
  //           ),
  //           infoWindow: const InfoWindow(title: 'order Location'),
  //           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //         ));
  //         _mapController.animateCamera(
  //           CameraUpdate.newLatLngZoom(
  //             LatLng(double.parse(mapData['orderLat'].toString()), double.parse(mapData['orderLon'].toString())),
  //             16.0,
  //           ),
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     print('Error loading map data: $e');
  //   }
  //   // Navigator.pop(context);
  // }

  // คำนวณระยะทางและเวลาโดยใช้ Google Directions API
  void _calculateDistanceAndTime() async {
    var route = await _getDirections();
    if (route != null) {
      _addPolyline(route);
    }

    String distance = await _getTravelDistance();
    String time = await _getTravelTime();

    setState(() {
      this.travelDistance = distance;
      this.travelTime = time;
    });
  }

  void _removePolyline() {
    setState(() {
      _polylines.clear();
    });
  }

// ฟังก์ชันเพื่อดึงเส้นทางจาก Google Directions API
  Future<List<LatLng>?> _getDirections() async {
    String googleApiKey = 'AIzaSyBF058dNvS_jaxJRp_buRM5DoPaVojsmEs';
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(driverLocation.latitude, driverLocation.longitude),
      destination: PointLatLng(orderLocation.latitude, orderLocation.longitude),
      mode: TravelMode.driving,
      wayPoints: [],
    );
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: request,
    );

    print('result : $result');
    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points.map((point) => LatLng(point.latitude, point.longitude)).toList();
      return polylineCoordinates;
    }

    return null;
  }

  void deletePer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('idwork_driver');
  }

// ฟังก์ชันเพื่อเพิ่ม Polyline ลงในแผนที่
  void _addPolyline(List<LatLng> polylineCoordinates) {
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        visible: true,
        points: polylineCoordinates,
        width: 5,
        color: Colors.blue,
      ));
    });
  }

// เรียกใช้ Google Directions API เพื่อคำนวณระยะทาง
  Future<String> _getTravelDistance() async {
    String apiKey = 'AIzaSyBF058dNvS_jaxJRp_buRM5DoPaVojsmEs';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${driverLocation.latitude},${driverLocation.longitude}&destination=${orderLocation.latitude},${orderLocation.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        var distance = data['routes'][0]['legs'][0]['distance']['text'];
        print('distance: $distance');
        return distance;
      }
    }
    return 'N/A';
  }

  Future<String> _getTravelTime() async {
    String apiKey = 'AIzaSyBF058dNvS_jaxJRp_buRM5DoPaVojsmEs';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${driverLocation.latitude},${driverLocation.longitude}&destination=${orderLocation.latitude},${orderLocation.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        var duration = data['routes'][0]['legs'][0]['duration']['text'];

        return duration;
      }
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    double totalBeforeDiscount = 0.0;
    if (_orderDetails != null && _orderDetails!['oder_selects'] != null) {
      totalBeforeDiscount = _orderDetails!['oder_selects'].fold(0.0, (sum, orderItem) {
        double price = double.tryParse(orderItem['price'].toString()) ?? 0.0;
        int quantity = orderItem['quantity'] ?? 0;
        return sum + (price * quantity);
      });
    } else {
      totalBeforeDiscount = 0.0;
    }
    print('_orderDetails : $_orderDetails');
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
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              await Future.delayed(Duration(seconds: 3));
              if (_orderDetails != null && _orderDetails!['driverfirst'] != null) {
                print(currentStatus);
              } else {
                print('ยังไม่มี driver');
                if (_orderDetails != null && _orderDetails!['user_location'] != null) {
                  double? orderLat = double.tryParse(_orderDetails!['user_location']['latitude'] ?? '');
                  double? orderLon = double.tryParse(_orderDetails!['user_location']['longitude'] ?? '');
                  if (orderLat != null && orderLon != null) {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(orderLat, orderLon),
                        16,
                      ),
                    );
                  } else {
                    print('orderLat หรือ orderLon เป็น null');
                  }
                } else {
                  print('orderDetails หรือ user_location เป็น null');
                }
              }
              // print('currentStatus : $currentStatus');
            },

            markers: _markers,
            //  polylines: _polylines, // เพิ่ม polyline บนแผนที่
          ),

          // เพิ่ม DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26, // สีของเงา
                      blurRadius: 10, // ระยะเบลอของเงา
                      spreadRadius: 2, // ขนาดการกระจายของเงา
                      offset: Offset(0, 3), // การขยับตำแหน่งเงา (x, y)
                    ),
                  ],
                ),
                child: _orderDetails == null
                    ? const Center(child: CircularProgressIndicator())
                    : CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header ที่แสดง icon และ title
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
                                  // รายการสถานะ (TimelineTile)
                                  ...deliveryStatuses.map((status) {
                                    bool isCurrentOrBefore = _isCurrentOrBefore(List<String>.from(status['status']!));
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 0.0),
                                      child: TimelineTile(
                                        alignment: TimelineAlign.manual,
                                        lineXY: 0.0,
                                        isFirst: status == deliveryStatuses.first,
                                        isLast: status == deliveryStatuses.last,
                                        indicatorStyle: IndicatorStyle(
                                          color: isCurrentOrBefore ? Colors.white : Colors.grey,
                                          iconStyle: IconStyle(
                                            iconData: isCurrentOrBefore ? Icons.check_circle : Icons.cancel,
                                            color: isCurrentOrBefore ? Colors.green : const Color.fromARGB(101, 158, 158, 158),
                                            fontSize: 22.0,
                                          ),
                                        ),
                                        beforeLineStyle: LineStyle(
                                          color: isCurrentOrBefore ? Colors.green : Colors.grey,
                                          thickness: 2,
                                        ),
                                        endChild: Container(
                                          margin: const EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 0.0,
                                            left: 5.0,
                                            right: 0.0,
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
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
                                    "สาขา: ${_orderDetails!['branch']['name']}",
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${_orderDetails!['user_location']['phone']}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "${_orderDetails!['user_location']['detail']}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Text(
                                              "${_orderDetails!['user_location']['subdistrict']} ${_orderDetails!['user_location']['district']} ${_orderDetails!['user_location']['province']} ${_orderDetails!['user_location']['postcode']}",
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
                                final orderItem = _orderDetails!['oder_selects'][index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    leading: Image.network(
                                      orderItem['image'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      orderItem['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '฿${orderItem['price']}',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('จำนวน: ${orderItem['quantity']}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: _orderDetails!['oder_selects'].length,
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
                                    elevation: 4, // เพิ่มเงาให้ Card
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // ทำมุมโค้งให้ Card
                                    ),
                                    margin: EdgeInsets.only(bottom: 16), // เพิ่ม margin ใต้ Card
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
                                            padding: EdgeInsets.symmetric(vertical: 8.0), // กำหนดระยะห่างเอง
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("ยอดรวมก่อนส่วนลด"),
                                                Text("฿${totalBeforeDiscount.toStringAsFixed(2)} ", style: TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("ค่าจัดส่ง"),
                                                Text("${_orderDetails!['shipping_cost'] ?? 'ฟรี'}", style: TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("ส่วนลด"),
                                                Text(
                                                  ((_orderDetails!['price_discount'] ?? "0.0") != "0.0") ? '-฿${_orderDetails!['price_discount'] ?? "0.0"}' : '0.00',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "ยอดชำระ",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "฿${(double.tryParse(_orderDetails!['price_sum'].toString())?.clamp(0, double.infinity) ?? 0.0).toStringAsFixed(2)}",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("วิธีการชำระเงิน"),
                                                Text("${_orderDetails!['payment_method'] ?? 'QrCode'}", style: TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // หมายเลขออเดอร์
                                  Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                              SizedBox(width: 8), // เพิ่มระยะห่างระหว่างข้อความและหมายเลข
                                              Spacer(),
                                              Text(
                                                "${_orderDetails!['code']}",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.copy),
                                                onPressed: () {
                                                  // คัดลอกหมายเลขออเดอร์ไปยังคลิปบอร์ด
                                                  Clipboard.setData(ClipboardData(text: _orderDetails!['code'].toString())).then((_) {
                                                    // แสดงข้อความที่คัดลอกเสร็จแล้ว
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('คัดลอกหมายเลขออเดอร์แล้ว'),
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("วันที่สั่งออเดอร์"),
                                                Text(
                                                  "${_orderDetails!['datetime']}",
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

  // Helper method to build order detail rows
  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
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
        (s) => (s['status'] as List<String>).any((item) => statusList.contains(item)),
      );
      // ตรวจสอบว่า statusIndex อยู่ก่อน currentIndex หรือไม่
      return statusIndex <= currentIndex;
    }
    return false;
  }
}
