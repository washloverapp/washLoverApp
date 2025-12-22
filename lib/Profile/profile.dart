import 'package:flutter/material.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_mapwash/Header/headerOrder.dart';
import 'package:my_flutter_mapwash/Login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/Profile/API/api_profile.dart'; // ✅ เพิ่ม import เพื่อเรียก API

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _ProfileState();
}

class _ProfileState extends State<profile> {
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Map<String, dynamic> profileData = {};

  Future<void> _loadProfile() async {
    try {
      Map<String, dynamic> data = await api_profile.fetchProfile();
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

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
      body: buildProfileContent(context),
    );
  }

  String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return phone.substring(0, 3) + 'xxxxxx' + phone.substring(phone.length - 2);
  }

  Widget buildProfileContent(BuildContext context) {
    final data = profileData;
    final phone = data['phone'] ?? '-';
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/duck2.jpg"),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['nickname'] ?? 'ไม่พบชื่อเล่น',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      maskPhone(phone),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          buildMenuItem(
            icon: Icons.account_balance_wallet,
            text: "วอลเล็ท",
            value: "(${data['balance'] ?? 0} คะแนน)",
          ),
          buildMenuItem(
            icon: Icons.star,
            text: "แต้มสะสม",
            value: "(${data['points'] ?? 0} คะแนน)",
            // onTap: () {},
          ),
          buildMenuItem(
            icon: Icons.local_laundry_service,
            text: "จำนวนครั้งที่ใช้บริการ",
            value: " (${data['service_count'] ?? 0} ครั้ง)",
            // onTap: () {},
          ),
          buildMenuItem(
            icon: Icons.access_time,
            text: "ใช้งานล่าสุด ${data['last_active'] ?? '-'}",
            value: "",
            // onTap: () {},
          ),
          buildMenuItem(
            icon: Icons.access_time,
            text: "รหัสประจำตัว ${data['device_id'] ?? '-'}",
            value: "",
            // onTap: () {},
          ),
          const SizedBox(height: 20),
          buildMenuItem22(
            icon: Icons.delete,
            text: "แจ้งลบบัญชี",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmptyNotificationPage(
                    nickname: data['nickname'] ?? '',
                    phone: phone,
                    device_id: data['device_id'] ?? '',
                  ),
                ),
              );
            },
          ),
          buildMenuLogout(
            icon: Icons.logout_rounded,
            text: "ออกจากระบบ",
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem22({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade800),
        title: Text(text, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade800),
            const SizedBox(width: 12),

            // ข้อความฝั่งซ้าย
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // ค่าอยู่ขวาสุด
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuLogout({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
        onTap: onTap,
      ),
    );
  }
}

// ----------------- หน้าลบ Account -----------------

class EmptyNotificationPage extends StatelessWidget {
  final String nickname;
  final String phone;
  final String device_id;
  const EmptyNotificationPage({
    super.key,
    required this.nickname,
    required this.phone,
    required this.device_id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // สีพื้นหลังอ่อนเหมือนในภาพ
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// รูปภาพด้านบน
              Image.network(
                "https://static.vecteezy.com/system/resources/previews/016/716/465/non_2x/gmail-icon-free-png.png", // เปลี่ยนตามไฟล์ของคุณ
                width: 140,
                height: 140,
              ),

              const SizedBox(height: 20),

              /// ข้อความหัวเรื่อง
              const Text(
                "แจ้งลบบัญชี",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              /// ข้อความอธิบาย
              Text(
                "หากคุณต้องการลบบัญชีของคุณ กรุณาส่งอีเมลที่มีรายละเอียดดังนี้:\n\n- ชื่อ: $nickname \n- เบอร์โทรศัพท์: $phone \n- รหัสประจำตัวอุปกรณ์: $device_id\n\nไปที่อีเมล washloverapp@gmail.com",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              /// ลิงก์ด้านล่าง
              Material(
                color: Colors.transparent, // ถ้าไม่อยากให้ background มีสี
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "กลับหน้าหลัก",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- หน้าแก้ไขโปรไฟล์ ----------------
class EditProfilePage extends StatefulWidget {
  final String nickname;
  final String phone;

  const EditProfilePage({
    super.key,
    required this.nickname,
    required this.phone,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _image;
  final picker = ImagePicker();

  late TextEditingController nicknameController;
  late TextEditingController emailController;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: widget.nickname);
    emailController = TextEditingController();
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: getImage,
                      borderRadius: BorderRadius.circular(18),
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade800,
                        radius: 18,
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            buildTextField("ชื่อเล่น", widget.nickname),
            buildTextField("เบอร์โทรศัพท์", widget.phone, enabled: false),
            buildTextField("อีเมล", "example@email.com"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("ยังไม่เชื่อมต่อ API บันทึก")),
                );
              },
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
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
