import 'package:flutter/material.dart';

import 'login_footer_widget.dart';
import 'login_form_widget.dart';
import 'login_header_widget.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30,),
                LoginHeaderWidget(size: size),
                const SizedBox(height: 10,),
                const LoginForm(),
                const SizedBox(height: 10,),
                const LoginFooterWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
