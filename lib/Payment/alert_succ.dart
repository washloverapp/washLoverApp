import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_mapwash/theme.dart';

class AlertSucc extends ConsumerStatefulWidget {
  final String head;
  final String detail;

  const AlertSucc(this.head, this.detail, {super.key});

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
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Auto-dismiss after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  void dispose() {
    txtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      widget.detail,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
