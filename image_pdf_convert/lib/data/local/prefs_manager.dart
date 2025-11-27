import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefsManager {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // First time
  static bool isFirstTime() => _prefs.getBool('isFirstTime') ?? true;
  static Future setFirstTimeDone() => _prefs.setBool('isFirstTime', false);

  // Recent PDFs
  static List<String> getRecentPdfs() {
    final json = _prefs.getString('recent_pdfs');
    if (json == null) return [];
    return List<String>.from(jsonDecode(json));
  }

  static Future addRecentPdf(String path) async {
    final List<String> list = getRecentPdfs();
    list.removeWhere((e) => e == path);
    list.insert(0, path);
    if (list.length > 10) list.removeLast();
    await _prefs.setString('recent_pdfs', jsonEncode(list));
  }
}