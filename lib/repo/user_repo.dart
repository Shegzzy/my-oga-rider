
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/model/booker_model.dart';
import '../services/model/booking_model.dart';
import '../services/model/companyModel.dart';
import '../services/model/earningModel.dart';
import '../services/model/locationModel.dart';
import '../services/model/order_status_model.dart';
import '../services/model/usermodel.dart';
import '../services/model/vehicleModel.dart';



//Here performs the database operations

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  User? userId = FirebaseAuth.instance.currentUser;


  ///Stores users info in FireStore
  createUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("aUserID")!;
    await _db.collection("Drivers").doc(userID).set(user.toJson()).whenComplete(() =>
        Get.snackbar(
            "Success", "Your account have been created.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }

  ///Updating Password
  Future<void> updatePassword(String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    await _db.collection("Drivers").doc(userID).update({'Password': pass}).then((value) => Get.snackbar(
        "Good", "Password Updated Successfully, Login Again",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.green),
    ).catchError((error, setTrack){
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }

  ///Stores Order Status info in FireStore
  storeOrderStatus(OrderStatusModel order) async {
    await _db.collection("Order_Status").add(order.toJson()).whenComplete(() =>
        Get.snackbar(
            "Success", "Order Service Started.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }

  ///Stores OEarning info in FireStore
  storeEarning(EarningModel earn) async {
    await _db.collection("Earnings").add(earn.toJson()).whenComplete(() =>
        Get.snackbar(
            "Success", "Earning Saved.",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.green),
    )
        .catchError((error, stackTrace) {
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.red);
    });
  }


  ///Getting User Informations from firebase

  Future<UserModel> getDriverDetails(String id){
    return _db.collection("Drivers")
              .doc(id).snapshots()
              .map((event) => UserModel.fromSnapshot(event)).first;
  }

  ///Getting OrderStatus Details

  Future<UserModel> getOrderStatus(String id){
    return _db.collection("Drivers")
        .doc(id).snapshots()
        .map((event) => UserModel.fromSnapshot(event)).first;
  }

  ///Retrieving Delivery Mode Details From Database
  Future<List<LocationModel>?>getLocation() async {
    final snapshot = await _db.collection("Settings").doc("locations").collection("states").get();
    final modeData = snapshot.docs.map((e) => LocationModel.fromSnapshot(e)).toList();
    return modeData;
  }

  ///Retrieving Delivery Mode Details From Database
  Future<List<VehicleModel>?>getVehicle() async {
    final snapshot = await _db.collection("Settings").doc("deliveryVehicles").collection("vehicles").get();
    final modeData = snapshot.docs.map((e) => VehicleModel.fromSnapshot(e)).toList();
    return modeData;
  }

  ///Retrieving Delivery Mode Details From Database
  Future<List<CompanyModel>?>getCompany() async {
    final snapshot = await _db.collection("Companies").get();
    final modeData = snapshot.docs.map((e) => CompanyModel.fromSnapshot(e)).toList();
    return modeData;
  }

  /// Getting Driver Details 2
  Future<UserModel> getUserById(String id) =>
      _db.collection("Drivers").doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });


  ///Fetch  User Details using stream
  Stream<UserModel> getDriverData(){
    final email = FirebaseAuth.instance.currentUser!.email;
    return _db.collection("Drivers")
        .where("Email", isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => UserModel.fromSnapshot(document)).first
    );
  }

  ///Fetch  User Details
  Future<BookerModel> getUserDetailsWithPhone(String phone) async {
    final snapshot = await _db.collection("Users").where("Phone", isEqualTo: phone).get();
    final userData = snapshot.docs.map((e) => BookerModel.fromSnapshot(e)).first;
    return userData;
  }

  ///Fetch  User Details
  Future<UserModel> getUserDetailsWithEmail(String email) async {
    final snapshot = await _db.collection("Drivers").where("Email", isEqualTo: email).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).first;
    return userData;
  }

  ///Retrieving Booking Details From Database
  Future<List<BookingModel>?> getUserBookingDetails() async {
    final email = userId!.email;
    UserModel userInfo = await getUserDetailsWithEmail(email!);

    final snapshot = await _db
        .collection("Bookings")
        .where("Driver ID", isEqualTo: userInfo.id)
        .get();

    // Retrieve the booking data and sort it by date
    List<BookingModel> bookingData = snapshot.docs
        .map((e) => BookingModel.fromSnapshot(e.data()))
        .toList();

    // Sort the list by date
    bookingData.sort((a, b) => DateTime.parse(b.created_at!).compareTo(DateTime.parse(a.created_at!)));

    return bookingData;
  }


  ///Fetch  User Details
  Future<BookingModel> getBookingDetails(String bookingNumber) async {
    final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: bookingNumber).get();
    final bookinData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e.data())).single;
    return bookinData;
  }

  ///Fetch All Users
  Future<List<UserModel>> getAllUserDetails() async {
    final snapshot = await _db.collection("Drivers").get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  ///Updating User Details
  Future<void> updateUserRecord(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? iD = prefs.getString("UserID");
      await _db.collection("Drivers").doc(iD).update(user.updateToJson()).whenComplete(() =>
          Get.snackbar(
              "Success", "Your account have been updated.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.white,
              colorText: Colors.green),
      )
          .catchError((error, stackTrace) {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });
    }

  Stream<OrderStatusModel> getOrderStatusData(String num){
    return _db.collection("Order_Status")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => OrderStatusModel.fromSnapshot(document)).first
    );
  }

  Future<OrderStatusModel> getStatusData(String bookingNumber) async {
    final snapshot = await _db.collection("Order_Status").where("Booking Number", isEqualTo: bookingNumber).get();
    final bookingData = snapshot.docs.map((e) => OrderStatusModel.fromSnapshot(e)).single;
    return bookingData;
  }


}