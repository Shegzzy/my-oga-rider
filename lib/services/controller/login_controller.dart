import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../repo/auth_repo.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final _authRepo = Get.put(AuthenticationRepository());

  Future<void> loginUsers(String email, String password) async {
    await _authRepo.loginUserWithEmailAndPassword(email, password) ;
  }

}