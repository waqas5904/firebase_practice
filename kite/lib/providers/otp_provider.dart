import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Provider class for OTP state management
class OTPProvider extends ChangeNotifier {
  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _otpCode = '';
  String? _verificationId;
  bool _isLoading = false;

  String get otpCode => _otpCode;
  bool get isLoading => _isLoading;
  bool get isOTPComplete => _otpCode.length == 6;

  void setVerificationId(String id) {
    _verificationId = id;
    notifyListeners();
  }

  void updateOTP(String value) {
    _otpCode = value;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> verifyOTP({
    Function? onSuccess,
    Function(String error)? onError,
  }) async {
    if (_verificationId == null) {
      if (onError != null) onError("Verification ID is missing");
      return;
    }

    setLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpCode,
      );

      await _auth.signInWithCredential(credential);
      setLoading(false);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      setLoading(false);
      if (onError != null) onError(e.toString());
      pinController.clear();
      _otpCode = '';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
