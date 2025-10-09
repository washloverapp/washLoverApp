import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:my_flutter_mapwash/Oders/location_helper.dart';

class address_user extends StatefulWidget {
  final Function(String address, LatLng location) onLocationPicked;

  const address_user({Key? key, required this.onLocationPicked})
      : super(key: key);

  @override
  State<address_user> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<address_user> {
  GoogleMapController? mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = "แตะบนแผนที่เพื่อเลือกตำแหน่ง";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation(); // โหลดตำแหน่งเมื่อเปิดหน้า
  }

  Future<void> _loadCurrentLocation() async {
    final locationData = await location_helper.getCurrentLocation();
    if (!mounted) return; // ✅ ป้องกัน setState หลัง dispose
    if (locationData != null) {
      final LatLng currentLatLng = locationData['latlng'];
      final String currentAddress = locationData['address'];

      setState(() {
        _selectedLocation = currentLatLng;
        _selectedAddress = currentAddress;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 16),
      );
    } else {
      print('📍 ไม่สามารถโหลดตำแหน่งปัจจุบันได้');
    }
  }

  void _updateLocation(LatLng latLng) async {
    setState(() {
      _selectedLocation = latLng;
      _selectedAddress = "กำลังโหลดที่อยู่...";
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _selectedAddress =
              '${p.name}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}';
        });
      }
    } catch (e) {
      print("❌ ไม่สามารถแปลงพิกัดเป็นที่อยู่ได้: $e");
      setState(() {
        _selectedAddress = 'ไม่สามารถดึงที่อยู่ได้';
      });
    }
  }

  void _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLatLng = LatLng(location.latitude, location.longitude);

        _updateLocation(newLatLng);

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLatLng, 16),
        );
      } else {
        print("ไม่พบสถานที่: $query");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการค้นหา: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'เลือกตำแหน่ง', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context); // ใช้ Navigator.pop เพื่อย้อนกลับหน้าปัจจุบัน
        },
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "ค้นหาสถานที่หรือที่อยู่...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),

          // Google Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(13.7563, 100.5018), // Bangkok
                zoom: 16,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              onTap: (latLng) {
                _updateLocation(latLng);
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId("selected"),
                        position: _selectedLocation!,
                      )
                    }
                  : {},
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _selectedAddress,
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),

          ElevatedButton.icon(
            icon: Icon(Icons.check, color: Colors.white), // ไอคอนสีขาว
            label: Text(
              "ยืนยันตำแหน่งนี้",
              style: TextStyle(color: Colors.white , fontSize: 15), // ตัวอักษรสีขาว
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // สีพื้นหลังปุ่ม
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _selectedLocation != null
                ? () {
                    widget.onLocationPicked(
                      _selectedAddress,
                      _selectedLocation!,
                    );
                    Navigator.pop(context);
                  }
                : null,
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
