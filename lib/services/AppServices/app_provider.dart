

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_oga_rider/services/AppServices/ride_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ride_request_model.dart';

enum Show { RIDER, TRIP }

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';

  late SharedPreferences prefs;

  late RideRequestModel rideRequestModel;
  late RequestModelFirebase requestModelFirebase;
  bool hasNewRideRequest = false;

  double distanceFromRider = 0;
  double totalRideDistance = 0;
  late StreamSubscription<QuerySnapshot> requestStream;
  int timeCounter = 0;
  double percentage = 0;
  late Timer periodicTimer;
  RideRequestServices _requestServices = RideRequestServices();
  late Show show;

  listenToRequest({required String? id, required BuildContext context}) async {
//    requestModelFirebase = await _requestServices.getRequestById(id);
    print("======= LISTENING =======");
    requestStream = _requestServices.requestStream().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((doc) {
        if ((doc.doc.data() as dynamic)['ID'] == id) {
          requestModelFirebase = RequestModelFirebase.fromSnapshot(doc.doc);
          notifyListeners();
          switch ((doc.doc.data() as dynamic)['status']) {
            case CANCELLED:
              print("====== CANCELELD");
              break;
            case ACCEPTED:
              print("====== ACCEPTED");
              break;
            case EXPIRED:
              print("====== EXPIRED");
              break;
            default:
              print("==== PEDING");
              break;
          }
        }
      });
    });
  }

  //  Timer counter for driver request
  percentageCounter({required String requestId, required BuildContext context}) {
    notifyListeners();
    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print("====== GOOOO $timeCounter");
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        hasNewRideRequest = false;
        requestStream.cancel();
      }
      notifyListeners();
    });
  }

  acceptRequest({required String requestId, required String driverId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest(
        {"id": requestId, "status": "accepted", "driverId": driverId});
    notifyListeners();
  }

  cancelRequest({required String requestId}) {
    hasNewRideRequest = false;
    _requestServices.updateRequest({"id": requestId, "status": "cancelled"});
    notifyListeners();
  }

}