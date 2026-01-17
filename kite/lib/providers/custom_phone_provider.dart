import 'package:flutter/material.dart';

// Provider class for phone field state
class PhoneFieldProvider extends ChangeNotifier {
  String _countryCode = '+1';
  bool _isFocused = false;
  final TextEditingController _controller = TextEditingController();

  String get countryCode => _countryCode;
  bool get isFocused => _isFocused;
  TextEditingController get controller => _controller;

  String get fullPhoneNumber => '$_countryCode${_controller.text}';

  void setCountryCode(String code) {
    _countryCode = code;
    notifyListeners();
  }

  void setFocusState(bool focused) {
    _isFocused = focused;
    notifyListeners();
  }

  void clearPhone() {
    _controller.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
