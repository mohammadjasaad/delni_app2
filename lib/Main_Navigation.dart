import 'package:flutter/material.dart';

import 'home_page.dart';
import 'services_page.dart';
import 'add_ad_page.dart';
import 'my_ads_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final String email;
  final String userToken;

  const MainNavigation({
    super.key,
    required this.email,
    required this.userToken,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(loggedInEmail: widget.email),
      const ServicesPage(),
      AddAdPage(userEmail: widget.email, userToken: widget.userToken),
      MyAdsPage(userToken: widget.userToken), // ✅ صفحة إعلاناتي
      ProfilePage(email: widget.email),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // ✅ للسماح بأكثر من 3 أيقونات
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.miscellaneous_services), label: 'الخدمات'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'إضافة إعلان'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'إعلاناتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
