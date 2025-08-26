// lib/core/constants.dart
import 'dart:io';

class Constants {
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/';
    return 'http://localhost:3000/api';
  }
}
