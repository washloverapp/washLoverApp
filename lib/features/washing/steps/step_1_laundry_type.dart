import 'package:flutter/material.dart';

class Step1LaundryType extends StatelessWidget {
  const Step1LaundryType({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.dry_cleaning),
            title: const Text('เสื้อผ้า'),
            onTap: () {
              // เพิ่ม Logic เมื่อเลือกเสื้อผ้า
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bed),
            title: const Text('ชุดเครื่องนอน/ผ้าห่ม'),
            onTap: () {
              // เพิ่ม Logic เมื่อเลือกชุดเครื่องนอน
            },
          ),
        ),
      ],
    );
  }
}