import 'package:flutter/material.dart';

class L10n {
  static final all = [
    const Locale('th'),
    const Locale('en'),
    const Locale('zh'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'th':
        return '🇹🇭';
      case 'zh':
        return '🇨🇳';
      default:
        return '🇹🇭';
    }
  }

  static String getCountryName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'th':
        return 'ไทย';
      case 'zh':
        return '中國';
      default:
        return 'ไทย';
    }
  }
}
