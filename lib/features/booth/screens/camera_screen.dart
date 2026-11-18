import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../services/camera_service.dart';
import '../provider/booth_provider.dart';
import '../widgets/countdown_overlay.dart';

class CameraScreen extends StatefulWidget {
  final int? retakeIndex;

  const CameraScreen({super.key, this.retakeIndex});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  bool _isLoading = true;
  bool _isPermissionDenied = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInitCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraService.controller;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (controller != null && controller.value.isInitialized) {
        _cameraService.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      _checkPermissionAndInitCamera();
    }
  }

  Future<void> _checkPermissionAndInitCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final status = await Permission.camera.status;

    if (status.isGranted) {
      _initCamera();
    } else {
      final requestStatus = await Permission.camera.request();
      if (requestStatus.isGranted) {
        _initCamera();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isPermissionDenied = true;
          });
        }
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initializeFrontCamera();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPermissionDenied = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onShutterPressed() {
    final boothProvider = context.read<BoothProvider>();
    if (boothProvider.isSessionRunning) return;

    final isRetake = widget.retakeIndex != null || boothProvider.isRetakeMode;
    final targetIndex = widget.retakeIndex ?? boothProvider.retakeIndex ?? 0;

    if (isRetake) {
      boothProvider.startSingleRetakeSession(
        index: targetIndex,
        onTakePicture: () async {
          return await _cameraService.takePicture();
        },
        onCompleted: () {
          if (!mounted) return;
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/preview');
              }
            }
          });
        },
      );
    } else {
      boothProvider.startPhotoSession(
        onTakePicture: () async {
          return await _cameraService.takePicture();
        },
        onSessionCompleted: () {
          if (!mounted) return;
          // Pindah ke preview screen setelah selesai sesi 3 foto
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              context.push('/preview');
            }
          });
        },
      );
    }
  }

  Widget _buildThumbnail(XFile photo) {
    return Container(
      width: 54,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? Image.network(photo.path, fit: BoxFit.cover)
          : Image.file(File(photo.path), fit: BoxFit.cover),
    );
  }

  Widget _buildEmptyThumbnailSlot(int index) {
    return Container(
      width: 54,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38, width: 1.5, style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorDots(int currentIndex, int capturedCount) {
    final displayIndex = currentIndex > 0 ? currentIndex : (capturedCount > 0 ? capturedCount : 0);
    final textLabel = displayIndex > 0 ? 'Foto $displayIndex/3' : 'Foto 0/3';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          textLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final isTaken = i < capturedCount;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isTaken ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isTaken ? Colors.white : Colors.white70,
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_isPermissionDenied) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_photography_outlined,
                  size: 80,
                  color: Colors.white70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kamera belum diizinkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Untuk menggunakan Jepret Photobooth, silakan berikan izin akses kamera.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null || !_cameraService.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Gagal memuat kamera',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkPermissionAndInitCamera,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controller = _cameraService.controller!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full Screen Camera Preview
          Center(child: CameraPreview(controller)),

          // Frame Overlay (transparan + border warna frame yang dipilih)
          Consumer<BoothProvider>(
            builder: (context, booth, child) {
              final frame = booth.selectedFrame;
              final isMalang = frame?.id == 'malang_edition';
              // Warna krem khas Malang Edition (#FFF7D6) atau border default frame
              final borderColor = isMalang
                  ? const Color(0xFFFFF7D6)
                  : (frame?.borderColor ?? Colors.white.withValues(alpha: 0.4));
              final frameName = frame?.name ?? 'Frame Preview';

              return IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: borderColor,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Badge nama frame di atas tengah preview
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: borderColor.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            frameName,
                            style: TextStyle(
                              color: borderColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Tulisan kecil "Malang Pride" di pinggir preview untuk Malang Edition
                      if (isMalang)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7D6).withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Malang Pride',
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Tombol Back di pojok kiri atas kamera
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Consumer<BoothProvider>(
              builder: (context, booth, child) {
                // Sembunyikan tombol back jika sesi foto sedang berjalan
                if (booth.isSessionRunning) return const SizedBox.shrink();
                return SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/frame-picker');
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Countdown Number Overlay (3 -> 2 -> 1)
          Consumer<BoothProvider>(
            builder: (context, booth, child) {
              if (!booth.isCountingDown || booth.countdownNumber <= 0) {
                return const SizedBox.shrink();
              }
              return CountdownOverlay(count: booth.countdownNumber);
            },
          ),

          // Message Banner ("Siap, pose 2!", dll)
          Consumer<BoothProvider>(
            builder: (context, booth, child) {
              if (booth.sessionMessage.isEmpty) {
                return const SizedBox.shrink();
              }
              return Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white70, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    booth.sessionMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              );
            },
          ),

          // Flash Putih Cepat
          Consumer<BoothProvider>(
            builder: (context, booth, child) {
              return AnimatedOpacity(
                opacity: booth.isFlashing ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 80),
                child: IgnorePointer(
                  ignoring: !booth.isFlashing,
                  child: Container(color: Colors.white),
                ),
              );
            },
          ),

          // Bottom Bar Area (Indikator, Shutter, 3 Thumbnail)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Shutter Gede di Tengah
                Consumer<BoothProvider>(
                  builder: (context, booth, child) {
                    final isBusy = booth.isSessionRunning;
                    return GestureDetector(
                      onTap: isBusy ? null : _onShutterPressed,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isBusy ? 0.35 : 1.0,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isBusy ? Colors.white38 : Colors.white,
                              width: 4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: isBusy ? Colors.white38 : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Indikator Foto (Foto 1/3, 2/3, 3/3 & Dots atau Retake)
                Consumer<BoothProvider>(
                  builder: (context, booth, child) {
                    final isRetake = widget.retakeIndex != null || booth.isRetakeMode;
                    final target = (widget.retakeIndex ?? booth.retakeIndex ?? 0) + 1;
                    if (isRetake) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Retake Foto $target dari 3',
                          style: const TextStyle(
                            color: Color(0xFFFF4081),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return _buildIndicatorDots(
                      booth.currentPhotoIndex,
                      booth.capturedPhotos.length,
                    );
                  },
                ),

                const SizedBox(height: 14),

                // 3 Thumbnail Foto di Bawah Kamera
                Consumer<BoothProvider>(
                  builder: (context, booth, child) {
                    final photos = booth.capturedPhotos;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: index < photos.length
                              ? _buildThumbnail(photos[index])
                              : _buildEmptyThumbnailSlot(index + 1),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
