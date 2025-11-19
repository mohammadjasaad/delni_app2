import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'verify_whatsapp_code_page.dart';

class LoginPhonePage extends StatefulWidget {
  const LoginPhonePage({super.key});

  @override
  State<LoginPhonePage> createState() => _LoginPhonePageState();
}

class _LoginPhonePageState extends State<LoginPhonePage> {
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();

    if (phone.isEmpty || !phone.startsWith("+")) {
      _showError("اكتب رقمك مع رمز الدولة مثل: +963988000000");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse("https://delni.co/api/send-whatsapp-code"),
        headers: {"Accept": "application/json"},
        body: {"phone": phone},
      );

      final data = jsonDecode(resp.body);

      if (data["status"] == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyWhatsappCodePage(phone: phone),
          ),
        );
      } else {
        _showError(data["message"] ?? "تعذر إرسال الرمز");
      }
    } catch (e) {
      _showError("⚠️ تأكد من اتصال الإنترنت");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ زر الرجوع
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFff9a9e), Color(0xFFfad0c4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.message, size: 60, color: Colors.white),
                ),

                const SizedBox(height: 20),

                const Text(
                  "تسجيل الدخول عبر واتساب",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "+9639xxxxxxxx",
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.phone, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(.25),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 6,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.green)
                        : const Text("إرسال رمز التحقق", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "سيتم إرسال رمز مؤقت عبر واتساب",
                  style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
