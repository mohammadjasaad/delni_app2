import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'api_service.dart';
import 'ad_details_page.dart';
import 'ad_model.dart';

class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  bool _isDarkMode = false;
  bool _loadingBanners = true;
  List<dynamic> _mallBanners = [];
  late Future<List<Ad>> _adsFuture;
  late Future<List<Ad>> _featuredAdsFuture;

  String? _city;
  double? _minPrice;
  double? _maxPrice;
  String _sortOrder = 'الأحدث أولًا';
  String? _selectedCategory;

  final List<String> _cities = ['دمشق', 'حلب', 'حمص', 'اللاذقية', 'طرطوس', 'حماة', 'إدلب'];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'إلكترونيات', 'icon': Icons.devices},
    {'name': 'أزياء', 'icon': Icons.checkroom},
    {'name': 'عطور', 'icon': Icons.spa},
    {'name': 'أثاث', 'icon': Icons.chair},
    {'name': 'منزلية', 'icon': Icons.kitchen},
    {'name': 'ألعاب', 'icon': Icons.child_friendly},
    {'name': 'سوبرماركت', 'icon': Icons.shopping_bag},
    {'name': 'ساعات', 'icon': Icons.watch},
    {'name': 'أحذية', 'icon': Icons.shopping_basket},
    {'name': 'كتب', 'icon': Icons.menu_book},
    {'name': 'أجهزة', 'icon': Icons.tv},
    {'name': 'سيارات', 'icon': Icons.directions_car},
    {'name': 'رياضة', 'icon': Icons.fitness_center},
    {'name': 'زهور', 'icon': Icons.local_florist},
    {'name': 'مطاعم', 'icon': Icons.fastfood},
    {'name': 'عروض', 'icon': Icons.local_offer},
  ];

  @override
  void initState() {
    super.initState();
    _loadMallBanners();
    _adsFuture = ApiService.fetchAds(category: 'دلني مول');
    _featuredAdsFuture = ApiService.fetchAds(category: 'دلني مول', isFeatured: true);
  }

  Future<void> _loadMallBanners() async {
    try {
      final mall = await ApiService.fetchMallBanners();
      setState(() {
        _mallBanners = mall;
        _loadingBanners = false;
      });
    } catch (_) {
      setState(() => _loadingBanners = false);
    }
  }

  void _toggleDarkMode() => setState(() => _isDarkMode = !_isDarkMode);

  void _applyFilters() {
    setState(() {
      _adsFuture = ApiService.fetchAds(
        category: 'دلني مول',
        city: _city,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sortOrder == 'الأغلى أولًا'
            ? 'desc'
            : _sortOrder == 'الأرخص أولًا'
                ? 'asc'
                : 'latest',
      );
    });
  }

  // 🟡 بانر احترافي
  Widget _buildMallBanner() {
    if (_loadingBanners) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      );
    }

    if (_mallBanners.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      itemCount: _mallBanners.length,
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      itemBuilder: (context, i, _) {
        final imageUrl = (_mallBanners[i] is String)
            ? _mallBanners[i]
            : (_mallBanners[i]['image_desktop'] ?? _mallBanners[i]['image']);
        final fullUrl = imageUrl.startsWith('http')
            ? imageUrl
            : 'https://delni.co/storage/$imageUrl';

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: fullUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, _) => Container(color: Colors.grey[300]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '💥 خصومات حتى 70% - تسوق الآن!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 🟢 شبكة التصنيفات
  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final selected = cat['name'] == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = selected ? null : cat['name'];
              });
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected ? Colors.amber : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 5, offset: const Offset(1, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'],
                      color: selected ? Colors.black : Colors.grey[800], size: 30),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.black : Colors.grey[800],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🟣 العروض الخاصة (عصري أفقي)
  Widget _buildFeaturedSection(Color textColor) {
    return FutureBuilder<List<Ad>>(
      future: _featuredAdsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final ads = snapshot.data ?? [];
        if (ads.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                '🔥 العروض الخاصة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 230,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ads.length,
                itemBuilder: (context, i) {
                  final ad = ads[i];
                  final img = ad.images.isNotEmpty
                      ? (ad.images.first.startsWith('http')
                          ? ad.images.first
                          : 'https://delni.co${ad.images.first}')
                      : null;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
                    ),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12, blurRadius: 5, offset: const Offset(1, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(15)),
                            child: img == null
                                ? Container(
                                    height: 110,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: img,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ad.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('${ad.price} ل.س',
                                    style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔵 شبكة المنتجات (Airbnb Style)
  Widget _buildAdsSection(Color textColor) {
    return FutureBuilder<List<Ad>>(
      future: _adsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final ads = snapshot.data ?? [];
        if (ads.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد منتجات في المول حاليًا'),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ads.length,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, i) {
            final ad = ads[i];
            final img = ad.images.isNotEmpty
                ? (ad.images.first.startsWith('http')
                    ? ad.images.first
                    : 'https://delni.co${ad.images.first}')
                : null;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(1, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(18)),
                      child: img == null
                          ? Container(
                              height: 140,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image),
                            )
                          : CachedNetworkImage(
                              imageUrl: img,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ad.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text('${ad.price} ل.س',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.grey, size: 14),
                              const SizedBox(width: 3),
                              Text(ad.city,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? Colors.black : const Color(0xFFFDFCF8);
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text('Delni Mall 🏬',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: textColor),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadMallBanners();
          _applyFilters();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildMallBanner(),
              _buildCategoryGrid(),
              _buildFeaturedSection(textColor),
              _buildAdsSection(textColor),
            ],
          ),
        ),
      ),
    );
  }
}
