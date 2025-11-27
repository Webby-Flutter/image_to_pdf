import 'package:flutter/material.dart';
import 'package:image_pdf_convert/data/local/prefs_manager.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isFirstTime = true;
  bool _isDarkMode = false;

  bool get isFirstTime => _isFirstTime;
  bool get isDarkMode => _isDarkMode;

  AppStateProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await PrefsManager.init();
    _isFirstTime = PrefsManager.isFirstTime();
    notifyListeners();
  }

  void completeOnboarding() {
    _isFirstTime = false;
    PrefsManager.setFirstTimeDone();
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
