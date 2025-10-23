import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'login_page.dart'; // ✅ หน้าล็อกอิน

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(16.197256, 103.282474);

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ===== ฟังก์ชันเปิดใน Google Maps =====
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

  // ===== ฟังก์ชันเปิดลิงก์ทั่วไป =====
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
    return Scaffold(
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
                  Color.fromARGB(169, 80, 171, 245),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ===== ไอคอนตกแต่งพื้นหลัง =====
          ...List.generate(15, (index) {
            final random = index * 37.5;
            final top = (random * 13) % MediaQuery.of(context).size.height;
            final left = (random * 29) % MediaQuery.of(context).size.width;
            final size = 20 + (random % 30);

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
                // ===== แผนที่ =====
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0047BA),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '888/1 หมู่ที่ 3 ตำบลท่าขอนยาง อ.กันทรวิชัย จ.มหาสารคาม 44150',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ===== ช่องทางติดต่อ =====
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Widget Bubble (ดาว / หัวใจ / วงกลม) =====
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

    final rotation = ([-0.2, 0.1, 0.3]..shuffle()).first;

    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }

  // ===== แถวข้อมูลการติดต่อ =====
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
                  fontSize: 16,
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
