import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;
  bool get isInitialized => _controller != null && _controller!.value.isInitialized;

  /// Inisialisasi kamera depan (atau kamera pertama jika kamera depan tidak ditemukan)
  Future<void> initializeFrontCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('NoCamerasFound', 'Tidak ditemukan kamera pada perangkat.');
    }

    // Cari kamera depan terlebih dahulu
    CameraDescription selectedCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    // Dispose controller lama jika ada
    await dispose();

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  /// Mengambil foto
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    if (_controller!.value.isTakingPicture) {
      return null;
    }
    try {
      final XFile photo = await _controller!.takePicture();
      return photo;
    } catch (e) {
      return null;
    }
  }

  /// Membersihkan resource kamera
  Future<void> dispose() async {
    if (_controller != null) {
      final oldController = _controller;
      _controller = null;
      await oldController?.dispose();
    }
  }
}
