import 'package:flutter/material.dart';
import 'package:kite/home_screen.dart';
import 'package:kite/providers/otp_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPView extends StatelessWidget {
  const OTPView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OTPProvider>();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.blue, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue),
      ),
    );

    void handleVerification() {
      provider.verifyOTP(
        onSuccess: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the 4-digit code sent to your phone',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              Center(
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : Pinput(
                        controller: provider.pinController,
                        focusNode: provider.focusNode,
                        length: 6, // Firebase normally sends 6 digits
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        showCursor: true,
                        onChanged: (value) => provider.updateOTP(value),
                        onCompleted: (pin) {
                          handleVerification();
                        },
                      ),
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Resend OTP logic can be added here
                  },
                  child: Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: provider.isOTPComplete && !provider.isLoading
                      ? () => handleVerification()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
