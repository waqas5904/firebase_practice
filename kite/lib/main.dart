import 'package:flutter/material.dart';
import 'package:kite/multi_provider/multi_app_provider.dart';
import 'package:kite/splash_screen/splash_screen.dart';

void main() {
  runApp(AppProviders.init(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: SplashScreen());
  }
}
