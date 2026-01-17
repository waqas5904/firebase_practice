import 'package:flutter/material.dart';
import 'package:kite/multi_provider/multi_app_provider.dart';
import 'package:kite/splash_screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // async ka prerequisite

  // Firebase initialize karna
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App run karna with MultiProvider
  runApp(AppProviders.init(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
