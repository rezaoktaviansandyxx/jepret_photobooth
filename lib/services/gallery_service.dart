import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class GalleryService {
  /// Mendapatkan daftar semua file strip photo (PNG) yang tersimpan di storage lokal app
  static Future<List<File>> getSavedStrips() async {
    final List<File> stripFiles = [];

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final stripsDir = Directory('${appDocDir.path}/strips');
      if (await stripsDir.exists()) {
        final entities = stripsDir.listSync();
        for (final entity in entities) {
          if (entity is File && entity.path.toLowerCase().endsWith('.png')) {
            stripFiles.add(entity);
          }
        }
      }

      // Juga periksa temp dir atau appDocDir root jika ada file jepret_*.png
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final tempEntities = tempDir.listSync();
        for (final entity in tempEntities) {
          if (entity is File &&
              entity.path.toLowerCase().endsWith('.png') &&
              entity.path.contains('jepret_')) {
            // Hindari duplikasi nama file
            if (!stripFiles.any((f) => f.path == entity.path)) {
              stripFiles.add(entity);
            }
          }
        }
      }

      // Urutkan dari yang paling baru (last modified descending)
      stripFiles.sort((a, b) {
        try {
          return b.lastModifiedSync().compareTo(a.lastModifiedSync());
        } catch (_) {
          return 0;
        }
      });
    } catch (e) {
      debugPrint('Error loading saved strips: $e');
    }

    return stripFiles;
  }

  /// Menghapus file strip photo dari storage lokal
  static Future<bool> deleteStrip(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting strip: $e');
    }
    return false;
  }
}
