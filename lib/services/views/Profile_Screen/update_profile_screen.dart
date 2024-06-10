import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/repo/user_repo.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../controller/profile_controller.dart';
import '../../controller/profile_photo_controller.dart';
import '../../model/usermodel.dart';
import '../Tab_Pages/profile_tab.dart';
import '../Welcome_Screen/welcome_screen.dart';


class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late String newDate;
  String? dOB;
  String? imageSource;
  final _db = FirebaseFirestore.instance;
  ProfileController controller = Get.put(ProfileController());
  UserRepository userRepositoryController = Get.put(UserRepository());
  var isUploading = false.obs;
  bool _isDataLoaded = false;


  @override
  void initState() {
    super.initState();
    if (!_isDataLoaded) {
      _isDataLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _getUser();
        controllers();
      });
    }
  }

  Future<UserModel?> _getUser() async {
    return await controller.getUserById();
  }

  late TextEditingController fullNameController;
  // late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController genderController;
  late TextEditingController dobController;
  late TextEditingController picController;

  controllers() {
    fullNameController = TextEditingController(
        text: userRepositoryController.userModel!.fullname!);
    // emailController =
    //     TextEditingController(text: userRepositoryController.userModel!.email!);
    phoneController = TextEditingController(
        text: userRepositoryController.userModel!.phoneNo!);
    addressController = TextEditingController(
        text: userRepositoryController.userModel!.address!);
    genderController = TextEditingController(
        text: userRepositoryController.userModel!.gender!);
    dobController = TextEditingController(
        text: userRepositoryController.userModel!.dateOfBirth!);
    picController = TextEditingController(
        text: userRepositoryController.userModel?.profilePic);
  }

  final picker = ImagePicker();

  XFile? _image;

  XFile? get image => _image;

  Future pickGalleryImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      setState(() {
        imageSource = _image?.path;
      });
      // print("Image source ${picController.text}" );
    }
  }

  Future pickCameraImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 100);

    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      setState(() {
        imageSource = _image?.path;
      });
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
                      LineAwesomeIcons.camera, color: PButtonColor,),
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

  Future<void> uploadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/profilepic${userID}');

    firebase_storage.UploadTask uploadTask = ref.putFile(
        File(image!.path).absolute);
    await Future.value(uploadTask);

    final newUrl = await ref.getDownloadURL();
    _db.collection("Drivers").doc(userID).update({"Profile Photo": newUrl}).then((value){
      Get.snackbar("Success", "Profile Photo Updated",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green
      );
      _image = null;
    }).onError((error, stackTrace) {
      Get.snackbar("Error", error.toString(),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red
      );
      });
    }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(LineAwesomeIcons.angle_left)),
          title:
          Text(moEditProfile, style: Theme
              .of(context)
              .textTheme
              .headlineMedium),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        body: GetBuilder<UserRepository>(builder: (userRepo) {
          return userRepo.profileLoading ?
          const Center(child: CircularProgressIndicator()) :
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30.0),

              ///Future Builder
              child: Column(

                ///Wrap this widget with future builder
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: 120.0,
                          height: 120.0,
                          child: imageSource != null ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                100),
                            child: Image.file(File(imageSource!)),
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(
                                100),
                            child: picController.text.isEmpty
                                ? const Icon(
                              LineAwesomeIcons.user_circle,
                              size: 35,)
                                : Image(image: NetworkImage(
                                picController.text),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child,
                                  loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, object,
                                  stack) {
                                return const Icon(
                                  Icons.person,
                                  color: Colors.blueGrey,);
                              },
                            ),
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            pickImage(context);
                          },
                          child: Container(
                              width: 35.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(100),
                                  color: moSecondarColor),
                              child: const Icon(
                                LineAwesomeIcons.camera,
                                size: 20.0,
                                color: Colors.black,)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),
                    Form(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: fullNameController,
                              decoration: const InputDecoration(
                                  label: Text(moFullName),
                                  prefixIcon: Icon(
                                      LineAwesomeIcons.user)),
                            ),
                            // const SizedBox(height: 20.0),
                            // TextFormField(
                            //   controller: emailController,
                            //   decoration: const InputDecoration(
                            //       label: Text(moEmail),
                            //       prefixIcon:
                            //       Icon(
                            //           LineAwesomeIcons.envelope)),
                            // ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                  label: Text(moPhone),
                                  prefixIcon: Icon(
                                      LineAwesomeIcons.phone)),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(
                                  label: Text(moAddress),
                                  prefixIcon:
                                  Icon(LineAwesomeIcons
                                      .address_card)),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              controller: genderController,
                              decoration: const InputDecoration(
                                  label: Text("Gender"),
                                  prefixIcon:
                                  Icon(LineAwesomeIcons
                                      .user_circle)),
                            ),
                            const SizedBox(height: 20.0),
                            TextFormField(
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1970),
                                  lastDate: DateTime(2101),
                                );
                                if (kDebugMode) {
                                  print(pickedDate);
                                }
                                if (pickedDate != null) {
                                  setState(() {
                                    dobController.text = formatDate(
                                        pickedDate, [yyyy, '-', mm, '-', dd])
                                        .toString();
                                  });
                                }
                                if (kDebugMode) {
                                  print(dOB);
                                }
                              },
                              controller: dobController,
                              decoration: const InputDecoration(
                                  label: Text("Date of Birth"),
                                  prefixIcon:
                                  Icon(
                                      LineAwesomeIcons.calendar)),
                            ),
                            const SizedBox(height: 20.0),
                            SizedBox(
                                width: double.infinity,
                                child: Obx(() =>
                                isUploading.value
                                    ? const Center(
                                    child: CircularProgressIndicator())
                                    : ElevatedButton(
                                  onPressed: isUploading.value
                                      ? null : () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    final String? iD = prefs.getString("UserID");
                                    isUploading(true);
                                    if(imageSource != null) {
                                      await uploadImage();
                                    }
                                    await _db.collection("Drivers").doc(iD).update({
                                      "FullName": fullNameController.text.trim(),
                                      // "Email": emailController.text.trim(),
                                      "Phone": phoneController.text.trim(),
                                      "Address": addressController.text.trim(),
                                      "Gender": genderController.text.trim(),
                                      "Date of Birth": dobController.text.trim(),
                                    }).whenComplete(() =>
                                        Get.snackbar(
                                            "Success",
                                            "Your account have been updated.",
                                            snackPosition: SnackPosition.TOP,
                                            backgroundColor: Colors.green
                                                .withOpacity(0.1),
                                            colorText: Colors.green),
                                    ).catchError((error, stackTrace) {
                                      Get.snackbar("Error",
                                          "Something went wrong. Try again.",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.redAccent
                                              .withOpacity(0.1),
                                          colorText: Colors.red);
                                    });
                                    isUploading(false);
                                    Get.offAll(() => const ProfileTabPage());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: PButtonColor,
                                      side: BorderSide.none,
                                      shape: const StadiumBorder()),
                                  child: const Text(moUpdate,
                                      style: TextStyle(
                                          color: PWhiteColor)),
                                ),
                                )
                            ),
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text.rich(TextSpan(
                                    text: moJoined,
                                    style: const TextStyle(
                                        fontSize: 12),
                                    children: [

                                      TextSpan(
                                          text: MyOgaFormatter.dateFormatter(
                                              DateTime.parse(
                                                  userRepositoryController
                                                      .userModel!
                                                      .dateCreated!)),
                                          style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold,
                                              fontSize: 12))
                                    ])),
                                ElevatedButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.currentUser
                                          ?.delete();
                                      Get.offAll(() => const WelcomeScreen());
                                    },
                                    style: ElevatedButton
                                        .styleFrom(
                                        backgroundColor:
                                        Colors.redAccent
                                            .withOpacity(0.1),
                                        elevation: 0,
                                        foregroundColor: Colors
                                            .red,
                                        shape: const StadiumBorder(),
                                        side: BorderSide.none),
                                    child: const Text(moDelete))
                              ],
                            )
                          ],
                        ))
                  ]),
            ),
          );
        })
    );
  }
}
