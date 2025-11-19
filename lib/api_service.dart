import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'ad_model.dart';

class ApiService {
  // 🧠 اختيار السيرفر حسب النظام
  static final String baseHost = Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : Platform.isIOS
          ? 'http://127.0.0.1:8000'
          : 'https://delni.co';

  static final String baseUrl = '$baseHost/api';

  // --------------------------------------------------------
  // 🟢 تسجيل الدخول عبر واتساب
  // --------------------------------------------------------
  static Future<bool> sendWhatsappCode(String phone) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/send-whatsapp-code'),
      headers: {'Accept': 'application/json'},
      body: {'phone': phone},
    );
    final data = jsonDecode(resp.body);
    return data["status"] == "success";
  }

  static Future<Map<String, dynamic>?> verifyWhatsappCode(
      String phone, String code) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/verify-whatsapp-code'),
      headers: {'Accept': 'application/json'},
      body: {'phone': phone, 'code': code},
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return null;
  }

  // --------------------------------------------------------
  // 🟡 عرض الإعلانات
  // --------------------------------------------------------
  static Uri _searchUri({
    String? q,
    String? query,
    String? city,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sort,
    bool isFeatured = false,
  }) {
    final effectiveQuery = query ?? q;
    final params = <String, String>{};

    if (effectiveQuery != null && effectiveQuery.trim().isNotEmpty) {
      params['query'] = effectiveQuery.trim();
    }
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    if (isFeatured) params['is_featured'] = '1';

    return Uri.parse('$baseUrl/ads/search')
        .replace(queryParameters: params.isEmpty ? null : params);
  }

static Future<List<Ad>> fetchAds({
  String? q,
  String? query,
  String? city,
  String? category,
  String? subCategory,
  double? minPrice,
  double? maxPrice,
  String? sort,
  bool isFeatured = false,
}) async {
  final params = <String, String>{};

  if (q != null && q.trim().isNotEmpty) params['query'] = q;
  if (query != null && query.trim().isNotEmpty) params['query'] = query;
  if (city != null && city.isNotEmpty) params['city'] = city;
  if (category != null && category.isNotEmpty) params['category'] = category;

  if (subCategory != null && subCategory.isNotEmpty) {
    params['sub_category'] = subCategory;
  }

  if (minPrice != null) params['min_price'] = minPrice.toString();
  if (maxPrice != null) params['max_price'] = maxPrice.toString();
  if (sort != null && sort.isNotEmpty) params['sort'] = sort;
  if (isFeatured) params['is_featured'] = '1';

  final uri = Uri.parse('$baseUrl/ads/search')
      .replace(queryParameters: params);

  final resp = await http.get(uri, headers: {'Accept': 'application/json'});

  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    return (data['ads'] as List).map((e) => Ad.fromJson(e)).toList();
  }

  throw Exception('فشل في جلب الإعلانات');
}


  // --------------------------------------------------------
  // 🟣 جلب البانرات (الصفحة الرئيسية)
  // --------------------------------------------------------
static Future<List<String>> fetchBanners() async {
  final resp = await http.get(
    Uri.parse('$baseUrl/banners'),
    headers: {'Accept': 'application/json'},
  );

  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    final banners = data['banners'] as List;

    return banners.map<String>((b) {
      final path = (b['image'] ?? b['image_desktop'] ?? b['full_url'] ?? '').toString();

      return path.startsWith('http')
          ? path
          : 'https://delni.co/storage/$path'; // ✅ هنا الحل
    }).toList();
  }

  return [];
}


  // --------------------------------------------------------
  // 🟣 جلب بانرات دلني مول
  // --------------------------------------------------------
  static Future<List<dynamic>> fetchMallBanners() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/mall/banners'),
      headers: {'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body)['banners'];
    return [];
  }

  // --------------------------------------------------------
  // 🔐 طلب GET مصادق (مع التوكن)
  // --------------------------------------------------------
  static Future<Map<String, dynamic>?> authenticatedGet(
      String endpoint, String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    return null;
  }

  // --------------------------------------------------------
  // 🟦 إعلاناتي (لوحة التحكم)
  // --------------------------------------------------------
  static Future<List<Ad>> fetchMyAds(String token) async {
    final resp = await authenticatedGet('/my-ads', token);
    if (resp == null || resp['ads'] == null) return [];
    return (resp['ads'] as List).map((e) => Ad.fromJson(e)).toList();
  }

  // --------------------------------------------------------
  // 🟩 إضافة إعلان جديد
  // --------------------------------------------------------
  static Future<bool> createAd({
    required String title,
    required String description,
    required String price,
    required String city,
    required String category,
    required List<XFile> images,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/ads');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..fields.addAll({
        'title': title,
        'description': description,
        'price': price,
        'city': city,
        'category': category,
      });

    for (final x in images) {
      req.files.add(await http.MultipartFile.fromPath(
        'images[]',
        x.path,
        filename: basename(x.path),
      ));
    }

    final resp = await req.send();
    return resp.statusCode == 201 || resp.statusCode == 200;
  }

  // --------------------------------------------------------
  // ❌ حذف إعلان (يحتاج توكن)
  // --------------------------------------------------------
  static Future<bool> deleteAd(int id, String token) async {
    final resp = await http.delete(
      Uri.parse('$baseUrl/ads/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return resp.statusCode == 200;
  }
}
