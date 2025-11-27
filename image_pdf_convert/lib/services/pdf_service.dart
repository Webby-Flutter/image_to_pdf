import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_pdf_convert/models/image_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String> createPdf({
    required List<ImageItem> images,
    required String fileName,
    required String pageSize,
    String? password,
  }) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.size = _getPageSize(pageSize);
    document.pageSettings.margins.all = 0;

    if (password != null && password.isNotEmpty) {
      document.security.userPassword = password;
      document.security.ownerPassword = password;
    }

    for (var img in images) {
      final bytes = await File(img.path).readAsBytes();
      final pdfImage = PdfBitmap(bytes);

      final page = document.pages.add();
      final size = page.getClientSize();

      final double scale = size.width / pdfImage.width;
      final double height = pdfImage.height * scale;

      page.graphics.drawImage(pdfImage, Rect.fromLTWH(0, 0, size.width, height > size.height ? size.height : height));
    }

    final directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/SnapPDF/$fileName.pdf";
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(await document.save());
    document.dispose();

    return path;
  }

  static Size _getPageSize(String size) {
    switch (size) {
      case 'A4':
        return const Size(595, 842);
      case 'Letter':
        return const Size(612, 792);
      default:
        return const Size(595, 842);
    }
  }
}
