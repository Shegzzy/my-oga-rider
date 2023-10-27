import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestModel {
  static const ID = "ID";
  static const DRIVER_ID = "Driver ID";
  static const PAYMENT_METHOD = "Payment Method";
  static const ADD_DETAILS = "Additional Details";
  static const DATE_CREATED = "Date Created";
  static const CUSTOMER_PHONE = "Customer Phone";
  static const CUSTOMER_NAME = "Customer Name";
  static const CUSTOMER_ID = "Customer ID";
  static const PICKUP = "PickUp Address";
  static const DROPOFF = "DropOff Address";
  static const PICKUP_LAT = "PickUp Lat";
  static const PICKUP_LNG = "PickUp Lng";
  static const DROPOFF_LAT = "DropOff Lat";
  static const DROPOFF_LNG = "DropOff Lng";
  static const DISTANCE_TEXT = "Distance";
  static const STATUS = "Status";
  static const AMOUNT = "Amount";
  static const BOOKING_NUMBER = "Booking Number";
  static const DELIVERY_MODE = "Delivery Mode";
  static const RIDE_TYPE = "Ride Type";
  static const PACKAGE_TYPE = "Package Type";

  String? _id;
  String? _customer_name;
  String? _customer_id;
  String? _customer_phone;
  String? _driver_id;
  String? _payment_method;
  String? _additional_details;
  String? _created_at;
  String? _pickup_address;
  String? _dropOff_address;
  String? _pickUp_latitude;
  String? _pickUp_longitude;
  String? _dropOff_latitude;
  String? _dropOff_longitude;
  String? _distance;
  String? _status;
  String? _amount;
  String? _bookingNumber;
  String? _deliveryMode;
  String? _rideType;
  String? _packageType;

  String? get id => _id;
  String? get driverId => _driver_id;
  String? get customerName => _customer_name;
  String? get customerId => _customer_id;
  String? get customerPhone => _customer_phone;
  String? get paymentMethod => _payment_method;
  String? get addDetails => _additional_details;
  String? get createdAt => _created_at;
  String? get pickUpAddy => _pickup_address;
  String? get dropOffAddy => _dropOff_address;
  String? get pickUpLat => _pickUp_latitude;
  String? get pickUpLong => _pickUp_longitude;
  String? get dropOffLat => _dropOff_latitude;
  String? get dropOffLong => _dropOff_longitude;
  String? get distance => _distance;
  String? get status => _status;
  String? get amount => _amount;
  String? get bookingNumber => _bookingNumber;
  String? get deliveryMode => _deliveryMode;
  String? get packageType => _packageType;
  String? get rideType => _rideType;


  RideRequestModel.fromMap(Map data) {
    _id = data[ID];
    _driver_id = data[DRIVER_ID];
    _customer_name = data[CUSTOMER_NAME];
    _customer_id = data[CUSTOMER_ID];
    _customer_phone = data[CUSTOMER_PHONE];
    _additional_details = data[ADD_DETAILS];
    _payment_method = data[PAYMENT_METHOD];
    _created_at = data[DATE_CREATED];
    _pickup_address = data[PICKUP];
    _pickUp_latitude = data[PICKUP_LAT];
    _pickUp_longitude = data[PICKUP_LNG];
    _dropOff_address = data[DROPOFF];
    _dropOff_latitude = data[DROPOFF_LAT];
    _dropOff_longitude = data[DROPOFF_LNG];
    _distance = data[DISTANCE_TEXT];
    _status = data[STATUS];
    _amount = data[AMOUNT];
    _bookingNumber = data[BOOKING_NUMBER];
    _deliveryMode = data[DELIVERY_MODE];
    _packageType = data[PACKAGE_TYPE];
    _rideType = data[RIDE_TYPE];
  }
}



class RequestModelFirebase {
  static const ID = "ID";
  static const DRIVER_ID = "Driver ID";
  static const PAYMENT_METHOD = "Payment Method";
  static const ADD_DETAILS = "Additional Details";
  static const DATE_CREATED = "Date Created";
  static const CUSTOMER_PHONE = "Customer Phone";
  static const CUSTOMER_NAME = "Customer Name";
  static const CUSTOMER_ID = "Customer ID";
  static const PICKUP = "PickUp Address";
  static const DROPOFF = "DropOff Address";
  static const PICKUP_LAT = "PickUp Lat";
  static const PICKUP_LNG = "PickUp Lng";
  static const DROPOFF_LAT = "DropOff Lat";
  static const DROPOFF_LNG = "DropOff Lng";
  static const DISTANCE_TEXT = "Distance";
  static const STATUS = "Status";
  static const AMOUNT = "Amount";
  static const BOOKING_NUMBER = "Booking Number";
  static const DELIVERY_MODE = "Delivery Mode";
  static const RIDE_TYPE = "Ride Type";
  static const PACKAGE_TYPE = "Package Type";

  String? _id;
  String? _customer_name;
  String? _customer_id;
  String? _customer_phone;
  String? _driver_id;
  String? _payment_method;
  String? _additional_details;
  String? _created_at;
  String? _pickup_address;
  String? _dropOff_address;
  String? _pickUp_latitude;
  String? _pickUp_longitude;
  String? _dropOff_latitude;
  String? _dropOff_longitude;
  String? _distance;
  String? _status;
  String? _amount;
  String? _bookingNumber;
  String? _deliveryMode;
  String? _rideType;
  String? _packageType;

  String? get id => _id;
  String? get driverId => _driver_id;
  String? get customerName => _customer_name;
  String? get customerId => _customer_id;
  String? get customerPhone => _customer_phone;
  String? get paymentMethod => _payment_method;
  String? get addDetails => _additional_details;
  String? get createdAt => _created_at;
  String? get pickUpAddy => _pickup_address;
  String? get dropOffAddy => _dropOff_address;
  String? get pickUpLat => _pickUp_latitude;
  String? get pickUpLong => _pickUp_longitude;
  String? get dropOffLat => _dropOff_latitude;
  String? get dropOffLong => _dropOff_longitude;
  String? get distance => _distance;
  String? get status => _status;
  String? get amount => _amount;
  String? get bookingNumber => _bookingNumber;
  String? get deliveryMode => _deliveryMode;
  String? get packageType => _packageType;
  String? get rideType => _rideType;

  RequestModelFirebase.fromSnapshot(DocumentSnapshot snapshot) {
    _id = (snapshot.data() as dynamic)[ID];
    _driver_id = (snapshot.data() as dynamic)[DRIVER_ID];
    _customer_name = (snapshot.data() as dynamic)[CUSTOMER_NAME];
    _customer_id = (snapshot.data() as dynamic)[CUSTOMER_ID];
    _customer_phone = (snapshot.data() as dynamic)[CUSTOMER_PHONE];
    _additional_details = (snapshot.data() as dynamic)[ADD_DETAILS];
    _payment_method = (snapshot.data() as dynamic)[PAYMENT_METHOD];
    _created_at = (snapshot.data() as dynamic)[DATE_CREATED];
    _pickup_address = (snapshot.data() as dynamic)[PICKUP];
    _pickUp_latitude = (snapshot.data() as dynamic)[PICKUP_LAT];
    _pickUp_longitude = (snapshot.data() as dynamic)[PICKUP_LNG];
    _dropOff_address = (snapshot.data() as dynamic)[DROPOFF];
    _dropOff_latitude = (snapshot.data() as dynamic)[DROPOFF_LAT];
    _dropOff_longitude = (snapshot.data() as dynamic)[DROPOFF_LNG];
    _distance = (snapshot.data() as dynamic)[DISTANCE_TEXT];
    _status = (snapshot.data() as dynamic)[STATUS];
    _amount = (snapshot.data() as dynamic)[AMOUNT];
    _bookingNumber = (snapshot.data() as dynamic)[BOOKING_NUMBER];
    _deliveryMode = (snapshot.data() as dynamic)[DELIVERY_MODE];
    _packageType = (snapshot.data() as dynamic)[PACKAGE_TYPE];
    _rideType = (snapshot.data() as dynamic)[RIDE_TYPE];
  }

}
