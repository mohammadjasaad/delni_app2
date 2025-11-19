// lib/login_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'home_page.dart';

enum _LoginTab { email, whatsapp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // التبويب الحالي
  _LoginTab _currentTab = _LoginTab.email;

  // حقول البريد
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _rememberMe = false;

  // حقول واتساب
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  bool _codeSent = false;

  bool _loading = false;

  // ============================
  //   مساعد لعرض رسالة
  // ============================
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ============================
  //   دخول بالبريد (UI جاهز – API لاحقاً)
  // ============================
  Future<void> _loginWithEmail() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnack('يرجى إدخال البريد وكلمة المرور');
      return;
    }

    // 🔸 هنا فقط عرض رسالة – يمكنك لاحقاً ربطها مع API خاص بالبريد
    _showSnack('تسجيل الدخول بالبريد سيتم تفعيله قريباً ✅');
  }

  // ============================
  //   إرسال كود واتساب
  // ============================
  Future<void> _sendWhatsappCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnack('يرجى إدخال رقم الهاتف مع رمز الدولة');
      return;
    }

    setState(() => _loading = true);
    try {
      final ok = await ApiService.sendWhatsappCode(phone);
      if (ok) {
        setState(() => _codeSent = true);
        _showSnack('تم إرسال كود واتساب إلى $phone');
      } else {
        _showSnack('فشل إرسال الكود، حاول مرة أخرى');
      }
    } catch (e) {
      _showSnack('حدث خطأ أثناء إرسال الكود');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ============================
  //   تأكيد كود واتساب + دخول
  // ============================
  Future<void> _verifyWhatsappAndLogin() async {
    final phone = _phoneCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      _showSnack('يرجى إدخال رقم الهاتف والكود');
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await ApiService.verifyWhatsappCode(phone, code);
      if (data == null) {
        _showSnack('الكود غير صحيح أو منتهي');
        return;
      }

      final token = data['token']?.toString() ?? '';
      if (token.isEmpty) {
        _showSnack('لم يتم استلام التوكن من السيرفر');
        return;
      }

      // ✅ دخول إلى الصفحة الرئيسية
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            phone: phone,
            userToken: token,
          ),
        ),
      );
    } catch (e) {
      _showSnack('خطأ أثناء التحقق من الكود');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF070B17); // خلفية كحلية مثل الموقع

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ============================
              //   لوجو أعلى الشاشة
              // ============================
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD600),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'Delni.co',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ============================
              //   الكرت الرئيسي الأبيض
              // ============================
              Container(
                width: 420,
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ============================
                    //   هيدر أصفر
                    // ============================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD600),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      child: Column(
                        children: const [
                          SizedBox(height: 8),
                          Text(
                            'مرحباً بك في Delni.co',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'اختر طريقة تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ============================
                    //   التبويبات (هاتف / واتساب – بريد)
                    // ============================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            _buildTabButton(
                              title: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              selected: _currentTab == _LoginTab.email,
                              onTap: () => setState(
                                  () => _currentTab = _LoginTab.email),
                            ),
                            _buildTabButton(
                              title: 'الهاتف / واتساب',
                              icon: Icons.phone_iphone,
                              selected: _currentTab == _LoginTab.whatsapp,
                              onTap: () => setState(
                                  () => _currentTab = _LoginTab.whatsapp),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ============================
                    //   محتوى التبويب
                    // ============================
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _currentTab == _LoginTab.email
                            ? _buildEmailForm()
                            : _buildWhatsappForm(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ============================
                    //   نص أسفل الكرت
                    // ============================
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 16, right: 16),
                      child: Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'لا تملك حساباً؟ أنشئ حساباً جديداً من الموقع Delni.co',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  //   زر التبويب
  // ============================
  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: selected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFD600) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.black : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  //   نموذج البريد الإلكتروني
  // ============================
  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'البريد الإلكتروني',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _emailCtrl,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            hintText: 'example@mail.com',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'كلمة المرور',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _passwordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: '••••••••',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
            ),
            const Text('تذكرني'),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  _showSnack('استعادة كلمة المرور من الموقع Delni.co'),
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD600),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _loading ? null : _loginWithEmail,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // ============================
  //   نموذج الهاتف / واتساب
  // ============================
  Widget _buildWhatsappForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'رقم الهاتف (مع رمز الدولة)',
            style: TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _phoneCtrl,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+9639XXXXXXXX',
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (_codeSent) ...[
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أدخل كود واتساب',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _codeCtrl,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '1234',
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: _loading ? null : _sendWhatsappCode,
            child: _loading && !_codeSent
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'إرسال كود واتساب',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        if (_codeSent)
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: _loading ? null : _verifyWhatsappAndLogin,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'تأكيد الكود والدخول',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
      ],
    );
  }
}
