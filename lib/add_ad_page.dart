import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class AddAdPage extends StatefulWidget {
  final String userEmail;
  final String userToken;

  const AddAdPage({Key? key, required this.userEmail, required this.userToken}) : super(key: key);

  @override
  State<AddAdPage> createState() => _AddAdPageState();
}

class _AddAdPageState extends State<AddAdPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages = images);
    }
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة الحقول واختيار صور')),
      );
      return;
    }

    final success = await ApiService.createAd(
      title: _titleController.text,
      description: _descriptionController.text,
      price: _priceController.text,
      city: 'دمشق',
      category: 'سيارات',
      userId: 1,
      images: _selectedImages,
      token: widget.userToken,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم نشر الإعلان بنجاح')),
      );
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ فشل في رفع الإعلان')),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة إعلان جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان الإعلان'),
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('اختيار صور'),
              ),
              const SizedBox(height: 10),
              _selectedImages.isEmpty
                  ? const Text('لم يتم اختيار صور')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedImages.map((img) {
                        if (kIsWeb) {
                          return FutureBuilder<Uint8List>(
                            future: img.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done &&
                                  snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                            },
                          );
                        } else {
                          return Image.file(
                            File(img.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        }
                      }).toList(),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAd,
                child: const Text('🟡 نشر الإعلان'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
