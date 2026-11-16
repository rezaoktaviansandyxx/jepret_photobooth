import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class BoothProvider extends ChangeNotifier {
  bool _isCountingDown = false;
  int _countdownNumber = 0;
  final List<XFile> _capturedPhotos = [];
  bool _isFlashing = false;

  bool get isCountingDown => _isCountingDown;
  int get countdownNumber => _countdownNumber;
  List<XFile> get capturedPhotos => List.unmodifiable(_capturedPhotos);
  bool get isFlashing => _isFlashing;

  XFile? get lastCapturedPhoto =>
      _capturedPhotos.isNotEmpty ? _capturedPhotos.last : null;

  void setCountingDown(bool value) {
    _isCountingDown = value;
    notifyListeners();
  }

  void setCountdownNumber(int value) {
    _countdownNumber = value;
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
    notifyListeners();
  }
}
