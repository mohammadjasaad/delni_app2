import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:shimmer/shimmer.dart';

import 'ad_model.dart';
import 'ad_details_page.dart';
import 'api_service.dart';
import 'mall_page.dart';
import 'taxi_map_page.dart';
import 'emergency_page.dart';
import 'services_page.dart';

class HomePage extends StatefulWidget {
  final String phone;
  final String userToken;

  const HomePage({
    super.key,
    required this.phone,
    required this.userToken,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Ad>> _adsFuture;
  late Future<List<Ad>> _featuredAdsFuture;
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _isDarkMode = false;

  final CarouselSliderController _featuredCarouselController =
      CarouselSliderController();

  String? _city;
  String? _category;

  final List<String> _uiCategories = [
    "عقارات",
    "سيارات",
    "خدمات",
    "دلني مول",
    "دلني تاكسي",
    "دلني عاجل",
  ];

  List<dynamic> _mainBanners = [];
  bool _loadingBanners = true;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _adsFuture = ApiService.fetchAds();
    _featuredAdsFuture = ApiService.fetchAds(isFeatured: true);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? Colors.black : const Color(0xFFFDFCF8);
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
        title: Text(
          'Delni',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              _buildBannerSlider(),
              _buildFeaturedSection(textColor),
              _buildSearchBar(textColor),
              _buildCategoryIcons(),
              _buildAdsSection(textColor),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // 🔥 الأقسام — A: فلترة — B: انتقال لصفحات خاصة
  // -----------------------------------------------------------------------------
  Widget _buildCategoryIcons() {
    final icons = {
      'عقارات': Icons.home_work,
      'سيارات': Icons.directions_car,
      'خدمات': Icons.handyman,
      'دلني مول': Icons.store_mall_directory,
      'دلني تاكسي': Icons.local_taxi,
      'دلني عاجل': Icons.medical_services,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 10,
        children: _uiCategories.map((cat) {
          final icon = icons[cat];
          final isSelected = _category == cat;

          return GestureDetector(
            onTap: () {
              if (cat == 'عقارات') {
                _category = 'realestate';
                _adsFuture = ApiService.fetchAds(category: "realestate");
                setState(() {});
                return;
              }

              if (cat == 'سيارات') {
                _category = 'cars';
                _adsFuture = ApiService.fetchAds(category: "cars");
                setState(() {});
                return;
              }

              if (cat == 'خدمات') return _navigateWithAnimation(const ServicesPage());
              if (cat == 'دلني مول') return _navigateWithAnimation(const MallPage());
              if (cat == 'دلني تاكسي') return _navigateWithAnimation(const TaxiMapPage());
              if (cat == 'دلني عاجل') return _navigateWithAnimation(const EmergencyPage());
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.amber.shade400 : Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [BoxShadow(color: Colors.amber.shade200, blurRadius: 8)]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.black : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.amber.shade700 : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // 🔥 Auto Featured Scroll
  // -----------------------------------------------------------------------------
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _featuredCarouselController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  // -----------------------------------------------------------------------------
  // 🔥 Banner Slider
  // -----------------------------------------------------------------------------
  Future<void> _loadBanners() async {
    try {
      final banners = await ApiService.fetchBanners();
      setState(() {
        _mainBanners = banners;
        _loadingBanners = false;
      });
    } catch (e) {
      setState(() => _loadingBanners = false);
    }
  }

  Widget _buildBannerSlider() {
    if (_loadingBanners) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }

    if (_mainBanners.isEmpty) return const SizedBox.shrink();

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: _mainBanners.map((img) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: img.toString(),
            fit: BoxFit.cover,
            width: double.infinity,
            errorWidget: (_, __, ___) =>
                Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------------------------
  // 🔥 Featured Section
  // -----------------------------------------------------------------------------
  Widget _buildFeaturedSection(Color textColor) {
    return FutureBuilder<List<Ad>>(
      future: _featuredAdsFuture,
      builder: (context, snapshot) {
        final ads = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (ads.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text('🔥 العروض الخاصة',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            CarouselSlider.builder(
              carouselController: _featuredCarouselController,
              itemCount: ads.length,
              options: CarouselOptions(
                height: 250,
                enlargeCenterPage: true,
                viewportFraction: 0.75,
              ),
              itemBuilder: (_, index, __) {
                final ad = ads[index];
                final img = ad.mainImage; // ← هنا

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(1, 3)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ad.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 4),
                              Text('${ad.price} ل.س',
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(ad.city,
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.7), fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------------------------------------------
  // 🔥 Ads Grid Section
  // -----------------------------------------------------------------------------
  Widget _buildAdsSection(Color textColor) {
    return FutureBuilder<List<Ad>>(
      future: _adsFuture,
      builder: (context, snapshot) {
        final ads = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator()));
        }

        if (ads.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد إعلانات حالياً'),
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
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, index) {
            final ad = ads[index];
            final img = ad.mainImage; // ← هنا

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 4),
                          Text('${ad.price} ل.س',
                              style: const TextStyle(
                                  color: Colors.amber, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(ad.city,
                              style: TextStyle(
                                  color: textColor.withOpacity(0.7), fontSize: 12)),
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

  // -----------------------------------------------------------------------------
  // 🔥 Search Bar
  // -----------------------------------------------------------------------------
  Widget _buildSearchBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'ابحث عن إعلان...',
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // 🔥 Helper Functions
  // -----------------------------------------------------------------------------
  Future<void> _refresh() async {
    await _loadBanners();
    setState(() {
      _adsFuture = ApiService.fetchAds();
      _featuredAdsFuture = ApiService.fetchAds(isFeatured: true);
    });
  }

  void _toggleDarkMode() =>
      setState(() => _isDarkMode = !_isDarkMode);

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _adsFuture = ApiService.fetchAds(query: q, city: _city, category: _category);
      });
    });
  }

  void _navigateWithAnimation(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));

          final fade = Tween<double>(begin: 0, end: 1).animate(anim);

          return SlideTransition(position: slide, child: FadeTransition(opacity: fade, child: child));
        },
      ),
    );
  }
}
