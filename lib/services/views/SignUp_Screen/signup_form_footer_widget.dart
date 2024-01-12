import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../constant/text_strings.dart';
import '../Login_Screen/login_screen.dart';

class SignupFormFooter extends StatelessWidget {
  const SignupFormFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Get.to(()=> const LoginScreen());
          },
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: moAlreadyHaveAccount,
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(text: moLogin.toUpperCase()),
            ]),
          ),
        ),
      ],
    );
  }
}