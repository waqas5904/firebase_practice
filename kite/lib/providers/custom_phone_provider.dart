import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Provider class for phone field state
class PhoneFieldProvider extends ChangeNotifier {
  String _countryCode = '+92'; // Default to Pakistan
  bool _isFocused = false;
  bool _isLoading = false;
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get countryCode => _countryCode;
  bool get isFocused => _isFocused;
  bool get isLoading => _isLoading;
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

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> verifyPhoneNumber({
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    if (_controller.text.isEmpty) {
      onError("Please enter a phone number");
      return;
    }

    setLoading(true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This callback will be called in some cases for auto-verification on Android
          await _auth.signInWithCredential(credential);
          setLoading(false);
          // Handled elsewhere or via auth state changes
        },
        verificationFailed: (FirebaseAuthException e) {
          setLoading(false);
          onError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          setLoading(false);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // You can use this to handle timeout
        },
      );
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
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
