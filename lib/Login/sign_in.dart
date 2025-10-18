import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout_NOaccount.dart';
import 'package:my_flutter_mapwash/Header/snackbar.dart';
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

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
  }

  @override
  void _handleLogin() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainLayout()));
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
    return Container(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
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
                          width: 250.0, height: 1.0, color: Colors.grey[400]),
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
              Container(
                margin: const EdgeInsets.only(top: 140.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8E75), Color(0xFFFDC569)],
                    begin: FractionalOffset(0.2, 0.2),
                    end: FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xFFFDC569),
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0),
                    BoxShadow(
                        color: Color(0xFFFF8E75),
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0),
                  ],
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: CustomTheme.loginGradientEnd,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 42.0, vertical: 10.0),
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
          const SizedBox(height: 10),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 100.0,
                height: 1.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white10, Colors.white],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
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
              Container(
                width: 100.0,
                height: 1.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white10],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NO_accountMainLayout()),
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
        ],
      ),
    );
  }
}
