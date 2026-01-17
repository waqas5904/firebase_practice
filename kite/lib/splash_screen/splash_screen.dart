import 'package:flutter/material.dart';
import 'package:kite/auth/login_screen.dart';
import 'package:kite/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);

    // navigation after splash complete
    if (!splashProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      });
    }

    return Scaffold(
      body: Center(
        child: splashProvider.isLoading
            ? CircularProgressIndicator()
            : Container(), // loader ke baad screen jaldi se replace ho jayegi
      ),
    );
  }
}
