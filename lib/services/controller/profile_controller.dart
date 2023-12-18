import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repo/user_repo.dart';
import '../model/booking_model.dart';
import '../model/companyModel.dart';
import '../model/locationModel.dart';
import '../model/usermodel.dart';
import 'package:async/async.dart';

import '../model/vehicleModel.dart';


class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _userRepo = Get.put(UserRepository());
  final _memoizer = AsyncMemoizer();
  final _user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get User Email and Pass it to UserRepository to fetch user record.
  getUserData() async {
    return _memoizer.runOnce(()  async {
      final email = _user?.email;
      if (email == null) {
        final phone = _user?.phoneNumber;
        return await _userRepo.getUserDetailsWithPhone(phone!);
      } else {
        return await _userRepo.getUserDetailsWithEmail(email);
      }
    });
  }

/// Fetch Location
   Future<List<LocationModel>?> getAllLocation() async {
       return await _userRepo.getLocation();
  }

  Future<List<VehicleModel>?> getAllVehicle() async {
    return await _userRepo.getVehicle();
  }

  Future<List<CompanyModel>?> getAllCompany() async {
    return await _userRepo.getCompany();
  }

  Future<List<UserModel>> getAllUser() async {
    return await _userRepo.getAllUserDetails();
  }

  updateRecord(UserModel user) async {
    await _userRepo.updateUserRecord(user);
    //NotificationService().showNotification(title: 'My Oga', body: 'Profile updated successful!');
  }

  /// Get User Id and Pass it to UserRepository to fetch Package record.
  Future<Future>getPackageData() async {
    return _memoizer.runOnce(()  async {
      final email =_user!.email;
      UserModel userInfo = await _userRepo.getUserDetailsWithEmail(email!);
      if (userInfo != null) {
        //return await _userRepo.getPackageDetails(userInfo.id!);
      } else {
        Get.snackbar("Error", "Can't fetch package");
      }
    });
  }


  Future<List<BookingModel>?> getAllUserBookings() async {
    return await _userRepo.getUserBookingDetails();
  }

  getUserById() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? iD = prefs.getString("UserID");
    return await _userRepo.getUserById(iD!);
  }


}