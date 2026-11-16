import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../services/camera_service.dart';
import '../provider/booth_provider.dart';
import '../widgets/countdown_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

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

  Future<void> _onShutterPressed() async {
    final boothProvider = context.read<BoothProvider>();
    if (boothProvider.isCountingDown) return;

    boothProvider.setCountingDown(true);

    // Hitung mundur: 3 -> 2 -> 1 (masing-masing 700ms dengan getaran)
    for (int i = 3; i >= 1; i--) {
      boothProvider.setCountdownNumber(i);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }

    // Reset countdown overlay sebelum jepret
    boothProvider.setCountdownNumber(0);

    // Ambil foto
    final photo = await _cameraService.takePicture();

    if (!mounted) return;

    // Trigger flash putih cepat
    boothProvider.setFlashing(true);
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      boothProvider.setFlashing(false);
    }

    if (photo != null) {
      boothProvider.addPhoto(photo);
    }

    boothProvider.setCountingDown(false);
  }

  Widget _buildThumbnail(XFile photo) {
    return Container(
      width: 56,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
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

          // Countdown Number Overlay (3 -> 2 -> 1)
          Consumer<BoothProvider>(
            builder: (context, booth, child) {
              if (!booth.isCountingDown || booth.countdownNumber <= 0) {
                return const SizedBox.shrink();
              }
              return CountdownOverlay(count: booth.countdownNumber);
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

          // Thumbnail Foto di Kiri Bawah & Shutter Button di Tengah Bawah
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Thumbnail foto di kiri bawah
                Align(
                  alignment: Alignment.centerLeft,
                  child: Consumer<BoothProvider>(
                    builder: (context, booth, child) {
                      final latestPhoto = booth.lastCapturedPhoto;
                      if (latestPhoto == null) {
                        return const SizedBox(width: 56, height: 76);
                      }
                      return _buildThumbnail(latestPhoto);
                    },
                  ),
                ),

                // Tombol Shutter Gede di Tengah
                Consumer<BoothProvider>(
                  builder: (context, booth, child) {
                    final isDisabled = booth.isCountingDown;
                    return GestureDetector(
                      onTap: isDisabled ? null : _onShutterPressed,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isDisabled ? 0.5 : 1.0,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 66,
                              height: 66,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
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
