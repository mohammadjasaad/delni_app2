import 'dart:convert';
import 'package:flutter/material.dart';
import 'ad_model.dart';
import 'api_service.dart';
import 'ad_details_page.dart';
import 'edit_ad_page.dart';

class MyAdsPage extends StatefulWidget {
  final String userToken;

  const MyAdsPage({Key? key, required this.userToken}) : super(key: key);

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  late Future<List<Ad>> _myAdsFuture;
  List<Ad> myAds = [];

  @override
  void initState() {
    super.initState();
    _myAdsFuture = fetchMyAds();
  }

  Future<List<Ad>> fetchMyAds() async {
    final url = "https://delni.co/api/my-ads";

    final response = await ApiService.authenticatedGet(url, widget.userToken);

    if (response != null && response["ads"] is List) {
      myAds = (response["ads"] as List)
          .map((json) => Ad.fromJson(json))
          .toList();
      return myAds;
    }

    throw Exception('فشل تحميل إعلاناتي');
  }

  Future<void> deleteAd(int adId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteAd(adId, widget.userToken);
      if (success) {
        setState(() => myAds.removeWhere((ad) => ad.id == adId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم الحذف بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في الحذف')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعلاناتي')),
      body: FutureBuilder<List<Ad>>(
        future: _myAdsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('❌ خطأ تحميل إعلاناتي: ${snapshot.error}');
            return const Center(child: Text('فشل تحميل الإعلانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد إعلانات بعد.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myAds.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final ad = myAds[index];

              final imageUrl = ad.images.isNotEmpty
                  ? (ad.images.first.startsWith('http')
                      ? ad.images.first
                      : 'https://delni.co${ad.images.first}')
                  : null;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdDetailsPage(ad: ad)),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: Icon(Icons.image,
                                      size: 50, color: Colors.grey),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          ad.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          '${ad.price} ل.س - ${ad.city}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditAdPage(
                                    ad: ad,
                                    userToken: widget.userToken,
                                  ),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  setState(() => _myAdsFuture = fetchMyAds());
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteAd(ad.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
