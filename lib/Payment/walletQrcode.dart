import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:my_flutter_mapwash/Home/API/api_sendFcmNotify.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
// import 'package:my_flutter_mapwash/Payment/PaymentFail.dart';
// import 'package:my_flutter_mapwash/Payment/PaymentSuccess.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_flutter_mapwash/Oders/API/api_saveorder.dart';
import 'package:my_flutter_mapwash/Oders/API/api_totalOrder.dart';
import 'package:my_flutter_mapwash/Payment/alert_error.dart';
import 'package:my_flutter_mapwash/Payment/alert_succ.dart';
import 'package:my_flutter_mapwash/Status/API/api_status.dart';
import 'package:my_flutter_mapwash/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Qrcode extends StatefulWidget {
  final double amountP;
  Qrcode({Key? key, required this.amountP}) : super(key: key);
  @override
  _QrcodeState createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  String phone = '';
  String displayMessageStatus = "กำลังดำเนินการ";
  String urlLink = "";
  String idWorking = "";
  String detail = "";
  String username = "";
  String image = "";
  String status = "";
  String ref = "";
  String dateStr = "";
  String endtime = "";
  String endtimeCount = "";
  String promotionPrice = "";
  String refID = "";
  String ID = "";
  String device_id = "";
  int _remainingSeconds = 05 * 60;
  List<Map<String, dynamic>> addressuser = [];
  List<Map<String, dynamic>> Branch = [];
  Timer? _timer;
  String payment = '';
  List<Map<String, dynamic>> Conferm_Oder = [];
  List<Map<String, dynamic>> jsonData = [];
  List<dynamic> _statusData = [];
  int inNumber = 0;

  String? qrImage;
  // String orderId = ""; // 👈 เปลี่ยนได้
  double amount = 1.0; // 👈 ระบุจำนวนเงิน
  String apiKey = "DRIVER"; // 👈 ใส่ API KEY จริงของคุณ
  bool isCheck = false;
  String? paymentStatus;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final args =
  //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  //   amount = args['amountP'];
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  @override
  void initState() {
    super.initState();
    amount = widget.amountP;
    getPhone();
    _startCountdown();
    loadStatus();
    loadPhone();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (mounted) {
        bool succ = await checkPaymentStatus(device_id);
        if (succ) {
          _timer!.cancel();
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              barrierColor: Colors.black54.withOpacity(.5),
              builder: (context) {
                return AlertSucc('', 'การโอนสำเร็จ');
              },
            ),
          ).then((value) async {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            });
            api_sendFcmNotify.sendFcmNotify(
              'แจ้งเตือนออเดอร์งานจากลูกค้า',
              'งานด่วนลูกค้ารอพนักงานรับผ้า',
            );
            final succCart = await APICartSet.sendCartToSet();
            if (succCart) {
              final succ = await _send_update_location();
              if (succ.status) {
                MainLayout.initialIndex = 4;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainLayout(),
                  ),
                  (Route<dynamic> route) => false, // 🔥 ลบทุกหน้าเก่าทิ้งทั้งหมด
                );
              }
            }
          });
        }
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _remainingSeconds = 05 * 60;
            // timer.cancel();
          }
        });
      } else {
        // _remainingSeconds = 05 * 60;
        // timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> generateQR(orderId) async {
    final url = "https://payment.washlover.com/create-payment-qr?amount=$amount&order_id=$orderId&ref4=$apiKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        qrImage = data["image2"];
        paymentStatus = "กรุณาสแกนเพื่อชำระเงิน";
      });
    } else {
      setState(() {
        paymentStatus = "สร้าง QR ไม่สำเร็จ";
      });
    }
  }

  /// 2) เช็คสถานะการชำระเงิน
  Future<bool> checkPaymentStatus(
    orderId,
  ) async {
    bool succ = false;
    final url = "https://payment.washlover.com/api/check-payment?ref1=$orderId&ref4=$apiKey";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // print(data["data"]["status"]);
      await Future.delayed(Duration(seconds: 2)); // delay 100ms ต่อจุด
      data["data"]["status"] = "success";
      if (data["data"]["status"] == "success") {
        succ = true;

        paymentStatus = "🎉 ชำระเงินเรียบร้อยแล้ว";
        setState(() {});
      } else {
        setState(() {
          paymentStatus = "${data["data"]["msg"]}" ?? "รอการชำระเงิน";
        });
      }
    } else {
      setState(() {
        paymentStatus = "เช็คสถานะไม่สำเร็จ";
      });
    }
    // await Future.delayed(Duration(seconds: 2)); // delay 100ms ต่อจุด
    // succ = true;
    return succ;
  }

  Future<void> loadStatus() async {
    // String orderId = '';
    try {
      // List<dynamic> data = await api_status.fetchstatus();
      // final filtered = data.where((e) => e['status'] == 1).toList();
      // setState(() {
      //   _statusData = filtered;
      //   inNumber = _statusData[0]['status'] ?? 0;
      //   device_id = _statusData[0]['device_id'] ?? '';
      //   orderId = _statusData[0]['device_id'] ?? '';
      // });
      // if (_statusData.isNotEmpty) {
      //   setState(() {});
      //   if (isCheck == false) {
      //     generateQR(orderId);
      //   }
      //   isCheck = true;
      //   checkPaymentStatus(orderId);
      // } else {
      //   generateQR(orderId);
      // }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String orderJsonString = prefs.getString('current_order') ?? '{}';
      Map<String, dynamic> orderJson = jsonDecode(orderJsonString);

      // print('orderJsonString');
      // print(orderJsonString);
      // print(orderJson);
      device_id = orderJson['device_id'] ?? '';

      generateQR(device_id);
    } catch (e) {
      print('Error loading status: $e');
      setState(() => _statusData = []);
    }
  }

  Future<String?> getPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  void loadPhone() async {
    phone = await getPhone() ?? '';
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    initializeDateFormatting('th_TH', null).then((_) {});
    String formattedDate = DateFormat('d MMMM yyyy, E', 'th_TH').format(now);
    String formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ------- เนื้อหาเดิมทั้งหมดของคุณ -------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Payment Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Icon(Icons.share, color: Colors.pink),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("รหัสงาน: $device_id", style: TextStyle(color: Colors.grey)),
                    Divider(),
                    buildInfoRow("ยูเซอร์", "$phone", "สถานะ", "$paymentStatus"),
                    buildInfoRow2("วันที่", "$formattedDate", "จะหมดเวลา", "${_formatTime(_remainingSeconds)} น."),
                    buildInfoRow3("หมายเลขอ้างอิง", "$device_id"),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "จำนวนเงิน:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "฿ $amount",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 16),
                    qrImage == null
                        ? Text("กำลังสร้าง QRCODE...")
                        : Card(
                            color: Colors.white,
                            // margin: EdgeInsets.zero,
                            child: Image.network(qrImage!, width: 450, height: 400)),
                    // SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "คำเตือน : สามารถสแกน QRCODE ได้เพียงครั้งเดียว ห้ามนำกลับมาใช้ซ้ำเด็ดขาด",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Expanded(child: buildButtonCancle("กลับ", Colors.grey, Colors.black, context)),
                        // Expanded(child: buildButtonSuccess("โอนสำเร็จ", Colors.lightGreen, Colors.white)),
                      ],
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

  Widget buildInfoRow3(String label1, String value1) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildInfoColumn3(label1, value1),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInfoColumn(label1, value1),
          buildInfoColumn(label2, value2),
        ],
      ),
    );
  }

  Widget buildInfoRow2(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildInfoColumn(label1, value1),
          buildInfoColumn2(label2, value2),
        ],
      ),
    );
  }

  Widget buildInfoColumn2(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }

  Widget buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildInfoColumn3(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(
              fontSize: 14,
            )),
      ],
    );
  }

  Widget buildButtonCancle(String text, Color bgColor, Color textColor, BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: CustomTheme.colorPrimary)),
        // backgroundColor: Colors.transparent,
        shape: WidgetStateProperty.all(StadiumBorder()),
      ),
      onPressed: () {
        // APICartSet.getCart('');

        Navigator.pop(context); // ปิด popup
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  Widget buildButtonSuccess(String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomTheme.colorPrimary,
        shape: StadiumBorder(),
        // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () async {
        final succ = await checkPaymentStatus(device_id);
        if (!succ) {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              barrierColor: Colors.black54.withOpacity(.5),
              builder: (context) {
                return AlertError('เตือน', 'การโอนไม่สำเร็จ กรุณาทำรายการโอนใหม่อีกครั้ง!');
              },
            ),
          );
        }

        // final succ = await _send_update_location();
        // if (succ.status) {
        //   MainLayout.initialIndex = 4;
        //   Navigator.pushAndRemoveUntil(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => MainLayout(),
        //     ),
        //     (Route<dynamic> route) => false, // 🔥 ลบทุกหน้าเก่าทิ้งทั้งหมด
        //   );
        // }

        // checkPaymentStatus();
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MainLayout(),
        //   ),
        //   (Route<dynamic> route) => false, // 🔥 ลบทุกหน้าเก่าทิ้งทั้งหมด
        // );
      },
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  Future<Status> _send_update_location() async {
    Status status = Status(status: false, messageJson: {});
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('lat') ?? 0.0;
      final lng = prefs.getDouble('lng') ?? 0.0;

      final succ = await ApiPost.updateLocation(lat: lat, lng: lng);

      if (succ.status) {
        status.status = true;
        status.messageJson = succ.messageJson;

        final jobId = succ.messageJson['device_id'];
        final sender = ApiTotalorder();
        final order = await sender.loadOrderSummary();
        await sender.clearCart(order, jobId);
      } else {
        status.messageJson = succ.messageJson;
      }
    } catch (e) {
      status.messageJson = {"error": e.toString()};
    }
    return status;
  }
}
