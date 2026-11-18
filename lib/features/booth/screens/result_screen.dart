import 'dart:io';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../provider/booth_provider.dart';
import '../widgets/photo_strip.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isSharing = false;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    // Inisialisasi stitching strip gambar saat layar dibuka jika belum digenerate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final booth = context.read<BoothProvider>();
      if (booth.stitchedImageBytes == null && booth.capturedPhotos.isNotEmpty) {
        booth.generateStitchedStrip();
      }
    });
  }

  /// Memastikan file PNG lokal tersedia dari memory bytes untuk disimpan ke galeri atau dishare
  Future<String?> _prepareLocalFile(BoothProvider booth) async {
    if (_savedFilePath != null && File(_savedFilePath!).existsSync()) {
      return _savedFilePath;
    }

    var bytes = booth.stitchedImageBytes;
    bytes ??= await booth.generateStitchedStrip();

    if (bytes == null) return null;

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/jepret_$timestamp.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    _savedFilePath = filePath;
    return filePath;
  }

  /// Simpan PNG ke galeri HP menggunakan path_provider + gal
  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final booth = context.read<BoothProvider>();
      final filePath = await _prepareLocalFile(booth);

      if (!mounted) return;

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memproses gambar strip.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Simpan ke galeri menggunakan gal
      await Gal.putImage(filePath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Tersimpan di galeri!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Bagikan hasil photo strip menggunakan share_plus
  Future<void> _sharePhoto() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final booth = context.read<BoothProvider>();
      final filePath = await _prepareLocalFile(booth);

      if (!mounted) return;

      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyiapkan foto untuk dibagikan.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Share file PNG via share sheet bawaan HP
      final box = context.findRenderObject() as RenderBox?;
      final sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Hasil foto Jepret Photobooth! 📸✨',
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka share sheet: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  /// Balik ke kamera, frame yang sama masih kepilih, mulai sesi baru
  void _onRetakeNewSession() {
    final booth = context.read<BoothProvider>();
    // Reset foto sesi sebelumnya, tapi frame tetap dipertahankan
    booth.clearPhotos();

    // Navigasi langsung ke kamera
    context.go('/camera');
  }

  @override
  Widget build(BuildContext context) {
    final booth = context.watch<BoothProvider>();
    final selectedFrame = booth.selectedFrame;
    final selectedFilter = booth.selectedFilter;
    final photos = booth.capturedPhotos;
    final stitchedBytes = booth.stitchedImageBytes;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Tap back -> balik ke Preview bukan ke Home
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/preview');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Kembali ke Preview',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/preview');
              }
            },
          ),
          title: const Text(
            'Hasil Foto',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Strip final yang sudah digabung tampil gede di tengah
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tampilan strip besar (dari stitched byte atau preview widget)
                        if (stitchedBytes != null)
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 320,
                              maxHeight: 520,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                stitchedBytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        else
                          // Fallback jika belum selesai di-stitch
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.05,
                                child: PhotoStrip(
                                  photos: photos,
                                  frame: selectedFrame,
                                  filter: selectedFilter,
                                  showRetakeButton: false,
                                ),
                              ),
                              if (booth.isStitching)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFF4081),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Menyiapkan strip HD...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                        const SizedBox(height: 12),

                        // Teks kecil: "Disimpan ke galeri • Hari ini"
                        const Text(
                          'Disimpan ke galeri • Hari ini',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons Bottom Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border(
                    top: BorderSide(color: Colors.white10, width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Baris tombol Download & Ambil Lagi
                    Row(
                      children: [
                        // Tombol [Download] warna pink, paling gede (flex 3)
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveToGallery,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded, size: 22),
                              label: Text(
                                _isSaving ? 'Menyimpan...' : 'Download',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4081),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Tombol [Ambil Lagi] warna putih di sebelahnya (flex 2)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _onRetakeNewSession,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 20,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                'Ambil Lagi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tombol [Share] di bawahnya
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isSharing ? null : _sharePhoto,
                        icon: _isSharing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 20),
                        label: Text(
                          _isSharing ? 'Membuka...' : 'Share',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
      ),
    );
  }
}
