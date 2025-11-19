import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'ad_model.dart';
import 'api_service.dart';
import 'ad_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? selectedCategory;
  String? selectedCity;
  String selectedSort = 'latest';
  bool isLoading = false;
  bool showMap = false;
  List<Ad> searchResults = [];

  MapController mapController = MapController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'عقارات', 'icon': FontAwesomeIcons.building},
    {'name': 'سيارات', 'icon': FontAwesomeIcons.car},
    {'name': 'الخدمات', 'icon': FontAwesomeIcons.screwdriverWrench},
    {'name': 'دلني تاكسي', 'icon': FontAwesomeIcons.taxi},
    {'name': 'دلني عاجل', 'icon': FontAwesomeIcons.truckMedical},
    {'name': 'دلني مول', 'icon': FontAwesomeIcons.store},
  ];

  final List<String> cities = [
    'دمشق',
    'حلب',
    'حمص',
    'اللاذقية',
    'طرطوس',
    'حماة',
    'إدلب',
    'دير الزور',
  ];

  final Map<String, String> sortOptions = {
    'latest': 'الأحدث أولاً',
    'price_asc': 'من الأرخص إلى الأغلى',
    'price_desc': 'من الأغلى إلى الأحدث',
  };

  Future<void> _performSearch({bool fromMap = false}) async {
    final query = _searchController.text.trim();
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());

    setState(() => isLoading = !fromMap);

    try {
      final results = await ApiService.fetchAds(
        q: query,
        city: selectedCity,
        category: selectedCategory,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (showMap && fromMap) {
        // ✅ فلترة حسب حدود الخريطة
        final bounds = mapController.bounds;
        if (bounds != null) {
          final sw = bounds.southWest;
          final ne = bounds.northEast;
          searchResults = results.where((ad) {
            if (ad.lat == null || ad.lng == null) return false;
            return ad.lat! >= sw.latitude &&
                ad.lat! <= ne.latitude &&
                ad.lng! >= sw.longitude &&
                ad.lng! <= ne.longitude;
          }).toList();
        }
      } else {
        searchResults = results;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء البحث')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    selectedCategory = null;
    selectedCity = null;
    selectedSort = 'latest';
    searchResults.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text('البحث المتقدم'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(showMap ? Icons.grid_view_rounded : Icons.map_rounded,
                color: Colors.amber.shade800),
            onPressed: () => setState(() => showMap = !showMap),
          ),
        ],
      ),
      body: showMap ? _buildMapView() : _buildListView(),
    );
  }

  // ✅ واجهة عرض القائمة
  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن إعلان...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
          const SizedBox(height: 14),

          // ✅ تبويبات الفئات
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: categories.map((cat) {
              bool isSelected = selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () {
                  setState(() => selectedCategory = cat['name']);
                  _performSearch();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.amber.shade400
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat['icon'],
                          size: 16,
                          color:
                              isSelected ? Colors.black : Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text(cat['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade800)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedCity,
            hint: const Text('اختر المدينة'),
            items: cities
                .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) {
              setState(() => selectedCity = value);
              _performSearch();
            },
          ),

          const SizedBox(height: 16),

          // ✅ السعر من / إلى
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'السعر الأدنى',
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'السعر الأعلى',
                    filled: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ زر البحث
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.search, color: Colors.black),
            label: const Text('ابحث الآن',
                style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ✅ النتائج
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final ad = searchResults[index];
                          return Card(
                            child: ListTile(
                              leading: ad.images.isNotEmpty
                                  ? Image.network(ad.images.first,
                                      width: 60, fit: BoxFit.cover)
                                  : const Icon(Icons.image_not_supported),
                              title: Text(ad.title),
                              subtitle:
                                  Text('${ad.price} ل.س • ${ad.city}'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AdDetailsPage(ad: ad),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ✅ واجهة عرض الخريطة التفاعلية
  Widget _buildMapView() {
    final markers = searchResults
        .where((ad) => ad.lat != null && ad.lng != null)
        .map(
          (ad) => Marker(
            width: 100,
            height: 40,
            point: LatLng(ad.lat!, ad.lng!),
            builder: (_) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  '${ad.price} ل.س',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(33.5, 36.3),
        zoom: 7.5,
        onPositionChanged: (pos, hasGesture) {
          if (hasGesture) {
            _performSearch(fromMap: true);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'delni.co',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 60,
            size: const Size(40, 40),
            fitBoundsOptions: const FitBoundsOptions(padding: EdgeInsets.all(50)),
            markers: markers,
            builder: (context, markers) => Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${markers.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
