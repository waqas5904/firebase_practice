import 'package:flutter/material.dart';
import 'package:kite/auth/login_screen.dart';
import 'package:kite/providers/splash_provider.dart';
import 'package:kite/utils/app_colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);

    if (!splashProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
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
            Spacer(),
            Text(
              "Splash screen animation",
              style: TextStyle(
                color: AppColors.border,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                fontFamily: "SF Pro Text",
              ),
            ),
            Spacer(),
            Text(
              "A Marsh Tech Product",
              style: TextStyle(
                color: AppColors.border,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: "SF Pro Text",
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      // Center(
      //   child: splashProvider.isLoading
      //       ? CircularProgressIndicator()
      //       : Container(),
      // ),
    );
  }
}
