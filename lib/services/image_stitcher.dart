import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../features/booth/data/filter_model.dart';
import '../features/booth/data/frame_model.dart';

class ImageStitcher {
  /// Ukuran standar strip photo booth (lebar 1080px untuk resolusi Instagram Story/HD)
  static const int canvasWidth = 1080;
  static const int canvasHeight = 1920;

  /// Stitch 3 foto XFile menjadi 1 gambar PNG (Uint8List)
  static Future<Uint8List> stitchStrip({
    required List<XFile> photos,
    FrameModel? frame,
    FilterModel? filter,
  }) async {
    final frameColor = frame?.backgroundColor;
    final int argb32 = frameColor != null
        ? frameColor.toARGB32()
        : 0xFFFFFFFF;

    // Jalankan image processing berat di compute isolate agar UI tidak lag/freeze
    final input = _StitchPayload(
      photoBytesList: await Future.wait(photos.map((p) => p.readAsBytes())),
      frameId: frame?.id ?? 'classic',
      frameName: frame?.name ?? 'Classic',
      frameTag: frame?.tag ?? 'Malang Pride',
      frameBgValue: argb32,
      filterType: filter?.type ?? FilterType.original,
      placeholderText: frame?.placeholderText,
    );

    return await compute(_processStitching, input);
  }

  /// Fungsi worker yang dijalankan di background isolate
  static Uint8List _processStitching(_StitchPayload payload) {
    // 1. Siapkan background canvas 1080 x 1920
    final canvas = img.Image(
      width: canvasWidth,
      height: canvasHeight,
      numChannels: 4,
    );

    // Ambil warna background dari frame
    final bgColor = _argbToColor(payload.frameBgValue);
    img.fill(canvas, color: bgColor);

    // Ukuran dan posisi layout vertikal
    // Margin horizontal 70px di kiri dan kanan -> lebar foto 1080 - 140 = 940px
    const int photoMarginX = 70;
    const int photoWidth = canvasWidth - (photoMarginX * 2); // 940px
    const int photoHeight = 510; // 3 x 510 = 1530px
    const int gapY = 24; // Jarak antar foto
    const int topMargin = 70; // Margin atas

    // 2. Decode dan tempel tiap foto (maksimal 3 foto)
    for (int i = 0; i < 3; i++) {
      if (i < payload.photoBytesList.length) {
        final rawBytes = payload.photoBytesList[i];
        img.Image? decoded = img.decodeImage(rawBytes);

        if (decoded != null) {
          // Normalisasi orientasi EXIF jika ada
          decoded = img.bakeOrientation(decoded);

          // Terapkan filter yang dipilih ke foto sebelum digabung
          decoded = _applyFilter(decoded, payload.filterType);

          // Resize / Crop agar pas dengan photoWidth x photoHeight (cover/center crop)
          final processedPhoto = _resizeAndCrop(decoded, photoWidth, photoHeight);

          // Posisi Y
          final int posY = topMargin + i * (photoHeight + gapY);

          // Tempel foto ke kanvas
          img.compositeImage(
            canvas,
            processedPhoto,
            dstX: photoMarginX,
            dstY: posY,
          );
        }
      }
    }

    // 3. Tulis teks branding/frame di bagian bawah strip
    _drawFooterText(canvas, payload);

    // 4. Encode hasil stitching ke format PNG
    return Uint8List.fromList(img.encodePng(canvas));
  }

  /// Terapkan filter ke decoded image
  static img.Image _applyFilter(img.Image src, FilterType filterType) {
    switch (filterType) {
      case FilterType.bw:
        // Grayscale / Black & White
        return img.grayscale(src);

      case FilterType.vintage:
        // Vintage: hangat kekuningan/sepia dengan kontras lembut
        var processed = img.sepia(src, amount: 0.55);
        processed = img.adjustColor(
          processed,
          contrast: 1.05,
          saturation: 0.9,
          gamma: 0.95,
        );
        return processed;

      case FilterType.pinky:
        // Pinky: soft magenta/pink warmth
        return img.colorOffset(
          src,
          red: 25,
          green: 0,
          blue: 20,
        );

      case FilterType.original:
        return src;
    }
  }

  /// Resize dengan center crop agar foto tidak gepeng / terdistorsi
  static img.Image _resizeAndCrop(img.Image src, int targetW, int targetH) {
    // Hitung perbandingan aspek rasio
    final double srcAspect = src.width / src.height;
    final double targetAspect = targetW / targetH;

    int cropX = 0;
    int cropY = 0;
    int cropW = src.width;
    int cropH = src.height;

    if (srcAspect > targetAspect) {
      // Gambar sumber lebih lebar: potong kiri dan kanan
      cropW = (src.height * targetAspect).round();
      cropX = ((src.width - cropW) / 2).round();
    } else {
      // Gambar sumber lebih tinggi: potong atas dan bawah
      cropH = (src.width / targetAspect).round();
      cropY = ((src.height - cropH) / 2).round();
    }

    final cropped = img.copyCrop(src, x: cropX, y: cropY, width: cropW, height: cropH);
    return img.copyResize(cropped, width: targetW, height: targetH, interpolation: img.Interpolation.linear);
  }

  /// Render teks footer di bagian bawah strip (misal "Malang Pride" atau nama frame)
  static void _drawFooterText(img.Image canvas, _StitchPayload payload) {
    final isMalang = payload.frameId == 'malang_edition';

    if (isMalang) {
      // Malang Pride branding
      const title = 'MALANG PRIDE';
      const subtitle = 'Bakso Malang * Bromo * Jepret';

      // Posisi di footer
      const textCenterY = 1690;
      _drawCenteredString(
        canvas,
        img.arial48,
        title,
        textCenterY,
        img.ColorRgb8(93, 64, 55), // Cokelat tua (#5D4037)
      );

      _drawCenteredString(
        canvas,
        img.arial24,
        subtitle,
        textCenterY + 70,
        img.ColorRgb8(141, 110, 99), // Cokelat muda (#8D6E63)
      );
    } else {
      // General Frame footer
      final title = payload.frameName.toUpperCase();
      final subtitle = payload.placeholderText ?? 'Jepret Solo Photobooth';

      const textCenterY = 1700;
      _drawCenteredString(
        canvas,
        img.arial48,
        title,
        textCenterY,
        img.ColorRgb8(60, 60, 60),
      );

      _drawCenteredString(
        canvas,
        img.arial24,
        subtitle,
        textCenterY + 65,
        img.ColorRgb8(120, 120, 120),
      );
    }
  }

  /// Utility untuk render teks rata tengah (horizontal center)
  static void _drawCenteredString(
    img.Image canvas,
    img.BitmapFont font,
    String text,
    int y,
    img.Color color,
  ) {
    // Estimasi lebar teks berdasarkan karakter & font
    final charWidth = font.characters['A'.codeUnitAt(0)]?.width ?? 24;
    final textWidth = text.length * charWidth;
    final int x = ((canvasWidth - textWidth) / 2).round().clamp(20, canvasWidth - 20);

    img.drawString(
      canvas,
      text,
      font: font,
      x: x,
      y: y,
      color: color,
    );
  }

  /// Konversi warna ARGB int (Flutter Color.toARGB32) ke img.Color
  static img.Color _argbToColor(int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return img.ColorRgba8(r, g, b, a);
  }
}

/// DTO untuk mengirim data ke Isolate tanpa membawa referensi Flutter widget/context
class _StitchPayload {
  final List<Uint8List> photoBytesList;
  final String frameId;
  final String frameName;
  final String frameTag;
  final int frameBgValue;
  final FilterType filterType;
  final String? placeholderText;

  _StitchPayload({
    required this.photoBytesList,
    required this.frameId,
    required this.frameName,
    required this.frameTag,
    required this.frameBgValue,
    required this.filterType,
    this.placeholderText,
  });
}
