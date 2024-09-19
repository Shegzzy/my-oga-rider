import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:otp_timer_button/otp_timer_button.dart';

import '../../../repo/auth_repo.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  @override
  void initState() {
    super.initState();
    AuthenticationRepository().autoRedirectTimer();
  }

  @override
  void dispose() {
    super.dispose();
    AuthenticationRepository().timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationRepository());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 50,),
              const Center(child: Icon(LineAwesomeIcons.envelope_open, size: 100,)),
              const SizedBox(height: 25,),
              const Text('Verify your email address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black),),
              const SizedBox(height: 25,),
              const Text('A verification mail has been sent to your email address, please check your email for a verification link to verify your email address', textAlign: TextAlign.center,),

              const SizedBox(height: 25,),
              SizedBox(
                width: 160,
                child: OtpTimerButton(
                  onPressed: () async {
                    controller.auth.currentUser?.sendEmailVerification();
                    Get.snackbar(
                        "Success", "Link sent",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.white,
                        colorText: Colors.green
                    );
                  },
                  text: const Text('Resend Link', style: TextStyle(
                    color: Colors.blue
                  ),),
                  duration: 60,
                  backgroundColor: Colors.white,
                  buttonType: ButtonType.text_button,
                ),
              ),

              TextButton(
                  onPressed: (){
                    controller.logout();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LineAwesomeIcons.arrow_left_solid),
                      SizedBox(width: 10,),
                      Text('back to Login'),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
