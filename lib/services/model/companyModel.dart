//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String? id;
  final String? name;
  final String? email;
  final String? location;
  final String? phoneNo;
  final String? address;
  final String? profilePic;
  final String? date;

  const CompanyModel({
    this.id,
    this.name,
    this.email,
    this.location,
    this.phoneNo,
    this.address,
    this.profilePic,
    this.date,
  });

  toJson() {
    return {
      "company": name,
      "email": email,
      "location": location,
      "phone": phoneNo,
      "address": address,
      "Profile Photo": profilePic,
      "date": date,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory CompanyModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return CompanyModel(
      id: document.id,
      email: data["email"],
      location: data["location"],
      name: data["company"],
      phoneNo: data["phone"],
      address: data["address"],
      profilePic: data["Profile Photo"],
      date: data["date"],
    );
  }

}