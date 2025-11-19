import 'package:flutter/material.dart';

import 'home_page.dart';
import 'services_page.dart';
import 'add_ad_page.dart';
import 'my_ads_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final String phone;
  final String userToken;
  final int initialTabIndex;

  const MainNavigation({
    super.key,
    required this.phone,
    required this.userToken,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  List<Widget> get pages => [
        HomePage(
          phone: widget.phone,
          userToken: widget.userToken,
        ),

        const ServicesPage(),

        AddAdPage(
          userPhone: widget.phone,
          userToken: widget.userToken,
        ),

        MyAdsPage(
          userToken: widget.userToken,
        ),

        ProfilePage(
          phone: widget.phone,
          userToken: widget.userToken,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "الخدمات"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "إضافة إعلان"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "إعلاناتي"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}
