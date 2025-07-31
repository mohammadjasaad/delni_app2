import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Main_Navigation.dart';
import 'register_page.dart';
import 'l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final url = Uri.parse("http://157.245.19.128:8000/api/login");

    try {
final response = await http.post(
  Uri.parse('https://delni.co/api/login'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  body: jsonEncode({
    'email': emailController.text,
    'password': passwordController.text,
  }),
);


      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('email', email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(
              userToken: token,
              email: email,
            ),
          ),
        );
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'فشل تسجيل الدخول';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('خطأ'),
            content: Text(message.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('خطأ في الاتصال'),
          content: Text('فشل الاتصال بالخادم: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.lock_open, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    t.translate('login'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 📧 البريد الإلكتروني
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: t.translate('email'),
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? '${t.translate('email')} مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  // 🔒 كلمة المرور
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: t.translate('password'),
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? '${t.translate('password')} مطلوبة' : null,
                  ),
                  const SizedBox(height: 24),

                  // 🔘 زر تسجيل الدخول
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              t.translate('login'),
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                   // 🔐 رابط نسيت كلمة المرور
TextButton(
  onPressed: () {
    // يمكنك لاحقًا فتح صفحة reset_password_page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("سيتم إضافة ميزة استعادة كلمة المرور قريبًا")),
    );
  },
  child: Text(
    t.translate('forgot_password'),
    style: const TextStyle(decoration: TextDecoration.underline),
  ),
),

                  // 📝 رابط التسجيل
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      t.translate('register'),
                      style: const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
