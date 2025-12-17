import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool _hasOpened = false;

  late TabController _tabController;
  final List<String> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ---------- Bottom Sheet ----------
  Future<void> _showOpenLinkSheet(String url) async {
    if (_hasOpened) return;

    setState(() => _hasOpened = true);
    await controller.stop();

    if (!_scanHistory.contains(url)) {
      _scanHistory.insert(0, url);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Container(
            
            padding: const EdgeInsets.all(16),
            
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'เลือกวิธีเปิด',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // ปุ่มเปิดใน LINE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'เปิดใน LINE',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                      _resetScanner();
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // ปุ่มเปิดเป็นเว็บ
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.public, color: Colors.orange),
                    label: const Text(
                      'เปิดในเบราว์เซอร์',
                      style: TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.inAppBrowserView,
                      );
                      _resetScanner();
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // ปุ่มยกเลิก
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resetScanner();
                  },
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetScanner() {
    setState(() => _hasOpened = false);
    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text(
        'สแกนเพื่อซักผ้า/อบผ้า',
        style: TextStyle(color: Colors.black, fontSize: 16), // ข้อความสีดำบน AppBar สีขาว
      ),
      backgroundColor: Colors.white,
      elevation: 0, // เอาเงา AppBar ออก
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.history), text: 'ที่เคยแสกน'),
          Tab(icon: Icon(Icons.qr_code_scanner), text: 'สแกน'),
        ],
        indicatorColor: Colors.blue, // สีเส้นใต้ Tab ที่เลือก
        labelColor: Colors.blue, // สี icon/text ของ Tab ที่เลือก
        unselectedLabelColor: Colors.grey, // สี icon/text ของ Tab ที่ไม่ได้เลือก
      ),
      iconTheme: const IconThemeData(color: Colors.black), // สี icon ถ้าใช้ back button
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _buildHistory(),
        _buildScanner(),
      ],
    ),
  );
}


  // ---------- Tab 1: History ----------
  Widget _buildHistory() {
    if (_scanHistory.isEmpty) {
      return const Center(child: Text('ยังไม่มีรายการที่เคยแสกน'));
    }

    return ListView.builder(
      itemCount: _scanHistory.length,
      itemBuilder: (context, index) {
        final url = _scanHistory[index];
        return ListTile(
          leading: const Icon(Icons.link),
          title: Text(
            url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _showOpenLinkSheet(url),
        );
      },
    );
  }

  // ---------- Tab 2: Scanner ----------
  Widget _buildScanner() {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final code = barcode.rawValue;
          if (code != null &&
              barcode.type == BarcodeType.url &&
              Uri.tryParse(code)?.host == 'liff.line.me') {
            _showOpenLinkSheet(code);
            break;
          }
        }
      },
    );
  }
}
