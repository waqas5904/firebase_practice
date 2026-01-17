import 'package:flutter/material.dart';
import 'package:kite/auth/login_screen.dart';
import 'package:kite/providers/splash_provider.dart';
import 'package:kite/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);

    if (!splashProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Lottie.asset(
              "assets/animations/Location Pin.json",
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              "Finding your way...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "SF Pro Rounded",
              ),
            ),
            const Spacer(),
            Text(
              "A Marsh Tech Product",
              style: TextStyle(
                color: AppColors.border,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: "SF Pro Text",
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
