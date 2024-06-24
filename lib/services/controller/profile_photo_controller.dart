import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/colors.dart';


class ProfilePhotoController with ChangeNotifier {


  final _ref = FirebaseFirestore.instance.collection("Drivers");
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage
      .instance;

  final picker = ImagePicker();

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  XFile? _image;

  XFile? get image => _image;

  Future pickGalleryImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
      notifyListeners();
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
      notifyListeners();
    }
  }

  void pickImage(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 120.0,
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(
                      LineAwesomeIcons.camera_solid, color: PButtonColor,),
                    title: const Text("Camera"),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: const Icon(
                      LineAwesomeIcons.image, color: PButtonColor,),
                    title: const Text("Gallery"),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  void uploadImage() async {
    setLoading(true);
    final user = FirebaseAuth.instance.currentUser!;
    final phone = user.phoneNumber;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;

    if(phone == null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/profilepic${userID}');
      firebase_storage.UploadTask uploadTask = ref.putFile(
          File(image!.path).absolute);
      await Future.value(uploadTask);

      final newUrl = await ref.getDownloadURL();
      _ref.doc(userID).update({"Profile Photo": newUrl}).then((value){
        Get.snackbar("Success", "Profile Photo Updated",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green
        );
        setLoading(false);
        _image = null;
      }).onError((error, stackTrace) {
        setLoading(false);
        Get.snackbar("Error", error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red
        );
      });
    }
    else {

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref('/profilepic${userID}');
      firebase_storage.UploadTask uploadTask = ref.putFile(
          File(image!.path).absolute);
      await Future.value(uploadTask);

      final newUrl = await ref.getDownloadURL();
      _ref.doc(userID).update({"Profile Photo": newUrl}).then((value){
        Get.snackbar("Success", "Profile Photo Updated",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green
        );
        setLoading(false);
        _image = null;
      }).onError((error, stackTrace) {
        setLoading(false);
        Get.snackbar("Error", error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red
        );
      });
    }
  }
}