import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Global variables for App Platform management
class Platform extends ChangeNotifier {
  String _osDiv = '';
  bool _isLoading = false;
  String _userDiv = '';
  String _fcmToken = '';
  bool _qrCheck = false;

  String get osDiv => _osDiv;
  bool get isLoading => _isLoading;
  String get userDiv => _userDiv;
  String get fcmToken => _fcmToken;
  bool get qrCheck => _qrCheck;

  set osDiv(String value) {
    _osDiv = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set userDiv(String value) {
    _userDiv = value;
    notifyListeners();
  }

  set fcmToken(String value) {
    _fcmToken = value;
    notifyListeners();
  }

  set qrCheck(bool value) {
    _qrCheck = value;
    notifyListeners();
  }
}
