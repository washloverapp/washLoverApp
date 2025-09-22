import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class AddressLocation extends StatefulWidget {
  const AddressLocation({super.key});

  @override
  _AddressLocationState createState() => _AddressLocationState();
}

class _AddressLocationState extends State<AddressLocation> {
  int _selectedAddress = 0; // ตัวเลือกเริ่มต้น
  List<Map<String, dynamic>> _addresses = []; // ที่อยู่ที่ดึงมาจาก API

  @override
  void initState() {
    super.initState();
    _fetchAddressData(); // ดึงข้อมูลที่อยู่จาก API เมื่อเริ่มต้น
  }

  // ฟังก์ชันดึงข้อมูลที่อยู่จาก API
  Future<void> _fetchAddressData() async {
    try {
      final response = await http
          .get(Uri.parse('https://fakerapi.it/api/v1/addresses?quantity=5'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressList = data['data'] as List;

        setState(() {
          _addresses = addressList.map((address) {
            return {
              'title': "Address #${address['id']}",
              'subtitle':
                  "${address['street']}, ${address['city']}, ${address['country']}, ${address['zipcode']}",
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load address data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ที่อยู่', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context); // ใช้ Navigator.pop เพื่อย้อนกลับหน้าปัจจุบัน
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  _addresses.length, // ใช้ _addresses ในการสร้าง ListView
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressTile(
                  icon: Icons.map,
                  title: address['title'],
                  subtitle: address['subtitle'],
                  index: index,
                  isDefault: index == 0, // ให้ที่อยู่แรกเป็น default
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(35.0),
            child: ElevatedButton(
              onPressed: () {
                print("Proceed to Payment with address $_selectedAddress");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              ),
              child: const Text(
                "บันทึก",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    bool isDefault = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddress = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _selectedAddress == index ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color:
                _selectedAddress == index ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Default",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _selectedAddress == index
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: _selectedAddress == index ? Colors.blue : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
