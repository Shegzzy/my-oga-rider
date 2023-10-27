//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String? id;
  final String? name;

  const LocationModel({
    this.id,
    this.name,
  });

  toJson() {
    return {
      "name": name,
    };
  }

  ///Getting User Info Mapping

  /// Map user fetched from Firebase to UserModel

  factory LocationModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return LocationModel(
      id: document.id,
      name: data["name"],
    );
  }

}