import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  Position? _currentLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _subdistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  Marker? _marker;
  bool _isLoading = true;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<String?> getPhoneFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phone');
    return phone;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("โปรดเปิด GPS")));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("โปรดให้สิทธิ์การเข้าถึงตำแหน่ง")));
        return;
      }
    }

    _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLocation =
          LatLng(_currentLocation!.latitude, _currentLocation!.longitude);
      _marker = Marker(
        markerId: MarkerId("current_location"),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _isLoading = false;
    });

    _getAddressFromLatLng(_selectedLocation!);

    if (_controller != null && _selectedLocation != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 19));
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    final apiKey = 'AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey&language=th');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final addressComponents = data['results'][0]['address_components'];
        setState(() {
          _subdistrictController.text =
              _getAddressComponent(addressComponents, 'sublocality_level_2') ??
                  _getAddressComponent(addressComponents, 'locality') ??
                  '';

          _districtController.text =
              _getAddressComponent(addressComponents, 'sublocality_level_1') ??
                  _getAddressComponent(
                      addressComponents, 'administrative_area_level_2') ??
                  '';
          _provinceController.text = _getAddressComponent(
                  addressComponents, 'administrative_area_level_1') ??
              '';
          _postalCodeController.text =
              _getAddressComponent(addressComponents, 'postal_code') ?? '';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่สามารถดึงข้อมูลที่อยู่ได้")));
    }
  }

  String? _getAddressComponent(List<dynamic> addressComponents, String type) {
    try {
      return addressComponents.firstWhere((component) {
        return component['types'].contains(type);
      })['long_name'];
    } catch (e) {
      return null;
    }
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _marker = Marker(
        markerId: MarkerId("selected_location"),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMap(
          initialPosition: _selectedLocation!,
          onLocationChanged: (newLocation) {
            setState(() {
              _selectedLocation = newLocation;
              _marker = Marker(
                markerId: MarkerId("selected_location"),
                position: newLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              );
            });
            _getAddressFromLatLng(newLocation); // Update address when back
            _animateCameraToLocation(newLocation);
          },
        ),
      ),
    );
  }

  void _animateCameraToLocation(LatLng location) {
    if (_controller != null && location != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
            location, 19), // You can change the zoom level here
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
      _marker = Marker(
        markerId: MarkerId("selected_location"),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });
    _getAddressFromLatLng(_selectedLocation!);
  }

  void _onCameraIdle() {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("selected_location"),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    if (_selectedLocation != null) {
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  void _saveAddress() async {
    if (_selectedLocation != null) {
      String? phone = await getPhoneFromPreferences();
      if (phone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่พบหมายเลขโทรศัพท์")),
        );
        return;
      }

      if (_isPrimary) {
        final putUrl = Uri.parse(
            'https://washlover.com/api/updatestatusaddress/phone?phone=$phone');
        final putResponse = await http.put(
          putUrl,
          headers: {'Content-Type': 'application/json'},
        );

        if (putResponse.statusCode == 200) {
          print('สถานะที่อยู่ได้รับการอัปเดต');
        } else {
          print('ไม่สามารถอัปเดตสถานะที่อยู่');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("ไม่สามารถอัปเดตสถานะที่อยู่ได้")),
          );
          return;
        }
      }

      final data = {
        'phone': phone,
        'detail': _addressController.text,
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'subdistrict': _subdistrictController.text,
        'district': _districtController.text,
        'province': _provinceController.text,
        'postcode': _postalCodeController.text,
        'name': _nameController.text,
        'status': _isPrimary ? 'active' : 'inactive',
      };

      final response = await http.post(
        Uri.parse('https://washlover.com/api/address'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณาเลือกตำแหน่ง")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("เพิ่มที่อยู่ใหม่")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "ชื่อที่อยู่",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: "รายละเอียดที่อยู่",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _subdistrictController,
                      decoration: InputDecoration(
                        labelText: "แขวง/ตำบล",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText: "เขต/อำเภอ",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _provinceController,
                      decoration: InputDecoration(
                        labelText: "จังหวัด",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _postalCodeController,
                      decoration: InputDecoration(
                        labelText: "รหัสไปรษณีย์",
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      enabled: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text("เลือกที่อยู่หลัก"),
                        Radio<bool>(
                          value: true,
                          groupValue: _isPrimary,
                          onChanged: (value) {
                            setState(() {
                              _isPrimary = value!;
                            });
                          },
                        ),
                        Text("ใช่"),
                        Radio<bool>(
                          value: false,
                          groupValue: _isPrimary,
                          onChanged: (value) {
                            setState(() {
                              _isPrimary = value!;
                            });
                          },
                        ),
                        Text("ไม่ใช่"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation ?? LatLng(0, 0),
                zoom: 19,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              onTap: _onMapTapped,
              // onCameraMove: _onCameraMove,
              markers: _marker != null ? {_marker!} : {},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Container(
            height: 1, // ความหนาของเส้น
            decoration: BoxDecoration(
              color: const Color.fromARGB(54, 0, 0, 0), // สีของเส้น
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 230, 230, 230)
                      .withOpacity(0.9), // สีเงา
                  blurRadius: 10, // ความเบลอของเงา
                  offset: Offset(0, 2), // ทิศทางของเงา (ด้านล่าง)
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                minimumSize:
                    Size(double.infinity, 50), // ปรับขนาดให้เต็มความกว้าง
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // ปรับมุมโค้งที่นี่
                ),
              ),
              child: Text(
                "บันทึก",
                style: TextStyle(
                  fontWeight: FontWeight.bold, // ทำให้ข้อความเป็นตัวหนา
                  fontSize: 18, // ปรับขนาดฟอนต์เป็น 18
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenMap extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationChanged; // Callback function

  FullScreenMap(
      {required this.initialPosition, required this.onLocationChanged});

  @override
  _FullScreenMapState createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialPosition;
    _marker = Marker(
      markerId: MarkerId("selected_location"),
      position: _selectedLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("แผนที่เต็มจอ"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onLocationChanged(_selectedLocation!);
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? LatLng(0, 0),
              zoom: 19,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _selectedLocation = position.target;
                _marker = Marker(
                  markerId: MarkerId("selected_location"),
                  position: _selectedLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                );
              });
            },
            markers: _marker != null ? {_marker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ],
      ),
    );
  }
}
