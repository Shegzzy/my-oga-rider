import 'package:cloud_firestore/cloud_firestore.dart';

class EarningModel {

  final String? id;
  final String? driver;
  final String? company;
  final String? booking;
  final String? amount;
  final String? customer;
  final String? dateCreated;
  final Timestamp? timeStamp;

  const EarningModel({
    this.id,
    this.driver,
    this.company,
    this.booking,
    this.amount,
    this.customer,
    this.dateCreated,
    this.timeStamp,
  });

  toJson() {
    return {
      "Driver": driver,
      "Company": company,
      "BookingID": booking,
      "Amount": amount,
      "Customer": customer,
      "DateCreated": dateCreated,
      "timeStamp": timeStamp,
    };
  }

  factory EarningModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return EarningModel(
      id: document.id,
      driver: data["Driver"],
      company: data["Company"],
      booking: data["BookingID"],
      amount: data["Amount"],
      customer: data["Customer"],
      dateCreated: data["DateCreated"],
      timeStamp: data["timeStamp"],
    );
  }


}