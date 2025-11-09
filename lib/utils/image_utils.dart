import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  static Future<String> compressAndEncodeImage(String imagePath) async {
    try {
      if (kIsWeb) {
        final bytes = await File(imagePath).readAsBytes();
        return base64Encode(bytes);
      } else {
        final file = File(imagePath);
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          '${file.path}_compressed.jpg',
          quality: 70,
          minWidth: 800,
          minHeight: 800,
        );
        
        if (compressed != null) {
          return base64Encode(await compressed.readAsBytes());
        }
        
        return base64Encode(await file.readAsBytes());
      }
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }
}