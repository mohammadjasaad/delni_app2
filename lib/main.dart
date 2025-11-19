import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'main_navigation.dart';
import 'l10n/app_localizations.dart';
import 'login_page.dart'; // لو عندك صفحة login
// استبدلها حسب اسم الملف عندك

void main() {
  runApp(const DelniApp());
}

class DelniApp extends StatelessWidget {
  const DelniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delni',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      home: const SplashScreen(),
    );
  }
}

// 🟡 شاشة البداية (Splash)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // الانتقال بعد 2 ثانية
    Timer(const Duration(seconds: 2), () {
      // ⚙️ هنا منطق التحقق من المستخدم
      // مثال: إذا كان المستخدم ضيف، افتح صفحة تسجيل الدخول
      // لو بدنا لاحقًا نفعل SharedPreferences للتحقق من login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(
            phone: "guest",
            userToken: "guest-token",
            initialTabIndex: 0,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD600), // خلفية Delni الصفراء
      body: Center(
        child: Image.asset(
          'assets/images/delni-logo.png',
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}
