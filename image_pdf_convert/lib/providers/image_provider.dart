import 'package:flutter/material.dart';
import 'package:image_pdf_convert/models/image_item.dart';

class ImagesProvider extends ChangeNotifier {
  List<ImageItem> _images = [];

  List<ImageItem> get images => _images;

  void addImages(List<ImageItem> newImages) {
    _images.addAll(newImages);
    notifyListeners();
  }

  void removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);
    notifyListeners();
  }

  void clearAll() {
    _images.clear();
    notifyListeners();
  }
}