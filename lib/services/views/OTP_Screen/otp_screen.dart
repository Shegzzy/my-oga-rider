import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

import '../../../constant/image_string.dart';
import '../../../constant/text_strings.dart';
import '../../controller/otp_controller.dart';
import '../../controller/signup_controller.dart';




class OTPScreen extends StatelessWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otpController = Get.put(OTPController());
    final controller = Get.put(SignUpController());
    var otp;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage(moLoginImage),
              ),
              Text(moOtpTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 40.0),
              Text("Enter code sent for verification.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              const SizedBox(
                height: 20.0,
              ),
              OtpTextField(
                  numberOfFields: 6,
                  fillColor: Colors.black.withOpacity(0.1),
                  filled: true,
                  onCodeChanged: (code){
                    otp = code;
                  },
                  onSubmit: (code) async{
                    otp = code;
                    await otpController.verifyOTP(otp);
                  }),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async{
                      await otpController.verifyOTP(otp);
                    },
                    child: otpController.otpLoading ?
                    const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(),)
                        : Text("Verify".toUpperCase()),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                child: OtpTimerButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final phoneNumber = prefs.getString("Phone");
                    controller.phoneAuthentication(phoneNumber!);
                  },
                  text: Text('Resend OTP'.toUpperCase()),
                  duration: 60,
                  backgroundColor: const Color(0xFF00002e),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
