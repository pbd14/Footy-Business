import 'package:flutter/material.dart';
import 'package:footy_business/Services/languages/languages.dart';
import 'package:footy_business/Services/languages/ru.dart';

import 'en.dart';
import 'uz.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'ru':
        return LanguageRu();
      case 'uz':
        return LanguageUz();
      default:
        return LanguageEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}
