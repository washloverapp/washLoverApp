import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_flutter_mapwash/Login/auth_wrapper.dart';
// import 'package:my_flutter_mapwash/Login/sign_login_opt.dart';
import 'package:my_flutter_mapwash/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
// import 'package:my_flutter_mapwash/Layouts/main_layout_NOaccount.dart';
// import 'package:my_flutter_mapwash/Header/snackbar.dart';
import 'package:my_flutter_mapwash/theme.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _focusPhone = FocusNode();
  final _focusPassword = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  
  String slert = '1';

  @override
  void initState() {
    super.initState();
    api_config.loadEndpoint();
  }

  @override
  void _handleLogin() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final endpoint =
        prefs.getString('endpoint') ?? 'https://members.washlover.com';
    final tokenfcm = prefs.getString('fcmtoken');
    //  prefs.clear();
    print(tokenfcm);
    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${endpoint}/api/auth/token');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          final token = data['token'];
          // เก็บ token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('phone', phone);
          await prefs.setString('password', password);
          // prefs.clear();
          print('prefs: $token');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบ token ใน response')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ระบุข้อมูลไม่ถูกต้อง: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดระบุข้อมูลไม่ถูกต้อง: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(
            fontFamily: 'WorkSansSemiBold',
            fontSize: 16.0,
            color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.blue, size: 22.0),
          hintText: hint,
          hintStyle:
              const TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: _togglePasswordVisibility,
                  child: Icon(
                    _obscurePassword
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 15.0,
                    color: Colors.black,
                  ),
                )
              : null,
        ),
        onSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            _handleLogin();
          }
        },
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.go,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40),

                /// ===== Login Card =====
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Card(
                      elevation: 2.0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SizedBox(
                        width: 350.0,
                        height: 160.0,
                        child: Column(
                          children: <Widget>[
                            _buildTextField(
                              hint: 'เบอร์โทรศัพท์',
                              icon: FontAwesomeIcons.phone,
                              controller: _phoneController,
                              focusNode: _focusPhone,
                              nextFocus: _focusPassword,
                            ),
                            Container(
                              width: 250.0,
                              height: 1.0,
                              color: Colors.grey[400],
                            ),
                            _buildTextField(
                              hint: 'PINN',
                              icon: FontAwesomeIcons.key,
                              controller: _passwordController,
                              focusNode: _focusPassword,
                              isPassword: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// ===== Login Button =====
                    Container(
                      margin: const EdgeInsets.only(top: 140.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8E75), Color(0xFFFDC569)],
                          begin: FractionalOffset(0.2, 0.2),
                          end: FractionalOffset(1.0, 1.0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFDC569),
                            offset: Offset(1.0, 6.0),
                            blurRadius: 20.0,
                          ),
                          BoxShadow(
                            color: Color(0xFFFF8E75),
                            offset: Offset(1.0, 6.0),
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        highlightColor: Colors.transparent,
                        splashColor: CustomTheme.loginGradientEnd,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 42.0,
                          vertical: 10.0,
                        ),
                        onPressed: _handleLogin,
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: 'WorkSansBold',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// ===== Divider =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildDivider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Washlover',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: 'WorkSansMedium',
                        ),
                      ),
                    ),
                    _buildDivider(reverse: true),
                  ],
                ),

                /// ===== Incognito Login =====
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('incognito', 'incognito');

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainLayout(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'เข้าสู่ระบบไม่ระบุตัวตน',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: 'WorkSansMedium',
                      ),
                    ),
                  ),
                ),

                /// ===== Google Login =====
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () async {
                      final googleAuth = GoogleAuth();
                      await googleAuth.signInWithGoogle(context);

                      // ถ้าต้องการ user สามารถดึงจาก FirebaseAuth
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        setState(() {
                          slert = 'Login success: ${user.email}';
                        });
                      } else {
                        setState(() {
                          slert = 'ailed: null';
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/google.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Text(
                        //   '\n ${slert} \n ',
                        //   style: TextStyle(
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider({bool reverse = false}) {
    return Container(
      width: 100.0,
      height: 1.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse
              ? [Colors.white, Colors.white10]
              : [Colors.white10, Colors.white],
        ),
      ),
    );
  }
}
