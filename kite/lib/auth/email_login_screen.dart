import 'package:flutter/material.dart';
import 'package:kite/auth/email_otp_screen.dart';
import 'package:kite/providers/email_auth_provider.dart';
import 'package:kite/utils/app_colors.dart';
import 'package:kite/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailProvider = context.watch<EmailAuthProvider>();

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
            const Spacer(),
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

            // Email Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5F0480),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: emailProvider.emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Enter your email address",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Sign in with phone number",
                      style: TextStyle(
                        color: Color(0xFF107CF1),
                        fontFamily: "SF Pro Rounded",
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 180,
                    color: const Color(0xFF107CF1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
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
            const Spacer(),

            emailProvider.isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      text: "Get code",
                      textColor: const Color(0xFF7B61FF),
                      backgroundColor: const Color(0xFFB4FFC0),
                      onTap: () {
                        emailProvider.sendOTP(
                          emailProvider.emailController.text,
                          onCodeSent: (code) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EmailOTPView(),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
