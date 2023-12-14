import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/booking_model.dart';
import '../model/order_status_model.dart';

class FirestoreService {

  FirebaseFirestore _db = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  BookingModel? bookingModel;
  List<BookingModel> acceptedBookingList = [];

  // Get pending bookings
  Stream<List<BookingModel>> getBookingData() {
    return _db.collection("Bookings")
        .where("Status", isEqualTo: "pending")
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => BookingModel.fromSnapshot(document.data()))
        .toList());
  }


  Stream<BookingModel> getBookingDataByNum(String num){
    return _db.collection("Bookings")
        .where("Booking Number", isEqualTo: num)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => BookingModel.fromSnapshot(document.data())).first
    );
  }


  Stream<QuerySnapshot> requestStream({required String id}) {
    CollectionReference reference = _db.collection("Bookings");
    return reference.snapshots();
  }

  Future <void> updateDetail(String? bookingNum) async {
    late String docId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    await _db.collection("Bookings")
        .where("Booking Number", isEqualTo:bookingNum)
        .get().then((value) => value.docs.forEach((element) {
          docId = element.id;
        }));
    return _db.collection("Bookings")
        .doc(docId)
        .update({'Status': 'active', 'Driver ID': userID});
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

  _saveDeviceToken() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      //String deviceToken = await fcm.getToken();
     // await prefs.setString('token', deviceToken);
    }
  }

  // Function to load accepted bookings from shared preferences
  Future<void> loadAcceptedBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? serializedList = prefs.getStringList('acceptedBookings');

    if (serializedList != null) {
      acceptedBookingList = serializedList
          .map((jsonString) => BookingModel.fromSnapshot(json.decode(jsonString)))
          .toList();
    }
  }

  // Function to save accepted bookings to shared preferences
  Future<void> saveAcceptedBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> serializedList =
    acceptedBookingList.map((booking) => json.encode(booking.toJson())).toList();

    prefs.setStringList('acceptedBookings', serializedList);
  }

  // Function to add a new accepted booking
  void addAcceptedBooking(BookingModel newBooking) {
    acceptedBookingList.add(newBooking);
    saveAcceptedBookings();
  }

  // Function to remove a completed booking
  void removeCompletedBooking(String bookingNumber) {
    acceptedBookingList.removeWhere((booking) => booking.bookingNumber == bookingNumber);
    saveAcceptedBookings();
  }

}