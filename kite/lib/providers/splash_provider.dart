import 'package:flutter/material.dart';
import 'dart:async';

class SplashProvider with ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  SplashProvider() {
    startSplash();
  }

  void startSplash() {
    Timer(Duration(seconds: 3), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}
