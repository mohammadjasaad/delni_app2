import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'ad_model.dart';

class ApiService {
  // ⛳️ العنوان الأساسي للسيرفر (تأكد من أنه http وليس https إن لم يكن مفعلًا)
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // ✅ 1. جلب جميع الإعلانات
  static Future<List<Ad>> fetchAds() async {
    final response = await http.get(Uri.parse('$baseUrl/ads'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Ad.fromJson(item)).toList();
    } else {
      print('⚠️ fetchAds() error: ${response.statusCode} - ${response.body}');
      throw Exception('فشل في جلب الإعلانات');
    }
  }

  // ✅ 2. جلب إعلانات المستخدم (تتطلب توكن)
  static Future<http.Response> authenticatedGet({
    required Uri url,
    required String token,
  }) {
    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // ✅ 3. حذف إعلان
  static Future<bool> deleteAd({
    required int adId,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/ads/$adId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('⚠️ deleteAd() error: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // ✅ 4. البحث في الإعلانات
  static Future<List<Ad>> searchAds(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/ads?search=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Ad.fromJson(item)).toList();
    } else {
      print('⚠️ searchAds() error: ${response.statusCode} - ${response.body}');
      throw Exception('فشل في البحث');
    }
  }

  // ✅ 5. إنشاء إعلان جديد مع صور متعددة
static Future<bool> createAd({
  required String title,
  required String description,
  required String price,
  required String city,
  required String category,
  required int userId,
  required List<XFile> images,
  required String token,
}) async {
  final uri = Uri.parse('$baseUrl/ads');
  final request = http.MultipartRequest('POST', uri);

  request.fields['title'] = title;
  request.fields['description'] = description;
  request.fields['price'] = price;
  request.fields['city'] = city;
  request.fields['category'] = category;
  request.fields['user_id'] = userId.toString();

  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';

  for (var image in images) {
    if (kIsWeb) {
      // 🟣 Web: استخدم readAsBytes
      final bytes = await image.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'images[]',
        bytes,
        filename: image.name,
        contentType: MediaType('image', 'jpeg'), // اختياري
      );
      request.files.add(multipartFile);
    } else {
      // 📱 Mobile: استخدم fromPath
      final file = await http.MultipartFile.fromPath(
        'images[]',
        image.path,
        filename: basename(image.path),
      );
      request.files.add(file);
    }
  }

  try {
    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      print('❌ createAd() error: ${response.statusCode}');
      print('🧾 Error body: $respStr');
      return false;
    }
  } catch (e) {
    print('🔥 Exception in createAd: $e');
    return false;
  }
 }
}
