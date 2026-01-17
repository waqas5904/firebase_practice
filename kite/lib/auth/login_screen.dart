import 'package:flutter/material.dart';
import 'package:kite/auth/otp_number.dart';
import 'package:kite/providers/custom_phone_provider.dart';
import 'package:kite/providers/otp_provider.dart';
import 'package:kite/utils/app_colors.dart';
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            const Text(
              "Welcome to",
              style: TextStyle(
                color: AppColors.background,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: "SF Pro Rounded",
              ),
            ),
            const SizedBox(height: 10),
            Image.asset("assets/images/Stizi.png"),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomPhoneField(
                fillColor: Color(0xFF5F0480),
                hintText: "Enter your phone number",
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                "Sign in with email",
                style: TextStyle(
                  color: Color(0xFF107CF1),
                  fontFamily: "SF Pro Rounded",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Container(height: 2, width: 120, color: Color(0xFF107CF1)),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Stizi shares the same ecosystem as Sidenote, with both apps using the same login for a seamless and less annoying experience.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "SF Pro Rounded",
                ),
              ),
            ),
            Spacer(),
            phoneProvider.isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      text: "Get code",
                      textColor: Color(0xFF7B61FF),
                      backgroundColor: Color(0xFFB4FFC0),
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
                  ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
