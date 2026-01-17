import 'package:flutter/material.dart';
import 'package:kite/providers/custom_phone_provider.dart';
import 'package:kite/providers/splash_provider.dart';
import 'package:provider/provider.dart';

class AppProviders {
  static List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider<SplashProvider>(create: (_) => SplashProvider()),
    ChangeNotifierProvider<PhoneFieldProvider>(
      create: (_) => PhoneFieldProvider(),
    ),
    // yahan baaki providers add kar sakte ho
  ];

  static Widget init({required Widget child}) {
    return MultiProvider(providers: providers, child: child);
  }
}
