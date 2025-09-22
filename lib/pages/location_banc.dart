import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/pages/banc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_mapwash/pages/locatio_banch_page.dart';

class LocationBanc extends StatefulWidget {
  @override
  _LocationBancState createState() => _LocationBancState();
}

class _LocationBancState extends State<LocationBanc> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng _currentLocation = LatLng(13.7731744, 100.7057792);
  bool _locationPermissionGranted = false;
  bool _isMapView = true;
  bool isLoading = true;
  int _currentIndex = 0;
  List<Map<String, dynamic>> branches = [], filteredBranches = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // _fetchBranches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBranches();
    });
  }

  // ฟังก์ชันคำนวณระยะทาง
  double _calculateDistance(LatLng position1, LatLng position2) =>
      Geolocator.distanceBetween(position1.latitude, position1.longitude,
          position2.latitude, position2.longitude) /
      1000;

  // ดึงข้อมูลจาก API
  Future<void> _fetchBranches() async {
    try {
      final response = await http
          .get(Uri.parse('https://washlover.com/api/branch?get=2'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to load branches: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final branchData = data['data'];

      if (data['status'] == 'success' &&
          branchData is List &&
          branchData.isNotEmpty) {
        setState(() {
          branches = List<Map<String, dynamic>>.from(branchData);
          filteredBranches = branches;
          _setMarkers();
          isLoading = false;
        });

        // 🔥 เพิ่มตรงนี้: โหลดจำนวนเครื่องซัก/อบ
        await _fetchMachineCounts();
      } else {
        // API สำเร็จแต่ไม่มีข้อมูล
        print('No branches found from API. Using mock data.');
        _useMockBranches();
      }
    } catch (error) {
      // กรณี Error เช่น network, timeout
      print('Error fetching branches: $error. Using mock data.');
      _useMockBranches();
    }
  }

  void _useMockBranches() {
    setState(() {
      branches = _createMockBranches();
      filteredBranches = branches;
      _setMarkers();
      isLoading = false;
    });
    _fetchMachineCounts();
  }

  List<Map<String, dynamic>> _createMockBranches() {
    return [
      {
        'id': 'mock_1',
        'name': 'สาขาจำลอง 1 (ลาดกระบัง)',
        'latitude': '13.727895',
        'longitude': '100.775833',
        'code': 'mock001',
        'address': 'ใกล้สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง'
      },
      {
        'id': 'mock_2',
        'name': 'สาขาจำลอง 2 (สยาม)',
        'latitude': '13.746242',
        'longitude': '100.534729',
        'code': 'mock002',
        'address': 'ใจกลางสยามสแควร์'
      },
      {
        'id': 'mock_3',
        'name': 'สาขาจำลอง 3 (บางนา)',
        'latitude': '13.668221',
        'longitude': '100.633239',
        'code': 'mock003',
        'address': 'ใกล้เซ็นทรัลบางนา'
      },
    ];
  }

  Future<void> _fetchMachineCounts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://android-dcbef-default-rtdb.firebaseio.com/machines.json'),
      );
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) return;
      setState(() {
        for (var branch in branches) {
          final code = branch['code']?.toString()?.toLowerCase();

          if (data.containsKey(code)) {
            final washList = data[code]['wash'] as List?;
            final dryerList = data[code]['dryer'] as List?;

            int washCount = (washList != null)
                ? washList.where((e) => e != null).length
                : 0;
            int dryerCount = (dryerList != null)
                ? dryerList.where((e) => e != null).length
                : 0;
            branch['washCount'] = washCount;
            branch['dryerCount'] = dryerCount;
          } else {
            branch['washCount'] = 0;
            branch['dryerCount'] = 0;
          }
        }
      });
    } catch (e) {}
  }

  void _setMarkers() {
    _markers.clear(); // ลบ Marker เก่าทั้งหมด
    for (var branch in branches) {
      double latitude = double.parse(branch['latitude']);
      double longitude = double.parse(branch['longitude']);
      String branchName = branch['name']; // ชื่อสาขาจาก API

      _markers.add(Marker(
        markerId: MarkerId(branch['id']),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: branchName, // แสดงชื่อสาขา
          // snippet: branch['address'], // สามารถเพิ่มรายละเอียด เช่น ที่อยู่
        ),
      ));
    }
  }

  // ขอ permission และรับตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    // _showSingleAnimationDialog(Indicator.ballScale, true);
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationPermissionGranted = true;
    });
    _mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_currentLocation, 16.0));
    // Navigator.pop(context);
  }

  void _toggleTabView() => setState(() => _isMapView = !_isMapView);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isMapView ? _buildMapView() : _buildListView(),
          _buildOverlayButtons(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSortedBranches() {
    List<Map<String, dynamic>> sorted = [...branches];
    sorted.sort((a, b) {
      double distA = _calculateDistance(_currentLocation,
          LatLng(double.parse(a['latitude']), double.parse(a['longitude'])));
      double distB = _calculateDistance(_currentLocation,
          LatLng(double.parse(b['latitude']), double.parse(b['longitude'])));
      return distA.compareTo(distB);
    });
    return sorted;
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: _currentLocation, zoom: 16.0),
          markers: _markers,
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: _locationPermissionGranted,
          myLocationButtonEnabled: _locationPermissionGranted,
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildBranchCarousel(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final sortedBranches = _getSortedBranches();
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: ListView.builder(
        itemCount: sortedBranches.length,
        itemBuilder: (context, index) {
          final branch = sortedBranches[index];
          double distance = _calculateDistance(
            _currentLocation,
            LatLng(double.parse(branch['latitude']),
                double.parse(branch['longitude'])),
          );
          return _buildBranchCard(branch, distance);
        },
      ),
    );
  }

  Widget _buildBranchCarousel() {
    final sortedBranches = _getSortedBranches();
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 350,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) =>
                setState(() => _currentIndex = index),
          ),
          items: sortedBranches.map((branch) {
            double distance = _calculateDistance(
                _currentLocation,
                LatLng(double.parse(branch['latitude']),
                    double.parse(branch['longitude'])));
            return _buildBranchCard(branch, distance);
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sortedBranches.length,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 5),
              height: 8,
              width: _currentIndex == index ? 16 : 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? Colors.orange[400]
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch, double distance) {
    String distanceString = distance.toStringAsFixed(2);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.white,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                double lat = double.parse(branch['latitude']);
                double lng = double.parse(branch['longitude']);
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    branch['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[400],
                    ),
                  ),
                  Text('$distanceString กม.'),
                ],
              ),
            ),
            SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BranchDetailPage2(
                    branchCode: branch['code'],
                    branchName: branch['name'],
                    branchDistant: '$distanceString',
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureIcon22(
                    Icons.local_laundry_service,
                    "เครื่องซัก",
                    'assets/images/sakpa.png',
                    _isMapView,
                    number:
                        branch['washCount'] ?? 0, // 👈 ใช้ค่าที่ได้จาก Firebase
                  ),
                  _buildFeatureIcon22(
                    Icons.local_laundry_service,
                    "เครื่องอบผ้า",
                    'assets/images/ooppa2.png',
                    _isMapView,
                    number: branch['dryerCount'] ?? 0,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BranchDetailPage2(
                    branchCode: branch['code'],
                    branchName: branch['name'],
                    branchDistant: '$distanceString',
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureIcon(Icons.local_parking, "ที่จอดรถ"),
                  _buildFeatureIcon(Icons.wifi, "Wi-Fi"),
                  _buildFeatureIcon(Icons.security, "CCTV"),
                  _buildFeatureIcon(Icons.clean_hands, "ซักอบพับ"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFeatureIcon22(
      IconData icon, String label, String imageUrl, bool isMapView,
      {int number = 0}) {
    return Column(
      children: [
        if (isMapView && imageUrl.isNotEmpty)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(149, 187, 222, 251),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
              if (number >= 0)
                Positioned(
                  top: 0,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      number.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 14)),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildOverlayButtons() {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          _buildToggleButton("แผนที่", _isMapView),
          SizedBox(width: 8),
          _buildToggleButton("สาขาทั้งหมด", !_isMapView),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Expanded(
      child: ElevatedButton(
        onPressed: _toggleTabView,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.orange[300] : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(label,
            style:
                TextStyle(color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }
}
