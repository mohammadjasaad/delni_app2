import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String label;
  final IconData icon;

  const ServiceDetailsPage({
    super.key,
    required this.label,
    required this.icon,
  });

  // فتح واتساب
  Future<void> openWhatsapp() async {
    final url = Uri.parse(
        "https://wa.me/963988779548?text=مرحباً%20أريد%20خدمة%20$label");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // اتصال
  Future<void> callPhone() async {
    final url = Uri.parse("tel:+963988779548");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(label),
        backgroundColor: Colors.amber[800],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ===============================
            //   صورة هيدر كبيرة
            // ===============================
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://delni.co/images/services-header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ===============================
            //   أيقونة واسم الخدمة
            // ===============================
            Icon(icon, size: 70, color: Colors.amber[800]),
            const SizedBox(height: 12),

            Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ===============================
            //   وصف الخدمة
            // ===============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                "خدمة $label عبر منصة دلني — نقدم لك أفضل جودة، سرعة، "
                "ومهنيّة عالية. اطلب خدمتك الآن بكل سهولة عبر الواتساب أو الاتصال المباشر.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===============================
            //   أزرار التواصل
            // ===============================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // زر واتساب
                ElevatedButton.icon(
                  onPressed: openWhatsapp,
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 22),
                  label: const Text("تواصل واتساب"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(width: 18),

                // زر اتصال
                ElevatedButton.icon(
                  onPressed: callPhone,
                  icon: const Icon(Icons.call, size: 22),
                  label: const Text("اتصال"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
