
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../views/Welcome_Screen/welcome_screen.dart';


class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 50));
    animate.value = true;
    await Future.delayed(const Duration(milliseconds: 2000));
    Get.to(const WelcomeScreen());
  }

}