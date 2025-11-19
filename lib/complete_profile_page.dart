import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main_navigation.dart';

class CompleteProfilePage extends StatefulWidget {
  final String token;
  final String phone;

  const CompleteProfilePage({
    super.key,
    required this.token,
    required this.phone,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showError("أدخل اسمك الحقيقي من فضلك");
      return;
    }

    setState(() => _loading = true);

    try {
      final resp = await http.post(
        Uri.parse("https://delni.co/api/update-profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: {
          "name": name,
        },
      );

      final data = jsonDecode(resp.body);

      if (data["status"] == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", widget.token);
        await prefs.setString("phone", widget.phone);
        await prefs.setString("name", name);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainNavigation(
              phone: widget.phone,
              userToken: widget.token,
            ),
          ),
        );
      } else {
        _showError(data["message"] ?? "حدث خطأ أثناء حفظ البيانات");
      }
    } catch (e) {
      _showError("⚠️ مشكلة أثناء الاتصال بالخادم");
    } finally {
      if (mounted) setState(() => _loading = false);
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
      backgroundColor: const Color(0xFFFDFCF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.person_pin_rounded,
                    size: 110, color: Colors.amber),
                const SizedBox(height: 16),

                const Text(
                  "مرحباً بك 👋",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                Text(
                  "لنكمل حسابك بشكل جميل 🌟\nاسمك سيظهر للآخرين في محادثات & تعليقات",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "اسمك",
                    prefixIcon: const Icon(Icons.badge, color: Colors.amber),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child:
                                CircularProgressIndicator(color: Colors.black),
                          )
                        : const Text("حفظ ومتابعة",
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
