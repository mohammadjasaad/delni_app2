import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'verify_whatsapp_code_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError("الرجاء إدخال رقم الهاتف");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resp = await http.post(
        Uri.parse("https://delni.co/api/send-whatsapp-code"),
        headers: {"Accept": "application/json"},
        body: {"phone": _phoneCtrl.text.trim()},
      );

      final data = resp.body;
      if (resp.statusCode == 200 && data.contains("success")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerifyWhatsappCodePage(phone: _phoneCtrl.text.trim()),
          ),
        );
      } else {
        _showError("تعذر إرسال الكود");
      }
    } catch (e) {
      _showError("خطأ: $e");
    } finally {
      setState(() => _isLoading = false);
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
      appBar: AppBar(
        title: const Text("إنشاء حساب"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add, size: 64, color: Colors.amber),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("إرسال الكود عبر واتساب"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
