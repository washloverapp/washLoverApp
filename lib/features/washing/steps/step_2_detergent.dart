import 'package:flutter/material.dart';

class Step2Detergent extends StatelessWidget {
  const Step2Detergent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เลือกน้ำยาซักผ้า:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('ปกติ'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('สูตรอ่อนโยน'),
            ),
          ],
        ),
      ],
    );
  }
}