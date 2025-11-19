import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class TaxiMapPage extends StatefulWidget {
  const TaxiMapPage({super.key});

  @override
  State<TaxiMapPage> createState() => _TaxiMapPageState();
}

class _TaxiMapPageState extends State<TaxiMapPage> {
  final MapController _mapController = MapController();

  LatLng? userLocation; // ← موقع المستخدم الحقيقي
  bool _loading = true;

  // سائقين وهميين (لاحقاً سنجلب من السيرفر)
  final List<LatLng> fakeDrivers = [
    LatLng(33.5145, 36.2750),
    LatLng(33.5120, 36.2785),
    LatLng(33.5155, 36.2732),
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    // ✅ طلب الإذن
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    // ✅ الحصول على موقع المستخدم
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(pos.latitude, pos.longitude);
      _loading = false;
    });

    // ✅ تحريك الخريطة إلى موقع المستخدم
    _mapController.move(userLocation!, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚖 Delni Taxi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : userLocation == null
              ? const Center(child: Text("⚠️ لم يتم السماح بالوصول إلى الموقع"))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: userLocation,
                    zoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    // ✅ نقطة موقع المستخدم
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation!,
                          width: 45,
                          height: 45,
                          child: const Icon(Icons.my_location, color: Colors.blue, size: 38),
                        ),

                        // ✅ السائقين
                        for (final driver in fakeDrivers)
                          Marker(
                            point: driver,
                            width: 45,
                            height: 45,
                            child: const Icon(Icons.local_taxi, color: Colors.amber, size: 38),
                          ),
                      ],
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🚕 تم إرسال طلب تاكسي! سيتم تطوير الطلب الآن")),
          );
        },
        label: const Text('طلب تاكسي'),
        icon: const Icon(Icons.send),
      ),
    );
  }
}
