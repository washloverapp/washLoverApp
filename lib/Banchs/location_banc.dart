import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

import 'package:my_flutter_mapwash/Banchs/API/api_location_banc.dart';

class location_banc extends StatefulWidget {
  @override
  _location_bancState createState() => _location_bancState();
}

class _location_bancState extends State<location_banc> {
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
      _loadBranchData(); // 👈 เพิ่มการโหลดสาขา
    });
  }

  // ฟังก์ชันคำนวณระยะทาง
  double _calculateDistance(LatLng position1, LatLng position2) =>
      Geolocator.distanceBetween(position1.latitude, position1.longitude,
          position2.latitude, position2.longitude) /
      1000;

  Future<void> _loadBranchData() async {
    setState(() => isLoading = true);

    final loadedBranches = await BranchService.fetchBranches();

    setState(() {
      branches = loadedBranches;
      filteredBranches = branches;
      _setMarkers();
      isLoading = false;
    });
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
      appBar: headerOrder(
        title: 'จุดบริการ',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
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
            height: 300,
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
              // onTap: () => Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BranchDetailPage2(
              //       branchCode: branch['code'],
              //       branchName: branch['name'],
              //       branchDistant: '$distanceString',
              //     ),
              //   ),
              // ),
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
              // onTap: () => Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BranchDetailPage2(
              //       branchCode: branch['code'],
              //       branchName: branch['name'],
              //       branchDistant: '$distanceString',
              //     ),
              //   ),
              // ),
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
