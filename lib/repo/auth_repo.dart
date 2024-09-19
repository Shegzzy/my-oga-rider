import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/repo/user_repo.dart';
import 'package:my_oga_rider/services/controller/request_controller.dart';
import 'package:my_oga_rider/services/views/Email_Verification_Screen/email_verification_screen.dart';
import 'package:my_oga_rider/services/views/Permission_info_screen/permission_alert_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/views/welcome_screen/welcome_screen.dart';
import '../services/model/usermodel.dart';
import '../services/notificationService.dart';
import '../services/views/Car_Registration/car_regitration_widget.dart';
import '../services/views/Car_Registration/verification_pending.dart';
import '../services/views/Login_Screen/login_screen.dart';
import '../services/views/Main_Screen/main_screen.dart';
import '../services/views/SignUp_Screen/signup_screen.dart';
import 'exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  //Variables
  late Timer timer;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;

  final _db = FirebaseFirestore.instance;
  var verificationId = "".obs;
  dynamic credentials;
  final _userRepo = Get.put(UserRepository());
  final requestController = Get.put(FirestoreService());

  UserModel? _userModel;


  // Functions
  void phoneAuthentication(String phoneNo) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
      },
      codeSent: (verificationId, resendToken) {
        log('Code sent');
        this.verificationId.value = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        this.verificationId.value = verificationId;
      },
      verificationFailed: (e) {
        if (e.code == "invalid-phone-number") {
          Get.snackbar('Error', 'Provided phone number is not valid.');
        } else {
          Get.snackbar('Error', 'Something went wrong. Try again.');
        }
      },
    );
  }

  verifyOtp(String otpNumber) async {
    Get.snackbar(
        "Error", "OTP Verification Called", snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.green
    );
    PhoneAuthCredential userCredential =
    PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: otpNumber);
    await FirebaseAuth.instance.signInWithCredential(userCredential).then((value) async {
      final firebaseUser = value;
      if(firebaseUser.user != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("CUserID", firebaseUser.user!.uid);
      }
    }).catchError((e) {
      Get.snackbar(
          "Error", e.toString(), snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.green
      );
    });
  }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId.value, smsCode: otp));
    return credentials.user != null ? true : false;
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final firebaseUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.user != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("aUserID", firebaseUser.user!.uid);
        prefs.setString("UserEmail", firebaseUser.user!.email!);
        prefs.setString("password", password);
        // final user = firebaseUser.user!;
        // user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      Get.snackbar(
          ex.toString(), ex.message, snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red
      );
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailAndPasswordFailure();
      Get.snackbar(
          ex.toString(), ex.message, snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red
      );
      throw ex;
    }
  }

  Future<void> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final firebaseUser = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if(firebaseUser.user != null){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("UserID", firebaseUser.user!.uid);
        prefs.setString("UserEmail", firebaseUser.user!.email!);
        checkVerification();
      }
      else {
        Get.to(() => const LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        Get.snackbar(
            "Error", "No Internet Connection", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else if (e.code == "wrong-password") {
        Get.snackbar(
            "Error", "Please Enter correct password", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else if (e.code == 'user-not-found') {
        Get.snackbar(
            "Error", "No such user with this email", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }  else if (e.code == 'too-many-requests') {
        Get.snackbar(
            "Error", "Too many attempts please try later", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }  else if (e.code == 'unknown') {
        Get.snackbar(
            "Error", "Email and Password Fields are required", snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      } else {
        Get.snackbar(
            "Error", e.toString(), snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red
        );
      }
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("UserID");
    await prefs.remove("aUserID");
    await prefs.remove("UserEmail");
    await prefs.remove("password");
    await prefs.remove("Phone");
    await prefs.remove('pendingBookings');
    await prefs.remove('token');
    requestController.requestHistory.clear();
    await _auth.signOut();
    Get.offAll(() => const WelcomeScreen());
  }

  Future<bool> uploadCarEntry(Map<String, dynamic> carData) async {
    bool isUploaded = false;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString("aUserID")!;

      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userID)
          .set(carData, SetOptions(merge: true))
          .whenComplete(() {
        checkVerification();
      });

      isUploaded = true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload car data",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    return isUploaded;
  }

  checkVerification() async {
    String? docId = "";
    String? company = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = prefs.getString("UserID");
    userID ??= prefs.getString("aUserID");
    try {
      /// Getting Driver Details 2
      await _db.collection("Drivers").doc(userID).get().then((value) {
        docId = value.data()!["Verified"];
        company = value.data()?["Company"] ?? "";
      }).catchError((error, stackTrace) {
        Get.snackbar("Error", "Not Allowed",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
        logout();
      });

      var myInt = int.tryParse(docId!);

      if(company == "") {
        Get.snackbar("Attention!!", "Please complete your registration",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green);
        Get.to(() => const CarRegistrationWidget());
      } else if (docId == "0") {
        await _auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("UserID");
        prefs.remove("UserEmail");
        Get.offAll(() => const VerificaitonPendingScreen());
      } else if (docId == "1") {
        final user = _auth.currentUser!;
        if (user.emailVerified) {
          checkUserType();
        } else {
          await user.sendEmailVerification();
          Get.offAll(() => const EmailVerificationScreen());
          // checkUserType();
        }
      } else if (docId == "Hold"){
        await logout();
        Get.snackbar("Error", "Your account is currently on hold, please contact your dispatch company",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      }
      else {
        Get.snackbar("Error", "Couldn't Verify your account, contact support!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
        await _auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("UserID");
        prefs.remove("UserEmail");
        Get.offAll(() => const WelcomeScreen());
      }
    } catch (e){
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    }
  }

  checkUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    final iD = prefs.getString("UserID");
    final userDoc =  await FirebaseFirestore.instance.collection("Drivers").doc(iD).get();
    if(userDoc.exists){
      if(Platform.isAndroid){
        if(permission == LocationPermission.denied){
          Get.to(()=> const PermissionScreen());
        }else{
          Get.offAll(() => MainScreen());
        }
      }else{
        Get.offAll(() => MainScreen());
      }
    } else{
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      logout();
    }
  }

  void autoRedirectTimer() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer){
      _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if(user != null){
        if(user.emailVerified){
          timer.cancel();
          checkVerification();
        }
      } else {
        // timer.cancel();
        return;
      }
    });
  }

}
