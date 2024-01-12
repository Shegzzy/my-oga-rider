import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/services/controller/getx_switch_state.dart';

import '../../../constant/colors.dart';
import '../../../constant/image_string.dart';
import '../../../constant/text_strings.dart';
import '../Login_Screen/login_screen.dart';
import '../SignUp_Screen/signup_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GetXSwitchState getXSwitchState = Get.find();
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = getXSwitchState.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? PDarkColor : moPrimaryColor,
      body: Container(
        padding: const EdgeInsets.all(30.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image(
              image: const AssetImage(moSplashImage),
              height: height * 0.2,
            ),
            Column(
              children: [
                Text(
                  moWelcomeTitle,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                Text(
                  moWelcomeSubtitle,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => const LoginScreen());
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Text(moLogin.toUpperCase()),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {

                      //Get.to(() => SignUpScreen());
                      Get.to(()=> const SignUpScreen());
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Text(moSignup.toUpperCase()),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
