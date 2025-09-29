import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/pages/totalOrder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class a_clothes extends StatefulWidget {
  const a_clothes({super.key});

  @override
  _a_clothesState createState() => _a_clothesState();
}

class _a_clothesState extends State<a_clothes> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> selectedOptions = {
    'clothingType': '',
    'detergent': {},
    'softener': {},
    'washingMachine': '',
    'temperature': '',
    'dryer': '',
    'note': '',
    'basketImage': '',
  };
  Widget _buildClothingType() {
    List<Map<String, dynamic>> clothingTypes = [
      {
        'image': 'assets/images/pha1.jpg',
        'name': 'เสื้อผ้า',
        'value': 1,
        'quantity': 0,
        'text': '0',
        'price': 0,
      },
      {
        'image': 'assets/images/nuam.png',
        'name': 'ชุดเครื่องนอน/ผ้านวม',
        'value': 2,
        'quantity': 0,
        'text': '1',
        'price': 120,
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: clothingTypes.length,
      itemBuilder: (context, index) {
        var item = clothingTypes[index];
        bool isSelected = selectedOptions['clothingType'] == item['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedOptions['clothingType'] = item['value'];
              print(item['value']);
              print(selectedOptions['clothingType']);
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : const Color.fromARGB(255, 227, 227, 227),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.asset(
                        item['image'],
                        width: 200,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              if (item['text'] != '1')
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop_sharp,
                          color: Colors.blue[200], size: 16),
                      SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          'closestBranch',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'เลือกรายการซัก',
          style: TextStyle(
            color: const Color.fromARGB(255, 203, 203, 203),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: PageView(
        // controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildClothingType(),
          if (selectedOptions['clothingType'] != 2) ...[],
          if (selectedOptions['clothingType'] != 1) ...[],
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: null,
              child: Text(
                "ย้อนกลับ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFC15C),
                padding: EdgeInsets.symmetric(vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: null,
              child: Text(
                "ถัดไป",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
