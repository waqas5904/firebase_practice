import 'package:flutter/material.dart';
import 'package:kite/auth/otp_number.dart';
import 'package:kite/providers/custom_phone_provider.dart';
import 'package:kite/providers/otp_provider.dart';
import 'package:kite/widgets/custom_button.dart';
import 'package:kite/widgets/custom_phone_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneProvider = context.watch<PhoneFieldProvider>();
    final otpProvider = context.read<OTPProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.phone_android, size: 80, color: Colors.blue),
              const SizedBox(height: 40),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your phone number to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              CustomPhoneField(
                hintText: "Enter your phone number",
                onChanged: (value) {},
              ),
              const SizedBox(height: 50),
              phoneProvider.isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: "Login with Code",
                      onTap: () {
                        phoneProvider.verifyPhoneNumber(
                          onCodeSent: (verificationId) {
                            otpProvider.setVerificationId(verificationId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OTPView(),
                              ),
                            );
                          },
                          onError: (error) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
