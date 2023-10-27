//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class BookerModel {
  final String? id;
  final String? fullname;
  final String? email;
  final String? password;
  final String? phoneNo;
  final String? address;
  final String? profilePic;
  final String? gender;
  final String? dateOfBirth;

  const BookerModel({
    this.id,
    this.fullname,
    this.email,
    this.password,
    this.phoneNo,
    this.address,
    this.profilePic,
    this.gender,
    this.dateOfBirth,
  });

  toJson() {
    return {
      "FullName": fullname,
      "Email": email,
      "Password": password,
      "Phone": phoneNo,
      "Address": address,
      "Profile Photo": profilePic,
      "Gender": gender,
      "Date of Birth": dateOfBirth,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory BookerModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return BookerModel(
      id: document.id,
      email: data["Email"],
      password: data["Password"],
      fullname: data["FullName"],
      phoneNo: data["Phone"],
      address: data["Address"],
      profilePic: data["Profile Photo"],
      gender: data["Gender"],
      dateOfBirth: data["Date of Birth"],
    );
  }

}