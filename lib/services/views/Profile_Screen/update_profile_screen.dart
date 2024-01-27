import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late Future userFuture;
  late String newDate;
  String? dOB;
  final _db = FirebaseFirestore.instance;
  ProfileController controller = Get.put(ProfileController());
  var isUploading = false.obs;

  @override
  void initState() {
    super.initState();
    userFuture = _getUser();
  }

  _getUser() async {
    return await controller.getUserById();
  }


  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
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
        body: ChangeNotifierProvider(
          create: (_) => ProfilePhotoController(),
          child: Consumer<ProfilePhotoController>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(30.0),

                    ///Future Builder
                    child: FutureBuilder(
                      future: userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            UserModel userData = snapshot.data as UserModel;

                            //Controllers
                            dOB = userData.dateOfBirth;
                            final email = TextEditingController(
                                text: userData.email);
                            final fullname = TextEditingController(
                                text: userData.fullname);
                            final phone = TextEditingController(
                                text: userData.phoneNo);
                            final address = TextEditingController(
                                text: userData.address);
                            final gender = TextEditingController(
                                text: userData.gender);
                            TextEditingController dateOfBirth = TextEditingController(
                                text: userData.dateOfBirth);
                            final profilePic = TextEditingController(
                                text: userData.profilePic);

                            return Column(

                              ///Wrap this widget with future builder
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        width: 120.0,
                                        height: 120.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              100),
                                          child: userData.profilePic == null
                                              ? const Icon(
                                            LineAwesomeIcons.user_circle,
                                            size: 35,)
                                              : Image(image: NetworkImage(
                                              userData.profilePic!),
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
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          provider.pickImage(context);
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
                                            controller: fullname,
                                            decoration: const InputDecoration(
                                                label: Text(moFullName),
                                                prefixIcon: Icon(
                                                    LineAwesomeIcons.user)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: email,
                                            decoration: const InputDecoration(
                                                label: Text(moEmail),
                                                prefixIcon:
                                                Icon(
                                                    LineAwesomeIcons.envelope)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: phone,
                                            decoration: const InputDecoration(
                                                label: Text(moPhone),
                                                prefixIcon: Icon(
                                                    LineAwesomeIcons.phone)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: address,
                                            decoration: const InputDecoration(
                                                label: Text(moAddress),
                                                prefixIcon:
                                                Icon(LineAwesomeIcons
                                                    .address_card)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          TextFormField(
                                            controller: gender,
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
                                              if(pickedDate != null){
                                                setState(() {
                                                  dOB = formatDate(pickedDate, [yyyy, '-', mm, '-', dd]).toString();
                                                });
                                              }
                                              if (kDebugMode) {
                                                print(dOB);
                                              }
                                            },
                                            controller: dateOfBirth,
                                            decoration: const InputDecoration(
                                                label: Text("Date of Birth"),
                                                prefixIcon:
                                                Icon(
                                                    LineAwesomeIcons.calendar)),
                                          ),
                                          const SizedBox(height: 20.0),
                                          SizedBox(
                                            width: double.infinity,
                                            child: Obx(()=> isUploading.value? const Center(child: CircularProgressIndicator()): ElevatedButton(
                                              onPressed: () async {
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                final String? iD = prefs.getString("UserID");
                                                isUploading(true);
                                                await _db.collection("Drivers").doc(iD).update({
                                                  "FullName": fullname.text.trim(),
                                                  "Email": email.text.trim(),
                                                  "Phone": phone.text.trim(),
                                                  "Address": address.text.trim(),
                                                  "Profile Photo": profilePic.text.trim(),
                                                  "Gender": gender.text.trim(),
                                                  "Date of Birth": dateOfBirth.text.trim(),
                                                }).whenComplete(() =>
                                                    Get.snackbar(
                                                        "Success", "Your account have been updated.",
                                                        snackPosition: SnackPosition.TOP,
                                                        backgroundColor: Colors.green.withOpacity(0.1),
                                                        colorText: Colors.green),
                                                ).catchError((error, stackTrace) {
                                                  Get.snackbar("Error", "Something went wrong. Try again.",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Colors.redAccent.withOpacity(0.1),
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
                                                        text: MyOgaFormatter.dateFormatter(DateTime.parse(userData.dateCreated!)),
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            fontSize: 12))
                                                  ])),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    FirebaseAuth.instance.currentUser?.delete();
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
                                ]);
                          }
                          else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          }
                          else {
                            return const Center(
                              child: Text("Something went wrong"),
                            );
                          }
                        }
                        else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                );
              }
          ),
        )
    );
  }
}
