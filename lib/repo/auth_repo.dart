import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/repo/user_repo.dart';
import 'package:my_oga_rider/services/views/Permission_info_screen/permission_alert_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/views/welcome_screen/welcome_screen.dart';
import '../services/model/usermodel.dart';
import '../services/notificationService.dart';
import '../services/views/Car_Registration/verification_pending.dart';
import '../services/views/Login_Screen/login_screen.dart';
import '../services/views/Main_Screen/main_screen.dart';
import '../services/views/SignUp_Screen/signup_screen.dart';
import 'exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  //Variables
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  var verificationId = "".obs;
  dynamic credentials;
  final _userRepo = Get.put(UserRepository());

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
        final user = firebaseUser.user!;
        user.sendEmailVerification();
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
        // await NotificationService().getDeviceToken().then((token) async {
        //   // print(token);
        //   await _db.collection("Drivers").doc(firebaseUser.user?.uid).update({
        //     "Token": token
        //   });
        //   prefs.setString("token", token);
        // });
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
    prefs.remove("UserID");
    prefs.remove("aUserID");
    prefs.remove("UserEmail");
    prefs.remove("password");
    prefs.remove("Phone");
    prefs.remove('pendingBookings');
    prefs.remove('token');
    // prefs.remove('acceptedBookings');
    await _auth.signOut();
    Get.offAll(() => const WelcomeScreen());
  }

  Future<bool> uploadCarEntry(Map<String,dynamic> carData)async{
    bool isUploaded = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("aUserID")!;

    await FirebaseFirestore.instance.collection('Drivers').doc(userID).set(carData,SetOptions(merge: true));

    isUploaded = true;

    return isUploaded;
  }


  checkVerification() async {
    String? docId = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    try {
      /// Getting Driver Details 2
      await _db.collection("Drivers").doc(userID).get().then((value) {
        docId = value.data()!["Verified"];
      }).catchError((error, stackTrace) {
        Get.snackbar("Error", "Not Allowed",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.red);
        logout();
      });

      var myInt = int.tryParse(docId!);

      if (docId == "0") {
        await _auth.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("UserID");
        prefs.remove("UserEmail");
        Get.offAll(() => const VerificaitonPendingScreen());
      }
      else if (docId == "1") {
        final user = _auth.currentUser!;
        if (user.emailVerified) {
          _checkUserType();
        } else {
          user.sendEmailVerification();
          _checkUserType();
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

  _checkUserType() async {
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

}
