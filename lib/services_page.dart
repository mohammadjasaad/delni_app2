import 'package:flutter/material.dart';
import 'service_details_page.dart';
import 'service_ads_page.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  // ================
  //  بيانات الأقسام
  // ================
  static const List<Map<String, dynamic>> homeServices = [
    {'icon': Icons.cleaning_services, 'label': 'تنظيف منازل'},
    {'icon': Icons.handyman, 'label': 'صيانة منزلية'},
    {'icon': Icons.local_shipping, 'label': 'نقل أثاث'},
    {'icon': Icons.grass, 'label': 'تنسيق حدائق'},
    {'icon': Icons.pets, 'label': 'رعاية الحيوانات'},
  ];

  static const List<Map<String, dynamic>> carServices = [
    {'icon': Icons.car_repair, 'label': 'ميكانيك سيارات'},
    {'icon': Icons.local_car_wash, 'label': 'غسيل سيارات'},
    {'icon': Icons.bolt, 'label': 'فحص كهرباء'},
    {'icon': Icons.health_and_safety, 'label': 'تأمين سيارات'},
    {'icon': Icons.car_crash, 'label': 'فحص سيارات'},
  ];

  static const List<Map<String, dynamic>> educationServices = [
    {'icon': Icons.menu_book, 'label': 'تعليم لغات'},
    {'icon': Icons.computer, 'label': 'تعليم برمجة'},
    {'icon': Icons.drive_eta, 'label': 'تعليم قيادة'},
    {'icon': Icons.fitness_center, 'label': 'تدريب مهني'},
    {'icon': Icons.music_note, 'label': 'تعليم موسيقى'},
  ];

  static const List<Map<String, dynamic>> beautyServices = [
    {'icon': Icons.spa, 'label': 'مراكز تجميل'},
    {'icon': Icons.brush, 'label': 'عيادات جلدية'},
    {'icon': Icons.content_cut, 'label': 'حلاقين'},
    {'icon': Icons.local_hospital, 'label': 'دايت وتغذية'},
    {'icon': Icons.bathtub, 'label': 'مساج / سبا'},
  ];

  static const List<Map<String, dynamic>> businessServices = [
    {'icon': Icons.build, 'label': 'صيانة أجهزة'},
    {'icon': Icons.key, 'label': 'صناعة مفاتيح'},
    {'icon': Icons.engineering, 'label': 'حدادة'},
    {'icon': Icons.chair_alt, 'label': 'نجارة'},
    {'icon': Icons.business_center, 'label': 'أعمال وصيانة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('الخدمات'),
        backgroundColor: Colors.amber[800],
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ============================
            //   صورة الهيدر
            // ============================
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                'https://delni.co/images/services-header.jpg',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'الخدمات 🛠️',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة… مثل تنظيف منازل، صيانة، تعليم…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            _buildSection(context, 'خدمات منزلية 🏠', homeServices),
            _buildSection(context, 'خدمات سيارات 🚗', carServices),
            _buildSection(context, 'تعليم وتدريب 🎓', educationServices),
            _buildSection(context, 'صحة وجمال 💅', beautyServices),
            _buildSection(context, 'أعمال وصيانة 🛠️', businessServices),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================
  //   بناء القسم
  // ============================
  Widget _buildSection(
      BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: items.map((service) {
              return _serviceCard(context, service);
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================
  //   بطاقة الخدمة
  // ============================
  Widget _serviceCard(BuildContext context, Map<String, dynamic> service) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ServiceAdsPage(label: service['label']),
    ),
  );
},


        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(service['icon'], size: 36, color: Colors.amber[800]),
            const SizedBox(height: 8),
            Text(
              service['label'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
