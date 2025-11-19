import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main_navigation.dart';
import 'complete_profile_page.dart';

class VerifyWhatsappCodePage extends StatefulWidget {
  final String phone;

  const VerifyWhatsappCodePage({super.key, required this.phone});

  @override
  State<VerifyWhatsappCodePage> createState() => _VerifyWhatsappCodePageState();
}

class _VerifyWhatsappCodePageState extends State<VerifyWhatsappCodePage> {
  final TextEditingController _codeCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 4) {
      _showError("أدخل الرمز المكون من 4 أرقام");
      return;
    }

    setState(() => _loading = true);

    try {
      final resp = await http.post(
        Uri.parse("https://delni.co/api/verify-whatsapp-code"),
        headers: {"Accept": "application/json"},
        body: {"phone": widget.phone, "code": code},
      );

      final data = jsonDecode(resp.body);

      if (data["status"] == "success" && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("phone", widget.phone);

        final user = data["user"];
        final name = user?["name"] ?? "";

        // ✅ إذا ما عنده اسم → نرسل لصفحة استكمال البيانات
        if (name.isEmpty || name == widget.phone) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                token: data["token"],
                phone: widget.phone,
              ),
            ),
          );
        } else {
          // ✅ لديه اسم → ندخله مباشرة
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainNavigation(
                phone: widget.phone,
                userToken: data["token"],
              ),
            ),
          );
        }
      } else {
        _showError(data["message"] ?? "رمز غير صحيح");
      }
    } catch (e) {
      _showError("⚠️ حدث خطأ في الاتصال");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تأكيد رمز واتساب")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("أدخل رمز التحقق المرسل إلى ${widget.phone}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _codeCtrl,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(labelText: "رمز التحقق"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : const Text("تأكيد", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
