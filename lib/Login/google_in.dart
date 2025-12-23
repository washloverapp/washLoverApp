import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> handleGoogleLogin(BuildContext context) async {
    try {
      // ✅ ใช้ instance + initialize (API ใหม่)
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // 1. เริ่ม Sign-In
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return;

      // 2. ดึง token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. สร้าง Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Login Firebase
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // 5. Firebase ID Token (ส่ง backend ได้)
      final idToken = await userCredential.user?.getIdToken();

      // ignore: avoid_print
      print('Firebase ID Token: $idToken');

      // 6. Redirect หน้า Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e, stack) {
      debugPrint("Login Error: $e");
      debugPrintStack(stackTrace: stack);
      print("Google Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Login with Google"),
          onPressed: () => handleGoogleLogin(context),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Text('Welcome, ${user?.displayName ?? 'User'}'),
      ),
    );
  }
}
