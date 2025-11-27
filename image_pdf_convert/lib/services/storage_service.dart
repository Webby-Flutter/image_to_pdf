import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> getPdfDirectory() async {
    final directory = await getExternalStorageDirectory();
    final folder = Directory("${directory!.path}/SnapPDF");
    if (!await folder.exists()) await folder.create(recursive: true);
    return folder.path;
  }
}