import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../ad_model.dart';

class AdCard extends StatelessWidget {
  final Ad ad;
  final VoidCallback? onTap;
  const AdCard({super.key, required this.ad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = ad.mainImage; // من الموديل (يحول للمطلق)
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة
            AspectRatio(
              aspectRatio: 1.3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: img == null
                    ? Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported)))
                    : CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                      ),
              ),
            ),
            // النصوص
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${ad.price.toStringAsFixed(1)} ر.س - ${ad.city.isEmpty ? 'مدينـة' : ad.city}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
