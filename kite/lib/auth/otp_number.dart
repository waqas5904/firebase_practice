import 'package:flutter/material.dart';
import 'package:kite/providers/otp_provider.dart';
import 'package:kite/utils/app_colors.dart';
import 'package:kite/views/map_view.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPView extends StatelessWidget {
  const OTPView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OTPProvider>(context);

    void handleVerification() {
      provider.verifyOTP(
        onSuccess: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MapView()),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
      );
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Icon(Icons.arrow_back_ios_new, color: Colors.white),
              const SizedBox(height: 100),
              Text(
                textAlign: TextAlign.center,
                "Enter the 6-digit code sent to your phone number${provider.phoneNumber} ",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: "SF Pro Rounded",
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input
              Center(
                child: Pinput(
                  length: 6,
                  controller: provider.pinController,
                  focusNode: provider.focusNode,
                  onChanged: (pin) {
                    provider.setOTP(pin);
                  },
                  onCompleted: (pin) {
                    provider.setOTP(pin);
                    handleVerification();
                  },
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  "Full code is need to activate",
                  style: TextStyle(
                    color: Color(0xFFB4FFC0),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    fontFamily: "SF Pro Rounded",
                  ),
                ),
              ),

              // Loading or Help Text
              Center(
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn’t receive code? ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: "SF Pro Rounded",
                                color: Colors.white,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  "Resend",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "SF Pro Rounded",
                                    color: Colors.blue,
                                  ),
                                ),
                                Container(
                                  height: 2,
                                  width: 50,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
              Spacer(),
              Center(
                child: Text(
                  "By providing your phone number, you agree Marsh Tech may send you texts with notifications and security codes",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "SF Pro Rounded",
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
