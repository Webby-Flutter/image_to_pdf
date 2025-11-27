import 'package:flutter/material.dart';

class PdfProvider extends ChangeNotifier {
  bool _isGenerating = false;
  String? _generatedPdfPath;
  String? _error;

  bool get isGenerating => _isGenerating;
  String? get generatedPdfPath => _generatedPdfPath;
  String? get error => _error;

  void startGenerating() {
    _isGenerating = true;
    _error = null;
    notifyListeners();
  }

  void pdfGenerated(String path) {
    _isGenerating = false;
    _generatedPdfPath = path;
    notifyListeners();
  }

  void setError(String message) {
    _isGenerating = false;
    _error = message;
    notifyListeners();
  }

  void reset() {
    _generatedPdfPath = null;
    _error = null;
    _isGenerating = false;
    notifyListeners();
  }
}