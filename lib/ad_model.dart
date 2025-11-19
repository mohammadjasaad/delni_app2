// lib/ad_model.dart
import 'dart:convert'; // 👈 الحل الأساسي للخطأ

class Ad {
  final int id;
  final String title;
  final String description;
  final String price;
  final String city;
  final String category;
  final String? subCategory;
  final String? email;
  final List<String> images;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    required this.category,
    this.subCategory,
    this.email,
    required this.images,
  });

  // ---------------------------------------------
  // 🔥 أول صورة جاهزة للعرض
  // ---------------------------------------------
  String? get mainImage {
    if (images.isEmpty) return null;
    return absoluteImages.first;
  }

  // ---------------------------------------------
  // 🔥 Getter بديل
  // ---------------------------------------------
  String? get firstImage => mainImage;

  // ---------------------------------------------
  // 🔥 تحويل الصور إلى روابط كاملة
  // ---------------------------------------------
  List<String> get absoluteImages {
    return images.map((img) {
      if (img.startsWith('http')) return img;
      return 'https://delni.co/storage/$img';
    }).toList();
  }

  // ---------------------------------------------
  // 🔥 JSON ⇢ Model
  // ---------------------------------------------
  factory Ad.fromJson(Map<String, dynamic> json) {
    final imgs = <String>[];

    if (json['images'] is List) {
      for (final img in json['images']) {
        imgs.add(img.toString());
      }
    } else if (json['images'] is String) {
      try {
        final decoded = jsonDecode(json['images']);
        if (decoded is List) {
          for (final img in decoded) {
            imgs.add(img.toString());
          }
        }
      } catch (_) {}
    }

    return Ad(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      city: json['city'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category']?.toString(),
      email: json['email']?.toString(),
      images: imgs,
    );
  }
}
