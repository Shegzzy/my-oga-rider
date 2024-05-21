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

  var acceptedRequests = <Map<String, dynamic>>[].obs;



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
        // addAcceptedBooking(updatedBooking);

        Map<String, dynamic> newRequest = {
          'request_id': updatedBooking.bookingNumber,
          'type': updatedBooking.deliveryMode,
          'status': updatedBooking.status,
        };
        await acceptRequest(newRequest);
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

  // New function to add a new accepted booking
  Future<void> acceptRequest(Map<String, dynamic> request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final riderId = prefs.getString("UserID")!;
    await _db
        .collection('Drivers')
        .doc(riderId)
        .collection('accepted_bookings')
        .doc(request['request_id'])
        .set(request);
  }

  // function to fetch accepted requests
  Future<void> fetchAcceptedRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final riderId = prefs.getString("UserID")!;

    FirebaseFirestore.instance
        .collection('Drivers')
        .doc(riderId)
        .collection('accepted_bookings')
        .snapshots()
        .listen((snapshot) {
      acceptedRequests.value = snapshot.docs
          .map((doc) => {
        'request_id': doc.id,
        'type': doc['type'],
        'status': doc['status'],
      }).toList();
      print(acceptedRequests);
    });
  }

  // function to delete completed booking or canceled booking
  Future<void> completedOrDeletedRequest(String requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final riderId = prefs.getString("UserID")!;

    await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(riderId)
        .collection('accepted_bookings')
        .doc(requestId)
        .delete();
  }


  // Function to add a new accepted booking
  void addAcceptedBooking(BookingModel newBooking) {
    _acceptedBookingList.add(newBooking);
    update();
    saveAcceptedBookings();
  }

  // Function to remove a completed booking
  void removeCompletedBooking(String bookingNumber) {
    _acceptedBookingList.removeWhere((booking) => booking.bookingNumber == bookingNumber);
    update();
    saveAcceptedBookings();
  }

  // Function to load pending bookings from shared preferences
  Future<void> loadPendingBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? serializedPendingList = prefs.getStringList('pendingBookings');

    if (serializedPendingList != null) {
      _requestHistory = serializedPendingList
          .map((jsonString) => BookingModel.fromSnapshot(json.decode(jsonString)))
          .toList();
    }
    print('Pending: ${_requestHistory.length}');
  }

  // Function to save pending bookings to shared preferences
  Future<void> savePendingBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> serializedPendingList =
    _requestHistory.map((booking) => json.encode(booking.toJson())).toList();

    prefs.setStringList('pendingBookings', serializedPendingList);
    update();
  }

  // Function to add a new pending booking
  void addPendingBooking(BookingModel newBooking) {
    _requestHistory.add(newBooking);
    savePendingBookings();
    update();
  }

  // Method to remove pending booking from list once its accepted
  void removePendingBookings(String bookingNumber) {
    // Listen to real-time updates on the booking document
    FirebaseFirestore.instance.collection("Bookings").doc(bookingNumber).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()?['Status'] == 'active') {
            _requestHistory.removeWhere((booking) => booking.bookingNumber == bookingNumber);
            update();
            savePendingBookings();
        }
      }
    });
  }

}