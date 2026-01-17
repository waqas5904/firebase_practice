import 'package:flutter/material.dart';
import 'package:kite/widgets/custom_phone_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Login",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          CustomPhoneField(
            hintText: "Enter your phone number",
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
