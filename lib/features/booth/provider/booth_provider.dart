import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/filter_model.dart';
import '../data/frame_model.dart';
import '../../../services/image_stitcher.dart';

enum SessionStatus { idle, running, done }

class BoothProvider extends ChangeNotifier {
  bool _isCountingDown = false;
  int _countdownNumber = 0;
  String _sessionMessage = '';
  final List<XFile> _capturedPhotos = [];
  int _currentPhotoIndex = 0; // 0: belum mulai / 1: foto 1 / 2: foto 2 / 3: foto 3
  bool _isFlashing = false;
  SessionStatus _sessionStatus = SessionStatus.idle;
  FrameModel? _selectedFrame;
  FilterModel _selectedFilter = FilterModel.filters.first;

  // Untuk retake foto spesifik
  int? _retakeIndex; // 0, 1, atau 2 jika sedang mode retake foto tertentu

  // Stitched PNG output
  Uint8List? _stitchedImageBytes;
  bool _isStitching = false;

  bool get isCountingDown => _isCountingDown;
  int get countdownNumber => _countdownNumber;
  String get sessionMessage => _sessionMessage;
  List<XFile> get capturedPhotos => List.unmodifiable(_capturedPhotos);
  int get currentPhotoIndex => _currentPhotoIndex;
  bool get isFlashing => _isFlashing;
  SessionStatus get sessionStatus => _sessionStatus;
  bool get isSessionRunning => _sessionStatus == SessionStatus.running;
  FrameModel? get selectedFrame => _selectedFrame;
  FilterModel get selectedFilter => _selectedFilter;
  int? get retakeIndex => _retakeIndex;
  bool get isRetakeMode => _retakeIndex != null;
  Uint8List? get stitchedImageBytes => _stitchedImageBytes;
  bool get isStitching => _isStitching;

  XFile? get lastCapturedPhoto =>
      _capturedPhotos.isNotEmpty ? _capturedPhotos.last : null;

  void selectFrame(FrameModel frame) {
    _selectedFrame = frame;
    notifyListeners();
  }

  void applyFilter(FilterModel filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setRetakeIndex(int? index) {
    _retakeIndex = index;
    notifyListeners();
  }

  void setCountingDown(bool value) {
    _isCountingDown = value;
    notifyListeners();
  }

  void setCountdownNumber(int value) {
    _countdownNumber = value;
    notifyListeners();
  }

  void setSessionMessage(String message) {
    _sessionMessage = message;
    notifyListeners();
  }

  void setFlashing(bool value) {
    _isFlashing = value;
    notifyListeners();
  }

  void addPhoto(XFile photo) {
    _capturedPhotos.add(photo);
    notifyListeners();
  }

  void updatePhotoAt(int index, XFile photo) {
    if (index >= 0 && index < _capturedPhotos.length) {
      _capturedPhotos[index] = photo;
      notifyListeners();
    }
  }

  void clearPhotos() {
    _capturedPhotos.clear();
    _currentPhotoIndex = 0;
    _retakeIndex = null;
    _sessionMessage = '';
    _sessionStatus = SessionStatus.idle;
    _stitchedImageBytes = null;
    _isStitching = false;
    notifyListeners();
  }

  /// Melakukan stitching foto menjadi 1 file PNG vertikal
  Future<Uint8List?> generateStitchedStrip() async {
    if (_capturedPhotos.isEmpty) return null;
    try {
      _isStitching = true;
      notifyListeners();

      final bytes = await ImageStitcher.stitchStrip(
        photos: _capturedPhotos,
        frame: _selectedFrame,
        filter: _selectedFilter,
      );

      _stitchedImageBytes = bytes;
      _isStitching = false;
      notifyListeners();
      return bytes;
    } catch (e) {
      debugPrint('Error stitching photos: $e');
      _isStitching = false;
      notifyListeners();
      return null;
    }
  }

  /// Memulai sesi jepret otomatis 3x
  Future<void> startPhotoSession({
    required Future<XFile?> Function() onTakePicture,
    VoidCallback? onSessionCompleted,
  }) async {
    if (_sessionStatus == SessionStatus.running) return;

    // Reset list foto dan state awal
    _capturedPhotos.clear();
    _currentPhotoIndex = 0;
    _retakeIndex = null;
    _sessionMessage = '';
    _sessionStatus = SessionStatus.running;
    notifyListeners();

    const int totalPhotos = 3;

    for (int photoNum = 1; photoNum <= totalPhotos; photoNum++) {
      _currentPhotoIndex = photoNum;
      _sessionMessage = '';
      notifyListeners();

      // Countdown 3-2-1, tiap angka 700ms
      _isCountingDown = true;
      for (int count = 3; count >= 1; count--) {
        _countdownNumber = count;
        notifyListeners();
        HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 700));
      }

      // Reset countdown sebelum jepret
      _countdownNumber = 0;
      _isCountingDown = false;
      notifyListeners();

      // Jepret
      final photo = await onTakePicture();

      // Flash putih & getar kecil
      _isFlashing = true;
      notifyListeners();
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      _isFlashing = false;
      notifyListeners();

      // Simpen ke list
      if (photo != null) {
        _capturedPhotos.add(photo);
        notifyListeners();
      }

      // Jika belum selesai 3 foto, beri jeda 1 detik dengan pesan pose berikutnya
      if (photoNum < totalPhotos) {
        _sessionMessage = 'Siap, pose ${photoNum + 1}!';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
        _sessionMessage = '';
        notifyListeners();
      }
    }

    _sessionStatus = SessionStatus.done;
    _sessionMessage = 'Selesai!';
    notifyListeners();

    if (onSessionCompleted != null) {
      onSessionCompleted();
    }
  }

  /// Mengambil ulang satu foto spesifik
  Future<void> startSingleRetakeSession({
    required int index,
    required Future<XFile?> Function() onTakePicture,
    VoidCallback? onCompleted,
  }) async {
    if (_sessionStatus == SessionStatus.running) return;

    _retakeIndex = index;
    _currentPhotoIndex = index + 1;
    _sessionStatus = SessionStatus.running;
    _sessionMessage = 'Ulang foto ke-${index + 1}';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    // Countdown 3-2-1
    _isCountingDown = true;
    for (int count = 3; count >= 1; count--) {
      _countdownNumber = count;
      notifyListeners();
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 700));
    }

    _countdownNumber = 0;
    _isCountingDown = false;
    notifyListeners();

    // Jepret
    final photo = await onTakePicture();

    // Flash putih
    _isFlashing = true;
    notifyListeners();
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    _isFlashing = false;
    notifyListeners();

    if (photo != null) {
      if (index < _capturedPhotos.length) {
        _capturedPhotos[index] = photo;
      } else {
        _capturedPhotos.add(photo);
      }
      notifyListeners();
    }

    _sessionStatus = SessionStatus.done;
    _sessionMessage = 'Selesai!';
    _retakeIndex = null;
    notifyListeners();

    if (onCompleted != null) {
      onCompleted();
    }
  }
}
