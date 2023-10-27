import 'package:flutter/material.dart';
import 'package:my_oga_rider/services/views/SignUp_Screen/signup_form_footer_widget.dart';
import 'package:my_oga_rider/services/views/SignUp_Screen/signup_form_widget.dart';

import '../../../constant/image_string.dart';
import '../../../constant/text_strings.dart';
import '../../../widgets/form_header_widget.dart';


class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FormHeaderWidget(
                  image: moSplashImage,
                  title: moSignupTitle,
                  subtitle: moSignupSubtitle,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SignupFormWidget(),
                SignupFormFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

