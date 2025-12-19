import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_mapwash/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_mapwash/Layouts/main_layout.dart';
import 'package:my_flutter_mapwash/theme.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _affiliateController = TextEditingController();

  final _focusName = FocusNode();
  final _focusPhone = FocusNode();
  final _focusPassword = FocusNode();
  final _focusConfirm = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _affiliateController.dispose();

    _focusName.dispose();
    _focusPhone.dispose();
    _focusPassword.dispose();
    _focusConfirm.dispose();

    super.dispose();
  }

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleObscureConfirm() {
    setState(() {
      _obscureConfirm = !_obscureConfirm;
    });
  }

  Widget _divider() =>
      Container(width: 250.0, height: 1.0, color: Colors.grey[400]);

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    bool obscure = false,
    VoidCallback? toggleObscure,
    List<TextInputFormatter>? inputFormatters,
    TextInputAction textInputAction = TextInputAction.next,
    void Function()? onSubmit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        autocorrect: false,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontFamily: 'WorkSansSemiBold',
          fontSize: 16.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.blue),
          hintText: hint,
          hintStyle:
              const TextStyle(fontFamily: 'WorkSansSemiBold', fontSize: 16.0),
          suffixIcon: toggleObscure != null
              ? GestureDetector(
                  onTap: toggleObscure,
                  child: Icon(
                    obscure ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
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
            onSubmit?.call();
          }
        },
      ),
    );
  }

  void _submit() async {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final affiliate = _affiliateController.text.trim();
    if (phone.isEmpty || name.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showDialog("ผิดพลาด", "กรุณาระบุข้อมูลให้ครบถ้วน");
      return;
    }
    if (password.length != 6) {
      _showDialog("ผิดพลาด", "PIN ต้องมีความยาว 6 ตัว");
      return;
    }
    if (password != confirm) {
      _showDialog("ผิดพลาด", "รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน");
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final endpoint = prefs.getString('endpoint') ?? "";

      if (endpoint.isEmpty) {
        _showDialog("ผิดพลาด", "ไม่พบ Endpoint ในระบบ");
        return;
      }
      var headers = {
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${endpoint}/api/register'),
      );
      request.fields.addAll({
        'phone': phone,
        'nickname': name,
        'password': password,
        // 'affiliate': affiliate, // ถ้ามีระบบ affiliate
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      print("Status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Response body: $responseBody");
        final data = jsonDecode(responseBody);
        if (data['status'] == 'error') {
          _showDialog("ผิดพลาด", data['msg'] ?? "เกิดข้อผิดพลาดบางประการ");
        } else {
          await prefs.setString('phone', phone);
          await prefs.setString('name', name);
          await prefs.setString('password', password);
          _checkLogin();
        }
      } else {
        print("Error reason: ${response.reasonPhrase}");
        _showDialog(
            "ผิดพลาด", "พบข้อมูลสมาชิกนี้แล้ว (${response.statusCode})");
      }
    } catch (e) {
      _showDialog("ผิดพลาด", "พบข้อมูลสมาชิกนี้แล้ว");
      print("Exception: $e");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    final endpoint = prefs.getString('endpoint');

    final tokenfcm = prefs.getString('fcm_token') ?? "";

    double currentLat = 13.7563;
    double currentLng = 100.5018;

    await prefs.setDouble('lat', currentLat);
    await prefs.setDouble('lng', currentLng);

    if (token != null || phone != null || password != null) {
      try {
        final url = Uri.parse('$endpoint/api/auth/token');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone': phone,
            'password': password,
          }),
        );
        if (response.statusCode == 200) {
          await api_config.saveTokenFcmApi(tokenfcm, phone);
          final data = json.decode(response.body);
          await prefs.setString('token', data['token']);
          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          });
          return;
        } else {
          await prefs.clear();
        }
      } catch (e) {
        debugPrint('Login check error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Card(
                    elevation: 2.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Container(
                      width: 300.0,
                      child: Column(
                        children: [
                          _buildTextField(
                            hint: 'ชื่อเล่น',
                            icon: FontAwesomeIcons.user,
                            controller: _nameController,
                            focusNode: _focusName,
                            nextFocus: _focusPhone,
                          ),
                          _divider(),
                          _buildTextField(
                            hint: 'เบอร์โทรศัพท์',
                            icon: FontAwesomeIcons.phone,
                            controller: _phoneController,
                            focusNode: _focusPhone,
                            nextFocus: _focusPassword,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          _divider(),
                          _buildTextField(
                            hint: 'PINN',
                            icon: FontAwesomeIcons.key,
                            controller: _passwordController,
                            focusNode: _focusPassword,
                            nextFocus: _focusConfirm,
                            obscure: _obscurePassword,
                            toggleObscure: _toggleObscurePassword,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          _divider(),
                          _buildTextField(
                            hint: 'Confirm PINN',
                            icon: FontAwesomeIcons.key,
                            controller: _confirmPasswordController,
                            focusNode: _focusConfirm,
                            obscure: _obscureConfirm,
                            toggleObscure: _toggleObscureConfirm,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.go,
                            onSubmit: _submit,
                          ),
                          _divider(),
                          _buildTextField(
                            hint: 'เพื่อนแนะนำ ( CODE )',
                            icon: FontAwesomeIcons.userGroup,
                            controller: _affiliateController,
                            focusNode: FocusNode(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 440.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      gradient: const LinearGradient(
                        colors: [
                          CustomTheme.loginGradientEnd,
                          CustomTheme.loginGradientStart
                        ],
                        begin: FractionalOffset(0.2, 0.2),
                        end: FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color: CustomTheme.loginGradientStart,
                            offset: Offset(1.0, 6.0),
                            blurRadius: 20.0),
                        BoxShadow(
                            color: CustomTheme.loginGradientEnd,
                            offset: Offset(1.0, 6.0),
                            blurRadius: 20.0),
                      ],
                    ),
                    child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: CustomTheme.loginGradientEnd,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 42.0, vertical: 10.0),
                      onPressed: _submit,
                      child: const Text(
                        'SIGN UP',
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
            ],
          ),
        ),
      ),
    );
  }
}
