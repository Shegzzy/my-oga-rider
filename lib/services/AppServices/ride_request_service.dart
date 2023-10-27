
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/ride_request_model.dart';

class RideRequestServices {
  //String collection = "requests";
  FirebaseFirestore _db = FirebaseFirestore.instance;

  void updateRequest(Map<String, dynamic> values) {
    _db.collection("Bookings").doc(values['id']).update(values);
  }

  Stream<QuerySnapshot> requestStream({String? id}) {
    CollectionReference reference = _db.collection("Bookings");
    return reference.snapshots();
  }

  Future<RequestModelFirebase> getRequestById(String id) =>
    _db.collection("Bookings").doc(id).get().then((doc) {
      return RequestModelFirebase.fromSnapshot(doc);
    });

}
