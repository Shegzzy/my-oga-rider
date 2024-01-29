import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repo/auth_repo.dart';
import '../views/Car_Registration/car_regitration_widget.dart';
import '../views/Forget_Password/Forget_Password_Otp/otp_screen.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();
  final _authController = Get.put(AuthenticationRepository());
  final _auth = FirebaseAuth.instance;

  bool _otpLoading = false;
  bool get otpLoading => _otpLoading;

  Future<void> verifyOTP(String otp) async {
   try{
     _otpLoading = true;
     update();

     var isVerified = await _authController.verifyOTP(otp);
     if(isVerified == true){
       await _auth.signOut();
       Get.offAll(() => const CarRegistrationWidget());
     } else {
       Get.offAll(const OTPScreen());
     }
   }catch(e){
     print('Error $e');
   }finally{
     _otpLoading = false;
     update();
   }
  }

  void verifyLoginOTP(String otp) async {
    var isVerified = await _authController.verifyOTP(otp);
    isVerified ? Get.offAll(() => const CarRegistrationWidget()) : Get.back();
  }

}