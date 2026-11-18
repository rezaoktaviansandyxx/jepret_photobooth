import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import '../data/filter_model.dart';
import '../data/frame_model.dart';

class PhotoStrip extends StatelessWidget {
  final List<XFile> photos;
  final FrameModel? frame;
  final FilterModel? filter;
  final void Function(int index)? onRetake;
  final bool showRetakeButton;

  const PhotoStrip({
    super.key,
    required this.photos,
    this.frame,
    this.filter,
    this.onRetake,
    this.showRetakeButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMalang = frame?.id == 'malang_edition';
    final bgColor = isMalang ? const Color(0xFFFFF7D6) : (frame?.backgroundColor ?? Colors.white);
    final borderColor = isMalang ? const Color(0xFFD4A373) : (frame?.borderColor ?? const Color(0xFFE0E0E0));

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Frame Header / Title (if not Malang)
          if (frame != null && !isMalang)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    frame!.placeholderEmoji ?? '✨',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    frame!.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // 3 Photos Stacked Vertically
          ...List.generate(3, (index) {
            final hasPhoto = index < photos.length;
            final photo = hasPhoto ? photos[index] : null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 220,
                      height: 140,
                      color: Colors.black12,
                      child: photo != null
                          ? _buildFilteredImage(photo)
                          : const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.black26,
                                size: 36,
                              ),
                            ),
                    ),
                  ),

                  // Retake Button di Pojok Foto
                  if (showRetakeButton && onRetake != null && hasPhoto)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onRetake!(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'Retake',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          // Frame Footer
          if (isMalang)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Malang Pride',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bakso Malang • Bromo',
                    style: TextStyle(
                      color: Color(0xFF8D6E63),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else if (frame?.placeholderText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                frame!.placeholderText!,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilteredImage(XFile photo) {
    Widget imageWidget = kIsWeb
        ? Image.network(
            photo.path,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );

    if (filter?.colorFilter != null) {
      return ColorFiltered(
        colorFilter: filter!.colorFilter!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
