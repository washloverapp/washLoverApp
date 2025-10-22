import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:http/http.dart' as http;

class select_Promotion extends StatefulWidget {
  const select_Promotion({super.key});
  @override
  _select_PromotionState createState() => _select_PromotionState();
}

class _select_PromotionState extends State<select_Promotion> {
  List<dynamic> promotionData = [];
  bool _isLoading = true;

  void _createMockData() {
    promotionData = [
      {
        "name": "โปรโมชั่นสุดพิเศษ",
        "detail": "ส่วนลดพิเศษสำหรับลูกค้าทุกท่าน",
        "image": "https://washlover.com/panel/img/icon-logo.png",
        "percent": "10",
        "id": "mock-01",
        "date_start": "วันนี้",
        "date_end": "สิ้นปี",
        "day": "ทุกวัน",
        "time_start": "00:00",
        "time_end": "23:59",
        "type": "daily",
        "amount": "1",
      }
    ];
  }

  Future<void> fetchPromotionData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://washlover.com/panel/promotion?get_promotion=1&type=daily&more=500'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic>? data = jsonResponse['data'];

        if (data != null && data.isNotEmpty) {
          promotionData = data.map((promo) {
            return {
              "name": promo['name'],
              "detail": promo['detail'],
              "image": promo['image'][0],
              "percent": promo['persen'],
              "id": promo['id'],
              "date_start": promo['date_start'],
              "date_end": promo['date_end'],
              "day": promo['day'],
              "time_start": promo['time_start'],
              "time_end": promo['time_end'],
              "type": promo['type'],
              "amount": promo['amount'],
            };
          }).toList();
        } else {
          _createMockData();
        }
      } else {
        throw Exception('Failed to load promotions');
      }
    } catch (e) {
      print('Error fetching promotions: $e');
      _createMockData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPromotionData();
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> gradientColors = [
      [Color(0xFFB3E5FC), Color(0xFFF8BBD0)], // ฟ้าชมพูพาสเทล
      [Color(0xFF81D4FA), Color(0xFFF48FB1)],
      [Color(0xFF4FC3F7), Color(0xFFE1BEE7)],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),
      appBar: headerOrder(
        title: 'โปรโมชั่น',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: promotionData.length,
              itemBuilder: (context, index) {
                final promo = promotionData[index];
                final colors = gradientColors[index % gradientColors.length];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(2, 3),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // รูปโปรโมชั่น
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                        child: Image.network(
                          promo['image'],
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      // เนื้อหาโปรโมชั่น
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                promo['detail'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${promo['percent']}% ส่วนลด',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEC407A),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            title: const Text(
                                              'โปรโมชั่น',
                                              style: TextStyle(
                                                  color: Color(0xFF1565C0),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: const Text(
                                                'สามารถเลือกรับโปรโมชั่นได้ก่อนทำรายการเลือกชำระเงิน'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('ตกลง'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ).copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(null),
                                      elevation: MaterialStateProperty.all(0.0),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF81D4FA),
                                            Color(0xFFF48FB1)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: const Text(
                                          "เลือก",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
