import 'package:flutter/material.dart';
import 'dart:math';

class EmailAuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  String? _sentOTP;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get userEmail => _userEmail;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Simulated Email OTP Sending
  // In a real app, you would use a backend or a service like SendGrid/EmailJS
  Future<void> sendOTP(
    String email, {
    required Function(String code) onCodeSent,
    required Function(String error) onError,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      onError("Please enter a valid email address");
      return;
    }

    setLoading(true);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate individual 6-digit code
      String code = (Random().nextInt(900000) + 100000).toString();
      _sentOTP = code;
      _userEmail = email;

      debugPrint("*****************************************");
      debugPrint("SIMULATED EMAIL OTP FOR $email: $code");
      debugPrint("*****************************************");

      setLoading(false);
      onCodeSent(code);
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> verifyOTP(
    String enteredCode, {
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (enteredCode == _sentOTP) {
        // Here you would normally sign in the user in Firebase
        // For simulation, we'll just succeed
        setLoading(false);
        onSuccess();
      } else {
        setLoading(false);
        onError("Invalid OTP code. Please try again.");
      }
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
