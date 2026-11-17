import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/booth_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _onRetakePressed(BuildContext context) {
    // Reset foto sesi sebelumnya, tapi frame tetap tersimpan di boothProvider
    final boothProvider = context.read<BoothProvider>();
    boothProvider.clearPhotos();
    // Balik ke Camera screen langsung
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/camera');
    }
  }

  @override
  Widget build(BuildContext context) {
    final booth = context.watch<BoothProvider>();
    final selectedFrame = booth.selectedFrame;
    final photos = booth.capturedPhotos;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hasil Foto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                    decoration: BoxDecoration(
                      color: selectedFrame?.backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedFrame?.borderColor ?? Colors.white30,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (selectedFrame?.borderColor ?? Colors.black).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedFrame != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedFrame.placeholderEmoji ?? '✨',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedFrame.name,
                                  style: TextStyle(
                                    color: selectedFrame.id == 'malang_edition'
                                        ? const Color(0xFF5D4037)
                                        : Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ...photos.map((photo) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 220,
                                height: 140,
                                color: Colors.black12,
                                child: kIsWeb
                                    ? Image.network(photo.path, fit: BoxFit.cover)
                                    : Image.file(File(photo.path), fit: BoxFit.cover),
                              ),
                            ),
                          );
                        }),
                        if (selectedFrame?.id == 'malang_edition')
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Malang Pride',
                              style: TextStyle(
                                color: const Color(0xFF8D6E63),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(top: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onRetakePressed(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70, width: 1.5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Ambil Lagi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
