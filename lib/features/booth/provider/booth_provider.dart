import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../data/frame_model.dart';

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

  bool get isCountingDown => _isCountingDown;
  int get countdownNumber => _countdownNumber;
  String get sessionMessage => _sessionMessage;
  List<XFile> get capturedPhotos => List.unmodifiable(_capturedPhotos);
  int get currentPhotoIndex => _currentPhotoIndex;
  bool get isFlashing => _isFlashing;
  SessionStatus get sessionStatus => _sessionStatus;
  bool get isSessionRunning => _sessionStatus == SessionStatus.running;
  FrameModel? get selectedFrame => _selectedFrame;

  XFile? get lastCapturedPhoto =>
      _capturedPhotos.isNotEmpty ? _capturedPhotos.last : null;

  void selectFrame(FrameModel frame) {
    _selectedFrame = frame;
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

  void clearPhotos() {
    _capturedPhotos.clear();
    _currentPhotoIndex = 0;
    _sessionMessage = '';
    _sessionStatus = SessionStatus.idle;
    notifyListeners();
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
}
