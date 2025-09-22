import 'package:flutter/material.dart';

class CustomSnackBar {
  CustomSnackBar(BuildContext context, Widget content,
      {required SnackBarAction snackBarAction,
      Color backgroundColor = Colors.green}) {
    final SnackBar snackBar = SnackBar(
        action: snackBarAction,
        backgroundColor: backgroundColor,
        content: content,
        behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class SnackBarDanger {
  SnackBarDanger(BuildContext context, Widget content,
      {required SnackBarAction snackBarAction,
      Color backgroundColor = Colors.red}) {
    final SnackBar snackBar = SnackBar(
        action: snackBarAction,
        backgroundColor: backgroundColor,
        content: content,
        behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class SnackBarSuccess {
  SnackBarSuccess(BuildContext context, Widget content,
      {SnackBarAction? snackBarAction, Color backgroundColor = Colors.green}) {
    final SnackBar snackBar = SnackBar(
        action: snackBarAction, // ถ้าไม่ส่งค่า snackBarAction ก็จะไม่มีปุ่มแสดง
        backgroundColor: backgroundColor,
        content: content,
        behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class SnackBarError {
  SnackBarError(BuildContext context, Widget content,
      {SnackBarAction? snackBarAction, Color backgroundColor = Colors.red}) {
    final SnackBar snackBar = SnackBar(
        action: snackBarAction, // ถ้าไม่ส่งค่า snackBarAction ก็จะไม่มีปุ่มแสดง
        backgroundColor: backgroundColor,
        content: content,
        behavior: SnackBarBehavior.floating);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
