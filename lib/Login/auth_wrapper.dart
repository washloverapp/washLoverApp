import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';

class GoogleAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 1️⃣ เรียก popup ของ Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Login cancelled by user');
        return;
      }

      final googleAuth = await googleUser.authentication;

      // 2️⃣ สร้าง credential สำหรับ Firebase bosshub-io
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3️⃣ Sign in Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        print('Firebase login failed');
        return;
      }

      // 4️⃣ ดึง ID Token ของ user
      final idToken = await user.getIdToken();
      // print('Firebase ID Token: $idToken'); 
      if (idToken == null) {
        print('Failed to get ID Token');
        return;
      }

      // 5️⃣ ส่ง token ไป backend
      final response = await _dio.post(
        'https://members.washlover.com/api/auth/google',
        data: {'id_token': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        print('Login success!');
        // Navigator.pushReplacement หรือ GoRouter redirect ไปหน้า dashboard
      } else {
        final errorMsg = response.data['error'] ?? 'Unknown error';
        print('Backend login error: $errorMsg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $errorMsg')),
        );
      }
    } catch (e, st) {
      print('Login Error: $e');
      print(st);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('การเข้าสู่ระบบด้วย Google ล้มเหลว: $e')),
      );
    }
  }
}
