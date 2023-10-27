import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../SignUp_Screen/signup_screen.dart';


class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 5.0,
        ),
        TextButton(
          onPressed: () {
            Get.to(()=> const SignUpScreen());
          },
          child: Text.rich(
            TextSpan(
                text: moDontHaveAccount,
                style: Theme.of(context).textTheme.bodyText1,
                children: const [
                  TextSpan(
                    text: moSignup,
                    style: TextStyle(color: moAccentColor),
                  ),
                ]
            ),
          ),
        ),
      ],
    );
  }
}
