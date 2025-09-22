import 'package:flutter/material.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ศูนย์ช่วยเหลือ', // ใส่ title ที่ต้องการแสดง
        onBackPressed: () {
          Navigator.pop(context); // ใช้ Navigator.pop เพื่อย้อนกลับหน้าปัจจุบัน
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Help",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 203, 203, 203),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  DirectionCard(
                      icon: Icons.phone,
                      label: 'Support Service Call',
                      color: Colors.green),
                  DirectionCard(
                      icon: Icons.email,
                      label: 'Support Service Email',
                      color: const Color.fromARGB(255, 132, 81, 221)),
                  DirectionCard(
                      icon: Icons.facebook,
                      label: 'Support Service Facebook',
                      color: const Color.fromARGB(255, 47, 161, 255)),
                  DirectionCard(
                      icon: Icons.social_distance,
                      label: 'Support Service google',
                      color: const Color.fromARGB(255, 255, 169, 41)),
                  DirectionCard(
                      icon: Icons.social_distance,
                      label: 'Support Service Youtube',
                      color: const Color.fromARGB(255, 255, 65, 129)),
                  DirectionCard(
                      icon: Icons.one_x_mobiledata,
                      label: 'Support Service Twitter',
                      color: const Color.fromARGB(255, 122, 122, 122)),
                  DirectionCard(
                      icon: Icons.social_distance,
                      label: 'Support Service Line',
                      color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DirectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  DirectionCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color.fromARGB(31, 255, 255, 255), width: 1),
        ),
        child: ListTile(
          // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Icon(icon, color: Colors.white),
          title: Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
