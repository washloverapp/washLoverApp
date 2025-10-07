import 'package:flutter/material.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';

class profile extends StatelessWidget {
  const profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'โปรไฟล์',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // color: Colors.blue.shade800,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // ทำให้เป็นวงกลม
                      border: Border.all(
                        color: Colors.grey, // สีของขอบ
                        width: 2, // ความหนาของขอบ
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage("assets/images/logo.png"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "สมชาย ใจดี",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "081 **** 123",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // เมนูต่างๆ
            buildMenuItem(
              icon: Icons.person,
              text: "ข้อมูลส่วนตัว",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
            ),
            buildMenuItem(
              icon: Icons.link,
              text: "เชื่อมต่อบัญชี LINE",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.account_balance_wallet,
              text: "วอลเล็ท (0 บาท)",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.star,
              text: "แต้มสะสม (120 คะแนน)",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.location_on,
              text: "ที่อยู่ของฉัน",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.confirmation_num,
              text: "คูปอง (2 คูปอง)",
              onTap: () {},
            ),
            buildMenuItem(
              icon: Icons.credit_card,
              text: "บัตรเครดิต / เดบิต",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      color: Colors.white, // กำหนดสีพื้นหลังให้เป็นสีขาว
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade800),
        title: Text(text, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ---------------- หน้าแก้ไขโปรไฟล์ ----------------
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: headerOrder(
        title: 'ข้อมูลส่วนตัว',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : const AssetImage("assets/images/logo.png")
                          as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: getImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade800,
                      radius: 18,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildTextField("ชื่อ", "สมชาย"),
            buildTextField("นามสกุล", "ใจดี"),
            buildTextField("เบอร์โทรศัพท์", "081 **** 123", enabled: false),
            buildTextField("อีเมล", "somchai.test@example.com"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "บันทึก",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String value, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          fillColor: Colors.white, // สีพื้นหลัง
          filled: true, // เปิดใช้งานสีพื้นหลัง
        ),
      ),
    );
  }
}
