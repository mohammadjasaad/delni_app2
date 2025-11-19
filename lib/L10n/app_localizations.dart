import 'package:flutter/material.dart';
import 'dart:async';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // 🟡 جميع النصوص
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'home': 'الرئيسية',
      'services': 'الخدمات',
      'add_ad': 'إضافة إعلان',
      'my_ads': 'إعلاناتي',
      'profile': 'حسابي',
      'ad_details': 'تفاصيل الإعلان',
      'description': 'الوصف',
      'edit_ad': 'تعديل الإعلان',
      'choose_image': 'اختيار صورة',
      'update': 'تحديث',
      'ad_updated_success': '✅ تم تحديث الإعلان بنجاح',
    },
    'en': {
      'home': 'Home',
      'services': 'Services',
      'add_ad': 'Add Ad',
      'my_ads': 'My Ads',
      'profile': 'Profile',
      'ad_details': 'Ad Details',
      'description': 'Description',
      'edit_ad': 'Edit Ad',
      'choose_image': 'Choose Image',
      'update': 'Update',
      'ad_updated_success': '✅ Ad updated successfully',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
