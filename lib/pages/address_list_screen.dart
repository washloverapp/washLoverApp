import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/pages/edit_address_screed.dart';
import 'add_address_screen.dart'; // ไฟล์หน้าสำหรับเพิ่มที่อยู่
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late Future<List<Map<String, dynamic>>> _addressFuture;

  // ฟังก์ชันสำหรับดึงหมายเลขโทรศัพท์จาก SharedPreferences
  Future<String?> getPhoneFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  // ฟังก์ชันสำหรับดึงข้อมูลที่อยู่จาก API
  // ฟังก์ชันสำหรับดึงข้อมูลที่อยู่จาก API
  Future<List<Map<String, dynamic>>> fetchAddresses(String phone) async {
    final String apiUrl = 'https://washlover.com/api/address'; // URL ของ API
    final String url =
        '$apiUrl?phone=$phone'; // ใส่หมายเลขโทรศัพท์ในพารามิเตอร์

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // หาก API ตอบกลับเป็น 200 OK
        final responseData = json.decode(response.body);

        // ตรวจสอบว่า responseData คือ Map หรือไม่
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          // ดึงข้อมูลจากฟิลด์ 'data' และแปลงให้เป็น List
          List<Map<String, dynamic>> addressList =
              List<Map<String, dynamic>>.from(responseData['data']);
          return addressList;
        } else {
          return [];
          throw Exception('Invalid response format');
        }
      } else {
        return [];
        // หากเกิดข้อผิดพลาดในการร้องขอ
        throw Exception('Failed to load data');
      }
    } catch (e) {
      return [];
      // หากเกิดข้อผิดพลาดในการเชื่อมต่อหรือร้องขอ
      throw Exception('Error occurred: $e');
    }
  }

  // ฟังก์ชันที่เรียกใช้เมื่อหน้าโหลดขึ้นมา
  @override
  void initState() {
    super.initState();
    _addressFuture = _loadAddresses();
  }

  // ฟังก์ชันสำหรับโหลดที่อยู่จาก SharedPreferences และ API
  Future<List<Map<String, dynamic>>> _loadAddresses() async {
    String? phone = await getPhoneFromPreferences();
    if (phone != null) {
      return fetchAddresses(phone);
    } else {
      throw Exception('No phone number found in preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("รายการที่อยู่")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _addressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(), // แสดงวงกลมหมุนระหว่างที่โหลดข้อมูล
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'เกิดข้อผิดพลาด: ${snapshot.error}')); // แสดงข้อความหากเกิดข้อผิดพลาด
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(
                    'ไม่มีรายการที่อยู่ที่บันทึกไว้')); // ถ้าไม่มีข้อมูลแสดงข้อความนี้
          } else {
            // แสดงข้อมูลที่ดึงมา
            List<Map<String, dynamic>> addresses = snapshot.data!;

            // จัดลำดับให้ "ที่อยู่หลัก" (status: "active") อยู่ด้านบนสุด
            addresses.sort((a, b) {
              bool aIsActive = a['status'] == 'active';
              bool bIsActive = b['status'] == 'active';
              if (aIsActive && !bIsActive) {
                return -1; // ให้ a อยู่ก่อน b
              } else if (!aIsActive && bIsActive) {
                return 1; // ให้ b อยู่ก่อน a
              } else {
                return 0; // ถ้า status เท่ากันไม่ต้องการการจัดลำดับ
              }
            });

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                bool isActive = addresses[index]['status'] ==
                    'active'; // ตรวจสอบว่า status เป็น active หรือไม่
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(
                      Icons.location_pin,
                      color: const Color.fromARGB(255, 255, 0, 0),
                      size: 25,
                    ),
                    title: Row(
                      children: [
                        // แสดง "ที่อยู่หลัก" ถ้า status เป็น active
                        if (isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'ที่อยู่หลัก',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        SizedBox(
                            width:
                                8), // เพิ่มช่องว่างระหว่าง "ที่อยู่หลัก" และชื่อ
                        // ชื่อที่อยู่
                        Expanded(
                          child: Text(
                            addresses[index]['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // แสดงข้อมูลที่อยู่ต่อกันโดยเว้นวรรค
                        Expanded(
                          child: Text(
                            '${addresses[index]['detail']} ${addresses[index]['subdistrict']} ${addresses[index]['district']} ${addresses[index]['province']} ${addresses[index]['postcode']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                        ),
                        // เพิ่ม IconButton สำหรับการแก้ไข
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // ดึง addressId จากข้อมูลที่อยู่ที่เลือก
                            String addressId =
                                addresses[index]['id'].toString();

                            // นำทางไปหน้าจอ EditAddressScreen และส่ง addressId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditAddressScreen(addressId: addressId),
                              ),
                            ).then((_) {
                              // เรียกใช้ _loadAddresses ใหม่หลังจากกลับจากหน้า EditAddressScreen
                              setState(() {
                                _addressFuture = _loadAddresses();
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // คลิกเพื่อดูรายละเอียดที่อยู่
                      Map<String, dynamic> address = addresses[index];

                      // ส่งข้อมูล address กลับไปที่หน้าก่อนหน้า
                      Navigator.pop(context, address);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressScreen()),
          ).then((_) {
            // เรียกใช้ _loadAddresses ใหม่หลังจากกลับจากหน้า AddAddressScreen
            setState(() {
              _addressFuture = _loadAddresses();
            });
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
