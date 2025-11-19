import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class AddAdPage extends StatefulWidget {
  final String userPhone;
  final String userToken;

  const AddAdPage({
    super.key,
    required this.userPhone,
    required this.userToken,
  });

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}


class _AddAdPageState extends State<AddAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 🔹 قوائم المدن والتصنيفات (ممكن لاحقاً تربطها من API)
  final List<String> _cities = const [
    'دمشق', 'حلب', 'اللاذقية', 'حماة', 'حمص', 'طرطوس', 'إدلب'
  ];
  final List<String> _categories = const [
    'سيارات', 'عقار', 'إلكترونيات', 'أثاث', 'وظائف'
  ];

  String _city = 'دمشق';
  String _category = 'سيارات';

  final _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _loading = false;

  Future<void> _pickImages() async {
    final imgs = await _picker.pickMultiImage(imageQuality: 85);
    if (imgs.isNotEmpty) {
      setState(() => _selectedImages = imgs);
    }
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ يرجى تعبئة الحقول واختيار صور')),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      final ok = await ApiService.createAd(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        city: _city,
        category: _category,
        images: _selectedImages,
        token: widget.userToken,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم نشر الإعلان بنجاح')),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في رفع الإعلان')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء رفع الإعلان: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedImages.clear();
      _city = _cities.first;
      _category = _categories.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('➕ إضافة إعلان جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان الإعلان'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),

              // 🔹 اختيار المدينة والتصنيف
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _city,
                      decoration: const InputDecoration(labelText: 'المدينة'),
                      items: _cities
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _city = v ?? _city),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('📷 اختيار صور'),
              ),
              const SizedBox(height: 10),

              _selectedImages.isEmpty
                  ? const Text('لم يتم اختيار صور',
                      style: TextStyle(color: Colors.grey))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedImages.map((img) {
                        if (kIsWeb) {
                          return FutureBuilder<Uint8List>(
                            future: img.readAsBytes(),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                      ConnectionState.done &&
                                  snap.hasData) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(snap.data!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover),
                                );
                              }
                              return const SizedBox(
                                width: 100,
                                height: 100,
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            },
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }).toList(),
                    ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitAd,
                  icon: const Icon(Icons.send),
                  label: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('🚀 نشر الإعلان'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
