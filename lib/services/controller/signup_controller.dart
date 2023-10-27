import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../repo/auth_repo.dart';
import '../../repo/user_repo.dart';
import '../model/usermodel.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  //TextField Controller to get data from TextFields
  final _authController = Get.put(AuthenticationRepository());
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phoneNo = TextEditingController();
  final address = TextEditingController();
  final userRepo = Get.put(UserRepository());

  // Function to register user using email & password
  Future<void> registerUser(String email, String password) async {
    await _authController.createUserWithEmailAndPassword(email, password);
    //String? error = AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password) as String?;
    //if(error != null) {
    //Get.showSnackbar(GetSnackBar(message: error.toString()));
    //}
  }

  Future<void> createUser(UserModel user) async {
    await userRepo.createUser(user);
   // NotificationService().showNotification(title: 'My Oga', body: 'Account created successfully!');
  }

  Future<void> phoneAuthentication(String phoneNo) async {
    _authController.phoneAuthentication(phoneNo);
  }


  //Future<void> saveBookingStatus(BookingModel booking) async {
  //  await userRepo.saveBookingRequest(booking);
    //NotificationService().showNotification(title: 'My Oga', body: 'Booking order placed successfully!');
  //}

}