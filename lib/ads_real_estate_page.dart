import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdsRealEstatePage extends StatefulWidget {
  final String userToken;
  const AdsRealEstatePage({super.key, required this.userToken});

  @override
  State<AdsRealEstatePage> createState() => _AdsRealEstatePageState();
}

class _AdsRealEstatePageState extends State<AdsRealEstatePage> {
  List<dynamic> _ads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final url = Uri.parse('https://delni.co/api/ads?category=عقارات');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _ads = data;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏠 العقارات"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ads.isEmpty
              ? const Center(child: Text("لا توجد إعلانات عقارية حالياً"))
              : Column(
                  children: [
                    // 🗺️ خريطة
                    SizedBox(
                      height: 250,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(33.5, 36.3),
                          zoom: 8,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: const ['a', 'b', 'c'],
                          ),
                        ],
                      ),
                    ),
                    // 🏠 قائمة الإعلانات
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: _ads.length,
                        itemBuilder: (context, index) {
                          final ad = _ads[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: ad['images'] != null &&
                                      ad['images'].isNotEmpty
                                  ? Image.network(
                                      'https://delni.co/storage/${ad['images'][0]}',
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(Icons.image_not_supported),
                              title: Text(ad['title'] ?? "بدون عنوان"),
                              subtitle: Text(ad['city'] ?? ""),
                              trailing: Text(
                                "${ad['price'] ?? '---'} ل.س",
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
