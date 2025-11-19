import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_model.dart';
import 'l10n/app_localizations.dart';

class EditAdPage extends StatefulWidget {
  final Ad ad;
  final String userToken;

  const EditAdPage({
    super.key,
    required this.ad,
    required this.userToken,
  });

  @override
  State<EditAdPage> createState() => _EditAdPageState();
}

class _EditAdPageState extends State<EditAdPage> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String description;
  late String price;
  late String city;
  late String category;

  File? newImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    title = widget.ad.title;
    description = widget.ad.description;
    price = widget.ad.price.toString();
    city = widget.ad.city;
    category = widget.ad.category;
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> updateAd() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? widget.userToken;

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse('https://delni.co/api/ads/${widget.ad.id}');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['_method'] = 'PUT';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['city'] = city;
    request.fields['category'] = category;

    if (newImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', newImage!.path),
      );
    }

    final response = await request.send();
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('ad_updated_success'),
          ),
        ),
      );
      Navigator.pop(context, true); // ✅ إعادة التحميل عند العودة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في تحديث الإعلان')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.translate('edit_ad'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: t.translate('title')),
                onChanged: (val) => title = val,
                validator: (val) =>
                    val!.isEmpty ? '${t.translate('title')} مطلوب' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration:
                    InputDecoration(labelText: t.translate('description')),
                onChanged: (val) => description = val,
                validator: (val) =>
                    val!.isEmpty ? '${t.translate('description')} مطلوبة' : null,
              ),
              TextFormField(
                initialValue: price,
                decoration: InputDecoration(labelText: t.translate('price')),
                keyboardType: TextInputType.number,
                onChanged: (val) => price = val,
                validator: (val) =>
                    val!.isEmpty ? '${t.translate('price')} مطلوب' : null,
              ),
              TextFormField(
                initialValue: city,
                decoration: InputDecoration(labelText: t.translate('city')),
                onChanged: (val) => city = val,
                validator: (val) =>
                    val!.isEmpty ? '${t.translate('city')} مطلوبة' : null,
              ),
              TextFormField(
                initialValue: category,
                decoration: InputDecoration(labelText: t.translate('category')),
                onChanged: (val) => category = val,
                validator: (val) =>
                    val!.isEmpty ? '${t.translate('category')} مطلوبة' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: Text(t.translate('choose_image')),
              ),
              const SizedBox(height: 10),

              // ✅ عرض الصورة الجديدة أو الحالية
              if (newImage != null)
                Image.file(newImage!, height: 180, fit: BoxFit.cover)
              else if (widget.ad.images.isNotEmpty)
                Image.network(
                  widget.ad.absoluteImages.first,
                  height: 180,
                  fit: BoxFit.cover,
                )
              else
                const SizedBox(
                  height: 180,
                  child: Center(
                      child: Icon(Icons.image_not_supported,
                          size: 60, color: Colors.grey)),
                ),

              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: updateAd,
                      icon: const Icon(Icons.save),
                      label: Text(t.translate('update')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
