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
        "name": "ลดแรงกลางเดือน!",
        "detail": "ลด 10% สำหรับทุกการซักเกิน 100 บาท",
        "image":
            "https://cdn.pixabay.com/photo/2017/08/30/07/54/washing-machine-2691559_960_720.png",
        "percent": "10",
        "id": "mock-01",
        "date_start": "วันนี้",
        "date_end": "สิ้นเดือน",
      },
      {
        "name": "สมาชิกใหม่รับทันที!",
        "detail": "ส่วนลดพิเศษ 15% สำหรับการซักครั้งแรก",
        "image":
            "https://cdn.pixabay.com/photo/2013/07/13/11/49/soap-158190_960_720.png",
        "percent": "15",
        "id": "mock-02",
        "date_start": "วันนี้",
        "date_end": "31 ธ.ค.",
      },
      {
        "name": "ชวนเพื่อนซักรับโบนัส!",
        "detail": "ลดทันที 20 บาท เมื่อแนะนำเพื่อนใช้บริการ",
        "image":
            "https://cdn.pixabay.com/photo/2014/04/03/00/41/cleaning-309608_960_720.png",
        "percent": "20",
        "id": "mock-03",
        "date_start": "วันนี้",
        "date_end": "สิ้นปี",
      },
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
      [const Color(0xFFB3E5FC), const Color(0xFFF8BBD0)], // ฟ้าชมพูพาสเทล
      [const Color(0xFF81D4FA), const Color(0xFFF48FB1)], // ฟ้าเข้มชมพูสด
      [const Color(0xFF4FC3F7), const Color(0xFFE1BEE7)], // ฟ้าน้ำทะเลม่วงอ่อน
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
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // รูปโปรโมชั่น (ขนาดเล็กลงให้พอดี)
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                        child: Image.network(
                          promo['image'],
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/logo.png',
                              width: 90,
                              height: 90,
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
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                promo['detail'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ส่วนลด ${promo['percent']}%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEC407A),
                                    ),
                                  ),
                                  Text(
                                    'หมดเขต: ${promo['date_end']}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                ],
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
    );
  }
}
