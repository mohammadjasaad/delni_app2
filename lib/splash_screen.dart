import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // ← عدل المسار حسب ملف تسجيل الدخول لديك
// أو استبدلها بـ home_page.dart إذا تريد الانتقال مباشرة إلى الرئيسية

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // ⏱️ الانتظار ثانيتين ثم الانتقال
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()), // ← أو HomePage()
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD600), // اللون الأصفر الخاص بـ Delni
      body: Center(
        child: Image.asset(
          'assets/images/delni-logo.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
