import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Oders/models/laundry_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaundrySummaryPage extends StatelessWidget {
  final String laundryType;
  final LaundryItem selectedMachineSize;
  final LaundryItem selectedTemperature;
  final LaundryItem selectedFabricSoftenerSize;
  final LaundryItem? selectedDetergent;
  final LaundryItem? selectedFabricSoftener;
  final int detergentQuantity;
  final int fabricSoftenerQuantity;
  final bool bringOwnDetergent;
  final bool bringOwnFabricSoftener;
  final String notes;
  final double totalPrice;
  final File? imageFile;

  const LaundrySummaryPage({
    super.key,
    required this.laundryType,
    required this.selectedMachineSize,
    required this.selectedTemperature,
    required this.selectedFabricSoftenerSize,
    required this.selectedDetergent,
    required this.selectedFabricSoftener,
    required this.detergentQuantity,
    required this.fabricSoftenerQuantity,
    required this.bringOwnDetergent,
    required this.bringOwnFabricSoftener,
    required this.notes,
    required this.totalPrice,
    required this.imageFile,
  });

  @override
  void initState() {
    debugPrintPrefs();
  }

  Future<void> debugPrintPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    print('laundryType: ${prefs.getString('laundryType')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('สรุปรายละเอียด'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('ประเภทผ้า'),
            _value(laundryType == 'clothes'
                ? 'เสื้อผ้า'
                : 'ชุดเครื่องนอน / ผ้านวม'),
            _sectionTitle('เครื่องซัก'),
            _itemRow(
              item: selectedMachineSize,
              trailingText: '${selectedMachineSize.price} บาท',
            ),
            _sectionTitle('อุณหภูมิ'),
            _itemRow(
              item: selectedTemperature,
              trailingText: '${selectedTemperature.price} บาท',
            ),
            _sectionTitle('เครื่องอบ'),
            _itemRow(
              item: selectedFabricSoftenerSize,
              trailingText: '${selectedFabricSoftenerSize.price} บาท',
            ),
            _sectionTitle('น้ำยาซัก'),
            bringOwnDetergent
                ? _value('ลูกค้านำมาเอง')
                : _itemRow(
                    item: selectedDetergent!,
                    trailingText: 'x$detergentQuantity',
                  ),
            _sectionTitle('น้ำยาปรับผ้านุ่ม'),
            bringOwnFabricSoftener
                ? _value('ลูกค้านำมาเอง')
                : _itemRow(
                    item: selectedFabricSoftener!,
                    trailingText: 'x$fabricSoftenerQuantity',
                  ),
            if (notes.isNotEmpty) ...[
              _sectionTitle('หมายเหตุ'),
              _value(notes),
            ],
            if (imageFile != null) ...[
              _sectionTitle('รูปที่แนบ'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ราคารวม',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${totalPrice.toInt()} บาท',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== Widgets =====

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _value(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _itemRow({
    required LaundryItem item,
    String? trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.detail,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.name.isNotEmpty)
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            trailingText ?? '${item.price} บาท',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
