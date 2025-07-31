import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'login_page.dart';
import 'l10n/app_localizations.dart';
// import 'splash_page.dart'; // إذا أنشأت صفحة البداية لاحقًا

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delni',
      debugShowCheckedModeBanner: false,

      // ✅ استخدم لغة الجهاز تلقائيًا، أو ثبتها مؤقتًا
      // locale: const Locale('ar'),

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
      ),

      home: const LoginPage(), // أو SplashPage إذا جاهزة
    );
  }
}
