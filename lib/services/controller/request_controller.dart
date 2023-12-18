import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/booking_model.dart';
import '../model/order_status_model.dart';

class FirestoreService extends GetxController {

  FirebaseFirestore _db = FirebaseFirestore.instance;
  late SharedPreferences prefs;
  BookingModel? bookingModel;
  List<BookingModel> _requestHistory = [];
  List<BookingModel> get requestHistory => _requestHistory;
  List<BookingModel> _acceptedBookingList = [];
  List<BookingModel> get acceptedBookingList => _acceptedBookingList;


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

  // Future <void> updateDetail(String? bookingNum) async {
  //   late String docId;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final userID = prefs.getString("UserID")!;
  //   await _db.collection("Bookings").where("Booking Number", isEqualTo:bookingNum).get().then((value) => value.docs.forEach((element) {docId = element.id;}));
  //   var updatedBookingSnapshot = await _db.collection("Bookings").doc(docId).get();
  //
  //   // Add the updated booking to the acceptedBookingList
  //   if (updatedBookingSnapshot.exists) {
  //     BookingModel updatedBooking = BookingModel.fromSnapshot(updatedBookingSnapshot.data()!);
  //     addAcceptedBooking(updatedBooking);
  //   }
  //   return _db.collection("Bookings").doc(docId).update({'Status': 'active', 'Driver ID': userID});
  // }

  Future<void> updateDetail(String? bookingNum) async {
    String docId;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;

    // Fetch the booking to be updated
    var snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: bookingNum).get();

    if (snapshot.docs.isNotEmpty) {
      docId = snapshot.docs.first.id;

      // Update the booking status to 'active' and set the driver ID
      await _db.collection("Bookings").doc(docId).update({'Status': 'active', 'Driver ID': userID});

      // Fetch the updated booking details after the update
      var updatedBookingSnapshot = await _db.collection("Bookings").doc(docId).get();

      // Add the updated booking to the acceptedBookingList
      if (updatedBookingSnapshot.exists) {
        BookingModel updatedBooking = BookingModel.fromSnapshot(updatedBookingSnapshot.data()!);
        addAcceptedBooking(updatedBooking);
      }
    }
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
      _acceptedBookingList = serializedList
          .map((jsonString) => BookingModel.fromSnapshot(json.decode(jsonString)))
          .toList();
    }
  }

  // Function to save accepted bookings to shared preferences
  Future<void> saveAcceptedBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> serializedList =
    _acceptedBookingList.map((booking) => json.encode(booking.toJson())).toList();

    prefs.setStringList('acceptedBookings', serializedList);
  }

  // Function to add a new accepted booking
  void addAcceptedBooking(BookingModel newBooking) {
    _acceptedBookingList.add(newBooking);
    saveAcceptedBookings();
  }

  // Function to remove a completed booking
  void removeCompletedBooking(String bookingNumber) {
    _acceptedBookingList.removeWhere((booking) => booking.bookingNumber == bookingNumber);
    saveAcceptedBookings();
  }

  // Method to remove pending booking from list once its accepted
  void removePendingBookings(String bookingNumber) {
    // Listen to real-time updates on the booking document
    FirebaseFirestore.instance.collection("Bookings").doc(bookingNumber).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        // Check if the booking status is now 'active'
        if (snapshot.data()?['Status'] == 'active') {
          // Booking has been accepted by another rider, remove it from the UI
            requestHistory.removeWhere((booking) => booking.bookingNumber == bookingNumber);
            update();
        }
      }
    });
  }


}