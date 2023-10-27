//Creating User Model

import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String? id;
  final String? name;

  const VehicleModel({
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

  factory VehicleModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document)
  {
    final data = document.data()!;
    return VehicleModel(
      id: document.id,
      name: data["name"],
    );
  }

}