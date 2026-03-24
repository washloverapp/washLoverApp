import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_mapwash/theme.dart';

class AlertSucc extends ConsumerStatefulWidget {
  String head;
  String detail;

  AlertSucc(this.head, this.detail, {super.key});

  @override
  ConsumerState<AlertSucc> createState() => _ProductCartState();
}

class _ProductCartState extends ConsumerState<AlertSucc> {
  List<dynamic> listPay = [
    {'id': 0, 'name': 'เงินสด'},
    {'id': 1, 'name': 'เงินโอน'},
  ];
  Map<String, dynamic> payData = {'id': 0, 'name': 'เงินสด'};
  bool save = false;
  TextEditingController txtController = TextEditingController();

  bool payCash = false;
  String? _errorMessage;

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'ใส่จำนวนเงิน!';
    }
    // Add more validation rules as needed
    return null; // Valid
  }

  void _validateAndSetError() {
    setState(() {
      _errorMessage = _validateInput(txtController.text);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _validateAndSetError();
    });
    super.initState();
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final listProductCart = ref.watch(listProductCartProvider);
    // final listProductCartNotifier = ref.read(listProductCartProvider.notifier);
    double sizeH = MediaQuery.sizeOf(context).height;
    // double totalMoney = 0;
    // for (var i = 0; i < listProductCart.length; i++) {
    //   if (!listProductCart[i]['free']) {
    //     totalMoney += double.parse(listProductCart[i]['price_total'].toString());
    //   }
    //
    //   // print('totalMoney--x');
    //   // print(totalMoney);
    // }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: SizedBox(
        // height: ((sizeH * .1) + 300),
        // height: 200,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return Container(
              decoration: BoxDecoration(
                // color: Colors.white,
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   stops: [0.1, 0.9],
                //   colors: [
                //     CupertinoColors.systemGroupedBackground,
                //
                //     widget.type == 2 ? Colors.red.withOpacity(.7) :   xColors.color4.withOpacity(.5),
                //   ],
                //   // center: Alignment.centerLeft,
                //   // focal: Alignment.topRight,
                //   // focalRadius: 5,
                // ),
                // // borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                //
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                // image: DecorationImage(image: AssetImage('assets/image/logo_no_bg.png'), fit: BoxFit.cover, alignment: Alignment(0, 0), opacity: .1),
              ),
              // decoration: BoxDecoration(
              //   color: widget.type == 2 ? Colors.red.withOpacity(.7) : xColors.color3.withOpacity(.8),
              //   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              //   image: DecorationImage(image: AssetImage('assets/image/logo_no_bg.png'), fit: BoxFit.cover, alignment: Alignment(0, 0), opacity: .1),
              // ),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    // Padding(
                                    //   padding: const EdgeInsets.all(0),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //         widget.head,
                                    //         style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    //               // color: CustomTheme.colorPrimary,
                                    //               fontWeight: FontWeight.normal,
                                    //             ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                    Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 50),
                                    Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.detail,
                                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                // color: Colors.red,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Positioned(
                              //     top: 0,
                              //     right: 0,
                              //     child: IconButton(
                              //         onPressed: () {
                              //           Navigator.of(context).pop(true);
                              //         },
                              //         icon: Icon(Icons.close, size: 30))),
                            ],
                          ),

                          // ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: CustomTheme.colorPrimary,
                          //       shape: StadiumBorder(),
                          //       // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          //     ),
                          //     child: Text('', style: TextStyle()),
                          //     onPressed: () async {}),

                          // // SizedBox(height: sizeH * .02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
