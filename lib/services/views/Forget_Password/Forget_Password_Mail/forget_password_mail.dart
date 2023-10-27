import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../constant/image_string.dart';
import '../../../../constant/text_strings.dart';
import '../../../../widgets/form_header_widget.dart';
import '../Forget_Password_Otp/otp_screen.dart';

class ForgetPasswordMailScreen extends StatelessWidget {
  const ForgetPasswordMailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30.0 * 4,
              ),
              const FormHeaderWidget(
                image: moSplashImage,
                title: moForgetPassword,
                subtitle: moForgetEmailSubtitle,
                crossAxisAlignment: CrossAxisAlignment.center,
                heightBetween: 30.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text(moEmail),
                        hintText: moEmail,
                        prefixIcon: Icon(Icons.mail_outline_outlined),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () { Get.to(() => const OTPScreen()); },
                        child: const Text(moNext),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
