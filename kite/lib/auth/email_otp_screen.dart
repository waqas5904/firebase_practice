import 'package:flutter/material.dart';
import 'package:kite/providers/email_auth_provider.dart';
import 'package:kite/utils/app_colors.dart';
import 'package:kite/views/map_view.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class EmailOTPView extends StatelessWidget {
  const EmailOTPView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmailAuthProvider>(context);

    void handleVerification(String pin) {
      provider.verifyOTP(
        pin,
        onSuccess: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapView()),
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Verification",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Enter the 6-digit code sent to your email\n${provider.userEmail}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // OTP Input
            Center(
              child: Pinput(
                length: 6,
                onCompleted: (pin) {
                  handleVerification(pin);
                },
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Loading or Help Text
            Center(
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : TextButton(
                      onPressed: () {
                        // Resend logic
                      },
                      child: const Text(
                        "Resend Code",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
