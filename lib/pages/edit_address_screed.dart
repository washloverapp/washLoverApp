import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditAddressScreen extends StatefulWidget {
  final String? addressId; // รับ addressId เพื่อใช้ในการดึงข้อมูลจาก API

  EditAddressScreen({this.addressId});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<EditAddressScreen> {
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
    if (widget.addressId != null) {
      _getAddressDetails(
          widget.addressId!); // ถ้ามี addressId ให้ดึงข้อมูลที่อยู่มาแสดง
    } else {
      _getCurrentLocation(); // ถ้าไม่มี addressId ให้หาตำแหน่งปัจจุบัน
    }
  }

  Future<String?> getPhoneFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  // ฟังก์ชันดึงข้อมูลที่อยู่จาก API ตาม addressId
  Future<void> _getAddressDetails(String addressId) async {
    print('addressid $addressId');
    String? phone = await getPhoneFromPreferences();
    print('phone $phone');
    final url = Uri.parse(
        'https://washlover.com/api/address/?id=$addressId&phone=$phone'); // URL สำหรับดึงข้อมูลที่อยู่
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final addressData = data['data'][0];
        print('getdata address for edit $addressData');
        setState(() {
          _nameController.text = addressData['name'];
          _addressController.text = addressData['detail'];
          _subdistrictController.text = addressData['subdistrict'];
          _districtController.text = addressData['district'];
          _provinceController.text = addressData['province'];
          _postalCodeController.text = addressData['postcode'];
          _selectedLocation = LatLng(
            double.parse(addressData['latitude'].toString()), // แปลงเป็น double
            double.parse(
                addressData['longitude'].toString()), // แปลงเป็น double
          );
          _marker = Marker(
            markerId: MarkerId("selected_location"),
            position: _selectedLocation!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
          _isLoading =
              false; // ตั้งค่า _isLoading เป็น false เพื่อหยุดแสดงการโหลด
        });

        // เมื่อได้ค่า _selectedLocation ให้ตั้งค่าแผนที่ให้โฟกัสที่ตำแหน่งนี้
        if (_controller != null && _selectedLocation != null) {
          _controller!.animateCamera(
              CameraUpdate.newLatLngZoom(_selectedLocation!, 19));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถดึงข้อมูลที่อยู่ได้')));
      setState(() {
        _isLoading = false; // เปลี่ยนค่าเป็น false เมื่อมีข้อผิดพลาด
      });
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
    _updateAddressFromGeocode(_selectedLocation!); // เรียกใช้เพื่ออัปเดตที่อยู่
  }

  Future<void> _deleteAddress() async {
    String? phone = await getPhoneFromPreferences();
    if (phone == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ไม่พบหมายเลขโทรศัพท์")));
      return;
    }
    print('phone : $phone');
    print(widget.addressId);
    if (widget.addressId != null) {
      final deleteUrl = Uri.parse(
          'https://washlover.com/api/address/phone?phone=$phone&id=${widget.addressId}');
      final response = await http.delete(deleteUrl);

      print('response delete :  $response');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ลบที่อยู่สำเร็จ")));
        Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ไม่สามารถลบที่อยู่ได้")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ไม่พบที่อยู่ที่ต้องการลบ")));
    }
  }

  Future<void> _updateAddressFromGeocode(LatLng latLng) async {
    final apiKey =
        'AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs'; // เปลี่ยนเป็น API key ของคุณ
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey&language=th';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          // แยกข้อมูลที่อยู่
          String? subdistrict;
          String? district;
          String? province;
          String? postalCode;

          print('result :  $result');
          for (var component in result['address_components']) {
            if (component['types'].contains('sublocality_level_2') ||
                component['types'].contains('locality')) {
              subdistrict = component['long_name'];
            }
            if (component['types'].contains('sublocality_level_1') ||
                component['types'].contains('administrative_area_level_2')) {
              district = component['long_name'];
            }
            if (component['types'].contains('administrative_area_level_1')) {
              province = component['long_name'];
            }
            if (component['types'].contains('postal_code')) {
              postalCode = component['long_name'];
            }
          }

          setState(() {
            _subdistrictController.text = subdistrict ?? '';
            _districtController.text = district ?? '';
            _provinceController.text = province ?? '';
            _postalCodeController.text = postalCode ?? '';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ไม่สามารถดึงข้อมูลที่อยู่จาก Google Geocoding API'),
          ));
        }
      } else {
        throw Exception('Failed to load geocode data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อกับ API: $e'),
      ));
    }
  }

  // ฟังก์ชันบันทึกการแก้ไขที่อยู่
  void _saveAddress() async {
    if (_selectedLocation != null) {
      String? phone = await getPhoneFromPreferences();
      if (phone == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ไม่พบหมายเลขโทรศัพท์")));
        return;
      }
      if (_isPrimary) {
        final putUrl = Uri.parse(
            'https://washlover.com/api/updatestatusaddress/phone?phone=$phone');
        final putResponse = await http.put(
          putUrl,
          headers: {'Content-Type': 'application/json'},
        );

        // ตรวจสอบผลลัพธ์จากคำขอ PUT
        if (putResponse.statusCode == 200) {
          print('สถานะที่อยู่ได้รับการอัปเดต');
        } else {
          print('ไม่สามารถอัปเดตสถานะที่อยู่');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("ไม่สามารถอัปเดตสถานะที่อยู่ได้")),
          );
          return; // ถ้า PUT ล้มเหลว ให้หยุดการดำเนินการ
        }
      }

      final data = {
        'id': widget.addressId,
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

      final url = widget.addressId != null
          ? Uri.parse(
              'https://washlover.com/api/address') // ถ้ามี addressId ให้ใช้ PUT
          : Uri.parse(
              'https://washlover.com/api/address'); // ถ้าไม่มี addressId ใช้ POST สำหรับการเพิ่มที่อยู่

      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลได้')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("กรุณาเลือกตำแหน่ง")));
    }
  }

  // ฟังก์ชันที่ใช้ดึงตำแหน่งปัจจุบัน
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

    if (_controller != null && _selectedLocation != null) {
      _controller!
          .animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 19));
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
            _updateAddressFromGeocode(newLocation); // Update address when back
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

  void _onCameraIdle() {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("selected_location"),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    if (_selectedLocation != null) {
      _updateAddressFromGeocode(_selectedLocation!);
    }
  }

  void _confirmDeleteAddress() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            "ยืนยันการลบที่อยู่",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "คุณต้องการลบที่อยู่นี้หรือไม่?",
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              isDefaultAction: true,
              child: Text(
                "ยกเลิก",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAddress();
              },
              isDestructiveAction: true,
              child: Text("ลบ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("แก้ไขที่อยู่")),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "หากต้องการเปลี่ยนข้อมูลจังหวัด สามารถแก้ไขตำแหน่งได้บนแผนที่",
                      style: TextStyle(
                        color: const Color.fromARGB(
                            255, 0, 0, 0), // เปลี่ยนเป็นสีที่ต้องการ
                        fontSize: 14, // ขนาดตัวอักษรเล็กกว่า
                        fontWeight: FontWeight.normal, // ไม่ใช้ตัวหนา
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: 400,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _selectedLocation ??
                          LatLng(0, 0), // ใช้ตำแหน่งเริ่มต้นที่ถูกต้อง
                      zoom: 19,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      if (_selectedLocation != null) {
                        _controller!.animateCamera(CameraUpdate.newLatLngZoom(
                            _selectedLocation!,
                            19)); // กำหนดให้แผนที่โฟกัสที่ตำแหน่งนี้
                      }
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
            child: Row(
              children: [
                // ปุ่ม "ลบที่อยู่"
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _confirmDeleteAddress, // เรียกฟังก์ชันยืนยันก่อนลบ
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          Size(double.infinity, 50), // ปรับขนาดให้เต็มความกว้าง
                      backgroundColor: Colors.red, // ใช้สีแดง
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "ลบที่อยู่",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // เพิ่มช่องว่างระหว่างปุ่ม
                // ปุ่ม "บันทึก"
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "บันทึก",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
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
