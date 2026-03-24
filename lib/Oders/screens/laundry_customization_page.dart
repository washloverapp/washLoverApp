import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:my_flutter_mapwash/Oders/API/api_totalOrder.dart';
import 'package:my_flutter_mapwash/Oders/models/laundry_item.dart';
import 'package:my_flutter_mapwash/Oders/screens/laundry_summary_page.dart';
import 'package:my_flutter_mapwash/Oders/services/laundry_service.dart';
import 'package:my_flutter_mapwash/Payment/walletQrcode.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';

class LaundryCustomizationPage extends StatefulWidget {
  final Map<String, dynamic> laundryType;

  const LaundryCustomizationPage({
    super.key,
    required this.laundryType,
  });

  @override
  State<LaundryCustomizationPage> createState() => _LaundryCustomizationPageState();
}

class _LaundryCustomizationPageState extends State<LaundryCustomizationPage> {
  final ImagePicker _picker = ImagePicker();
  final LaundryService _laundryService = LaundryService();

  XFile? _selectedImage;

  LaundryItem? selectedDetergent;
  LaundryItem? selectedFabricSoftener;
  LaundryItem? selectedMachineSize;
  LaundryItem? selectedTemperature;
  LaundryItem? selectedFabricSoftenerSize;

  final TextEditingController _notesController = TextEditingController();

  int detergentQuantity = 2;
  int fabricSoftenerQuantity = 2;

  bool bringOwnDetergent = false;
  bool bringOwnFabricSoftener = false;

  static const int _pricePerPiece = 5;

  int basePrice = 0;
  bool isLoading = true;

  List<LaundryItem> allItems = [];
  List<LaundryItem> detergentItems = [];
  List<LaundryItem> fabricSoftenerItems = [];
  List<LaundryItem> machineSizeItems = [];
  List<LaundryItem> temperatureItems = [];
  List<LaundryItem> fabricSoftenerSizeItems = [];

  @override
  void initState() {
    super.initState();
    _loadLaundryItems();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /* -------------------- ORDER JSON -------------------- */

  Map<String, dynamic> _buildOrderJson() {
    String jobId = ''; // รหัส ID งาน

    if (jobId == null || jobId.isEmpty) {
      jobId = const Uuid().v4();
    }
    return {
      // "device_id": 'order_$jobId',
      // "laundry_type": widget.laundryType,
      // "machine_size": selectedMachineSize == null
      //     ? null
      //     : {
      //         "id": selectedMachineSize!.id,
      //         "name": selectedMachineSize!.name,
      //         "price": selectedMachineSize!.price,
      //       },
      // "temperature": selectedTemperature == null
      //     ? null
      //     : {
      //         "id": selectedTemperature!.id,
      //         "name": selectedTemperature!.name,
      //         "price": selectedTemperature!.price,
      //       },
      // "dryer_size": selectedFabricSoftenerSize == null
      //     ? null
      //     : {
      //         "id": selectedFabricSoftenerSize!.id,
      //         "name": selectedFabricSoftenerSize!.name,
      //         "price": selectedFabricSoftenerSize!.price,
      //       },
      // "detergent": {
      //   "id": selectedDetergent?.id,
      //   "name": selectedDetergent?.name,
      //   "quantity": detergentQuantity,
      //   "bring_own": bringOwnDetergent,
      //   "price_per_piece": _pricePerPiece,
      // },
      // "fabric_softener": {
      //   "id": selectedFabricSoftener?.id,
      //   "name": selectedFabricSoftener?.name,
      //   "quantity": fabricSoftenerQuantity,
      //   "bring_own": bringOwnFabricSoftener,
      //   "price_per_piece": _pricePerPiece,
      // },
      // "notes": _notesController.text,
      // "total_price": getTotalPrice(),
      // "image_path": _selectedImage?.path,

      "device_id": 'order_$jobId',
      "notes": _notesController.text,
      "total_price": getTotalPrice(),
      "image_path": _selectedImage?.path,
      "laundry_type": widget.laundryType,
      "machine_size": selectedMachineSize,
      "temperature": selectedTemperature,
      "dryer_size": selectedFabricSoftenerSize,
      "detergent": selectedDetergent,
      "fabric_softener": selectedFabricSoftener,
    };
  }

  Future<void> _saveOrderToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_order', jsonEncode(_buildOrderJson()));
    // print(jsonEncode(_buildOrderJson()));
  }

  /* -------------------- API -------------------- */

  // Future<Status> _send_update_location() async {
  //   Status status = Status(status: false, messageJson: {});
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final lat = prefs.getDouble('lat') ?? 0.0;
  //     final lng = prefs.getDouble('lng') ?? 0.0;
  //
  //     final succ = await ApiPost.updateLocation(lat: lat, lng: lng);
  //
  //     if (succ.status) {
  //       status.status = true;
  //       status.messageJson = succ.messageJson;
  //
  //       final jobId = succ.messageJson['device_id'];
  //       final sender = ApiTotalorder();
  //       final order = await sender.loadOrderSummary();
  //       await sender.clearCart(order, jobId);
  //     } else {
  //       status.messageJson = succ.messageJson;
  //     }
  //   } catch (e) {
  //     status.messageJson = {"error": e.toString()};
  //   }
  //   return status;
  // }

  /* -------------------- DATA LOAD -------------------- */

  Future<void> _loadLaundryItems() async {
    try {
      setState(() => isLoading = true);
      final items = await _laundryService.fetchLaundryItems();
      setState(() {
        allItems = items;
        detergentItems = _laundryService.getItemsByType(items, 'detergent');
        fabricSoftenerItems = _laundryService.getItemsByType(items, 'softener');
        machineSizeItems = _laundryService.getItemsByType(items, 'washing');
        temperatureItems = _laundryService.getItemsByType(items, 'temperature');
        fabricSoftenerSizeItems = _laundryService.getItemsByType(items, 'dryer');
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  /* -------------------- IMAGE -------------------- */

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
      await _saveOrderToPrefs();
    }
  }

  /* -------------------- PRICE -------------------- */

  // int getTotalPrice() {
  //   return (selectedMachineSize?.price ?? 0) +
  //       (selectedTemperature?.price ?? 0) +
  //       (selectedFabricSoftenerSize?.price ?? 0) +
  //       (bringOwnDetergent ? 0 : detergentQuantity * _pricePerPiece) +
  //       (bringOwnFabricSoftener ? 0 : fabricSoftenerQuantity * _pricePerPiece);
  // }

  // bool get isAllRequiredFieldsSelected =>
  //     (selectedDetergent != null || bringOwnDetergent) &&
  //     (selectedFabricSoftener != null || bringOwnFabricSoftener) &&
  //     selectedMachineSize != null &&
  //     selectedTemperature != null &&
  //     selectedFabricSoftenerSize != null;

  /* -------------------- UI -------------------- */

  // Price calculation methods

  int getMachineSizePrice(LaundryItem? machineSize) {
    return machineSize?.price ?? 0;
  }

  int getTemperaturePrice(LaundryItem? temperature) {
    return temperature?.price ?? 0;
  }

  int getFabricSoftenerSizePrice(LaundryItem? size) {
    return size?.price ?? 0;
  }

  int getDetergentPrice(LaundryItem? detergent) {
    if (detergent == null || bringOwnDetergent) return 0;
    return _pricePerPiece * detergentQuantity;
  }

  int getFabricSoftenerPrice(LaundryItem? fabricSoftener) {
    if (fabricSoftener == null || bringOwnFabricSoftener) return 0;
    return _pricePerPiece * fabricSoftenerQuantity;
  }

  double getTotalPrice() {
    double total = basePrice.toDouble();
    total += getDetergentPrice(selectedDetergent).toDouble();
    total += getFabricSoftenerPrice(selectedFabricSoftener).toDouble();
    total += getMachineSizePrice(selectedMachineSize).toDouble();
    total += getTemperaturePrice(selectedTemperature).toDouble();
    total += getFabricSoftenerSizePrice(selectedFabricSoftenerSize).toDouble();
    return total;
  }

  bool get isDetergentSelected => selectedDetergent != null || bringOwnDetergent;
  bool get isFabricSoftenerSelected => selectedFabricSoftener != null || bringOwnFabricSoftener;
  bool get isMachineSizeSelected => selectedMachineSize != null;
  bool get isTemperatureSelected => selectedTemperature != null;
  bool get isFabricSoftenerSizeSelected => selectedFabricSoftenerSize != null;

  // ตรวจสอบว่าทุกตัวเลือกที่จำเป็นถูกเลือกแล้วหรือไม่
  bool get isAllRequiredFieldsSelected {
    return isDetergentSelected &&
        isFabricSoftenerSelected &&
        isMachineSizeSelected &&
        isTemperatureSelected &&
        isFabricSoftenerSizeSelected;
  }

  @override
  Widget build(BuildContext context) {
    print('widget.laundryType');
    print(widget.laundryType);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: Color(0xFF42A5F5),
        //   elevation: 5,
        //   // leading: IconButton(
        //   //   icon: const Icon(Icons.close, color: Colors.black),
        //   //   onPressed: () => Navigator.of(context).pop(),
        //   // ),
        //   actions: [
        //     // IconButton(
        //     //   icon: const Icon(Icons.share, color: Colors.black),
        //     //   onPressed: () {},
        //     // ),
        //     // IconButton(
        //     //   icon: const Icon(Icons.close, color: Colors.black),
        //     //   onPressed: () => Navigator.of(context).pop(),
        //     // ),
        //   ],
        // ),
        appBar: headerOrder(
          title: 'ตัวเลือก',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // Selected Options Images Section
                  _buildSelectedOptionsImages(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Title
                          Text(
                            widget.laundryType['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.laundryType['name_eng'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${getTotalPrice()}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'ราคารวม',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // เลือกขนาดเครื่องซัก
                          _buildSelectionSection(
                            title: 'เลือกขนาดเครื่องซัก',
                            isCompleted: isMachineSizeSelected,
                            items: machineSizeItems,
                            selectedItem: selectedMachineSize,
                            onChanged: (item) {
                              setState(() {
                                selectedMachineSize = item;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // เลือกอุณหภูมิ
                          _buildSelectionSection(
                            title: 'เลือกอุณหภูมิ',
                            isCompleted: isTemperatureSelected,
                            items: temperatureItems,
                            selectedItem: selectedTemperature,
                            onChanged: (item) {
                              setState(() {
                                selectedTemperature = item;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // เลือกขนาดเครื่องอบผ้า
                          _buildSelectionSection(
                            title: 'เลือกขนาดเครื่องอบผ้า',
                            isCompleted: isFabricSoftenerSizeSelected,
                            items: fabricSoftenerSizeItems,
                            selectedItem: selectedFabricSoftenerSize,
                            onChanged: (item) {
                              setState(() {
                                selectedFabricSoftenerSize = item;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // เลือกน้ำยาซัก
                          _buildSelectionSectionWithQuantity(
                            title: 'เลือกน้ำยาซัก',
                            isCompleted: isDetergentSelected,
                            items: detergentItems,
                            selectedItem: selectedDetergent,
                            quantity: detergentQuantity,
                            bringOwn: bringOwnDetergent,
                            onBringOwnChanged: (v) {
                              setState(() {
                                bringOwnDetergent = v;
                                if (v) {
                                  selectedDetergent = null;
                                }
                              });
                            },
                            onChanged: (item) {
                              setState(() {
                                selectedDetergent = item;
                                if (item != null) bringOwnDetergent = false;
                                if (item == null) detergentQuantity = 2;
                              });
                            },
                            onQuantityChanged: (newQuantity) {
                              setState(() => detergentQuantity = newQuantity);
                            },
                          ),

                          const SizedBox(height: 24),

                          // เลือกน้ำยาปรับผ้านุ่ม
                          _buildSelectionSectionWithQuantity(
                            title: 'เลือกน้ำยาปรับผ้านุ่ม',
                            isCompleted: isFabricSoftenerSelected,
                            items: fabricSoftenerItems,
                            selectedItem: selectedFabricSoftener,
                            quantity: fabricSoftenerQuantity,
                            bringOwn: bringOwnFabricSoftener,
                            onBringOwnChanged: (v) {
                              setState(() {
                                bringOwnFabricSoftener = v;
                                if (v) selectedFabricSoftener = null;
                              });
                            },
                            onChanged: (item) {
                              setState(() {
                                selectedFabricSoftener = item;
                                if (item != null) bringOwnFabricSoftener = false;
                                if (item == null) fabricSoftenerQuantity = 2;
                              });
                            },
                            onQuantityChanged: (newQuantity) {
                              setState(() => fabricSoftenerQuantity = newQuantity);
                            },
                          ),

                          const SizedBox(height: 24),

                          // หมายเหตุ
                          _buildNotesSection(),

                          const SizedBox(height: 24),

                          // เลือกรูปภาพ
                          _buildImagePickerSection(),

                          const SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isAllRequiredFieldsSelected
                  ? () async {
                      await _saveOrderToPrefs();
                      // var succ = await _send_update_location();

                      // if (succ.status) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Qrcode(
                            amountP: getTotalPrice(),
                          ),
                        ),
                      );
                      // }

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => LaundrySummaryPage(
                      //       laundryType: widget.laundryType,
                      //       selectedMachineSize: selectedMachineSize!,
                      //       selectedTemperature: selectedTemperature!,
                      //       selectedFabricSoftenerSize: selectedFabricSoftenerSize!,
                      //       selectedDetergent: selectedDetergent,
                      //       selectedFabricSoftener: selectedFabricSoftener,
                      //       detergentQuantity: detergentQuantity,
                      //       fabricSoftenerQuantity: fabricSoftenerQuantity,
                      //       bringOwnDetergent: bringOwnDetergent,
                      //       bringOwnFabricSoftener: bringOwnFabricSoftener,
                      //       notes: _notesController.text,
                      //       totalPrice: getTotalPrice(),
                      //       imageFile: _selectedImage != null
                      //           ? File(_selectedImage!.path)
                      //           : null,
                      //     ),
                      //   ),
                      // );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAllRequiredFieldsSelected ? Colors.orange[300] : Colors.grey[300],
                foregroundColor: isAllRequiredFieldsSelected ? Colors.white : Colors.grey[500],
                padding: const EdgeInsets.symmetric(vertical: 0),
                shape: StadiumBorder(),
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ชำระเงิน  ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: isAllRequiredFieldsSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                    Text(
                      '${getTotalPrice()} ฿',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: isAllRequiredFieldsSelected ? Colors.white : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSection({
    required String title,
    required bool isCompleted,
    required List<LaundryItem> items,
    required LaundryItem? selectedItem,
    required ValueChanged<LaundryItem?> onChanged,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'ใช้สำเร็จ' : 'เลือก 1',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildRadioOption(
                  item: item,
                  selectedItem: selectedItem,
                  onChanged: onChanged,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSectionWithQuantity({
    required String title,
    required bool isCompleted,
    required List<LaundryItem> items,
    required LaundryItem? selectedItem,
    required int quantity,
    required bool bringOwn,
    required ValueChanged<bool> onBringOwnChanged,
    required ValueChanged<LaundryItem?> onChanged,
    required ValueChanged<int> onQuantityChanged,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => onBringOwnChanged(!bringOwn),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: bringOwn,
                          onChanged: (_) => onBringOwnChanged(!bringOwn),
                          activeColor: const Color(0xFF4CAF50),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ไม่เลือก',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'ใช้สำเร็จ' : 'เลือก 1',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (bringOwn)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'ลูกค้าจะนำมาเอง',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 12),
              ...items.map((item) => _buildRadioOptionWithQuantity(
                    item: item,
                    selectedItem: selectedItem,
                    quantity: quantity,
                    onChanged: onChanged,
                    onQuantityChanged: onQuantityChanged,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOptionWithQuantity({
    required LaundryItem item,
    required LaundryItem? selectedItem,
    required int quantity,
    required ValueChanged<LaundryItem?> onChanged,
    required ValueChanged<int> onQuantityChanged,
  }) {
    final bool isSelected = selectedItem?.id == item.id;
    return InkWell(
      onTap: () => onChanged(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[400]!,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
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
            if (isSelected)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: quantity > 2 ? () => onQuantityChanged(quantity - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: quantity > 2 ? const Color(0xFF4CAF50) : Colors.grey[400],
                    iconSize: 26,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF4CAF50),
                    iconSize: 26,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              )
            else
              Text(
                '+$_pricePerPiece บาท/ชิ้น',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required LaundryItem item,
    required LaundryItem? selectedItem,
    required ValueChanged<LaundryItem?> onChanged,
  }) {
    final bool isSelected = selectedItem?.id == item.id;
    return InkWell(
      onTap: () => onChanged(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[400]!,
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // รูปภาพ
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
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
              item.price == 0 ? '0 บาท' : '+${item.price} บาท',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: item.price == 0 ? Colors.grey[600] : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'หมายเหตุ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'กรอกหมายเหตุ',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เลือกรูปภาพ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เลือกรูปในมือถือ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedOptionsImages() {
    final List<LaundryItem> selectedItems = [];
    if (selectedMachineSize != null) {
      selectedItems.add(selectedMachineSize!);
    }

    if (selectedTemperature != null) {
      selectedItems.add(selectedTemperature!);
    }
    if (selectedFabricSoftenerSize != null) {
      selectedItems.add(selectedFabricSoftenerSize!);
    }
    if (selectedDetergent != null) {
      selectedItems.add(selectedDetergent!);
    }
    if (selectedFabricSoftener != null) {
      selectedItems.add(selectedFabricSoftener!);
    }
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.white,
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ตัวเลือกที่เลือกไว้',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Text(
                                            item.detail,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Text(
                            item.detail,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
