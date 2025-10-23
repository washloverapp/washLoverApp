import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  late GoogleMapController mapController;

  // พิกัดบริษัท
  final LatLng _center = const LatLng(16.197256, 103.282474);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ===== ฟังก์ชันเปิด Google Maps App =====
  Future<void> _openInGoogleMaps() async {
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_center.latitude},${_center.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
      );
    }
  }

  // ===== ฟังก์ชันโทร / เปิดลิงก์ / ส่งอีเมล =====
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดลิงก์นี้ได้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ติดต่อเรา',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Stack(
        children: [
          // ===== พื้นหลัง Gradient =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(169, 165, 227, 255),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ===== เพิ่มไอคอนดาว หัวใจ วงกลม =====
          ...List.generate(18, (index) {
            final random = index * 57.3;
            final top = (random * 7) % screenSize.height;
            final left = (random * 13) % screenSize.width;
            final size = 18 + (random % 32);
            return Positioned(
              top: top,
              left: left,
              child: _bubble(size),
            );
          }),

          // ===== เนื้อหาหลัก =====
          SingleChildScrollView(
            child: Column(
              children: [
                // ===== Google Map =====
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 16.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('company'),
                        position: _center,
                        infoWindow: const InfoWindow(
                          title: 'บริษัท เอส.เอ เซอร์วิส อินดัสทรีส์ จำกัด',
                          snippet: 'Wash Lover HQ',
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                  ),
                ),

                // ===== ปุ่มเปิดใน Google Maps =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton.icon(
                    onPressed: _openInGoogleMaps,
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'เปิดใน Google Maps',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0047BA),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const Divider(thickness: 1.2),

                // ===== ข้อมูลบริษัท =====
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'บริษัท เอส.เอ เซอร์วิส อินดัสทรีส์ จำกัด',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0047BA),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '888/1 หมู่ที่ 3 ตำบลท่าขอนยาง อ.กันทรวิชัย จ.มหาสารคาม 44150',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ===== ช่องทางการติดต่อ =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _contactRow(
                        icon: Icons.facebook,
                        label: 'WASH LOVER',
                        color: const Color(0xFF1877F2),
                        onTap: () =>
                            _launch('https://facebook.com/washlover247'),
                      ),
                      _contactRow(
                        icon: Icons.chat_bubble_outline,
                        label: '@washlover247 (LINE)',
                        color: const Color(0xFF06C755),
                        onTap: () =>
                            _launch('https://line.me/R/ti/p/@washlover247'),
                      ),
                      _contactRow(
                        icon: Icons.email_outlined,
                        label: 'washlover247@gmail.com',
                        color: const Color(0xFF0047BA),
                        onTap: () => _launch('mailto:washlover247@gmail.com'),
                      ),
                      _contactRow(
                        icon: Icons.phone,
                        label: '080-339-6668',
                        color: const Color(0xFF0047BA),
                        onTap: () => _launch('tel:0803396668'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/logo/logocolor.png',
                    width: 200, // กำหนดขนาดภาพตามต้องการ
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    final icons = [
      Icons.favorite,
      Icons.star_rounded,
      Icons.circle,
    ];
    final icon = (icons..shuffle()).first;

    final colors = [
      const Color.fromARGB(255, 62, 122, 172),
      const Color.fromARGB(255, 68, 191, 207),
      const Color.fromARGB(255, 214, 132, 140),
      const Color.fromARGB(255, 230, 216, 93),
    ];
    final color = (colors..shuffle()).first.withOpacity(0.25);

    final rotation = ([-0.3, 0.2, 0.4]..shuffle()).first;

    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
