import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // ✅ للـ Clipboard
import 'ad_model.dart';
import 'l10n/app_localizations.dart';

class AdDetailsPage extends StatefulWidget {
  final Ad ad;
  const AdDetailsPage({super.key, required this.ad});

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  int _index = 0;

  Future<void> _callSeller(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إجراء المكالمة')),
      );
    }
  }

  Future<void> _whatsappSeller(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح واتساب')),
      );
    }
  }

  void _copyPhone(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 تم نسخ الرقم')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ad = widget.ad;
    final images = ad.absoluteImages;

    // رقم تجريبي إذا ما في رقم
    final phone = ad.email ?? "963999999999";

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('ad_details')),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final link = images.isNotEmpty ? images.first : '';
              Share.share('${ad.title} - ${ad.price} ل.س\n$link');
            },
          )
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: PageView.builder(
              itemCount: images.isEmpty ? 1 : images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                if (images.isEmpty) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image, size: 60)),
                  );
                }
                return CachedNetworkImage(
                  imageUrl: images[i],
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) =>
                      const Center(child: Icon(Icons.broken_image)),
                );
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                  child: Text('${_index + 1}/${images.length}',
                      style: const TextStyle(fontSize: 12))),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('${ad.price} ل.س',
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(children: [
                      const Icon(Icons.location_city),
                      const SizedBox(width: 8),
                      Text(ad.city.isEmpty ? 'غير محدد' : ad.city),
                    ]),
                    const SizedBox(height: 8),

                    Row(children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 8),
                      Text(ad.category),
                    ]),

                    const Divider(height: 32),

                    Text(t.translate('description'),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      ad.description.isEmpty ? 'لا يوجد وصف' : ad.description,
                      style: const TextStyle(fontSize: 16),
                    ),

                    const Divider(height: 32),

                    // ✅ أزرار التواصل
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.call),
                          label: const Text("اتصال"),
                          onPressed: () => _callSeller(phone),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text("واتساب"),
                          onPressed: () => _whatsappSeller(phone),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          icon: const Icon(Icons.copy),
                          label: const Text("نسخ"),
                          onPressed: () => _copyPhone(phone),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
