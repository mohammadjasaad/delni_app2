import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'api_service.dart';
import 'ad_details_page.dart';
import 'ad_model.dart';

class ServiceAdsPage extends StatefulWidget {
  final String label;

  const ServiceAdsPage({super.key, required this.label});

  @override
  State<ServiceAdsPage> createState() => _ServiceAdsPageState();
}

class _ServiceAdsPageState extends State<ServiceAdsPage> {
  late Future<List<Ad>> _adsFuture;
  bool showMap = false; // تبديل بين الشبكة والخريطة

  @override
  void initState() {
    super.initState();
    _adsFuture = ApiService.fetchAds(
      category: "services",
      subCategory: widget.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        backgroundColor: Colors.amber[800],
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.grid_view : Icons.map),
            onPressed: () {
              setState(() => showMap = !showMap);
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Ad>>(
        future: _adsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          final ads = snapshot.data!;
          if (ads.isEmpty) {
            return const Center(
              child: Text("لا توجد خدمات لهذا القسم حالياً"),
            );
          }

          return showMap ? _buildMapView(ads) : _buildGridView(ads);
        },
      ),
    );
  }

  // ============================
  // 🟦 Grid View
  // ============================
  Widget _buildGridView(List<Ad> ads) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ads.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final ad = ads[index];
        final img = ad.mainImage ?? "https://delni.co/images/no-image.png";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
            );
          },
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    img,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),

                // TEXT
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ad.city,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${ad.price} ل.س",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================
  // 🗺️ Map View
  // ============================
  Widget _buildMapView(List<Ad> ads) {
    final fallbackPoint = LatLng(33.5138, 36.2765); // دمشق

    return FlutterMap(
      options: MapOptions(
        initialCenter: fallbackPoint,
        initialZoom: 10,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),

        MarkerLayer(
          markers: ads.map((ad) {
            LatLng point = fallbackPoint;

            if (ad.city.contains("دمشق")) {
              point = LatLng(33.5138, 36.2765);
            } else if (ad.city.contains("حلب")) {
              point = LatLng(36.2154, 37.1596);
            } else if (ad.city.contains("اللاذقية")) {
              point = LatLng(35.5308, 35.7904);
            }

            return Marker(
              width: 60,
              height: 60,
              point: point,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
                  );
                },
                child: Column(
                  children: [
                    const Icon(Icons.location_on,
                        size: 40, color: Colors.red),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ad.price.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
