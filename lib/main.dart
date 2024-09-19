import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_oga_rider/repo/auth_repo.dart';
import 'package:my_oga_rider/repo/user_repo.dart';
import 'package:my_oga_rider/services/AppServices/app_provider.dart';
import 'package:my_oga_rider/services/controller/getx_switch_state.dart';
import 'package:my_oga_rider/services/controller/request_controller.dart';
import 'package:my_oga_rider/services/views/Main_Screen/main_screen.dart';
import 'package:my_oga_rider/services/views/Permission_info_screen/permission_alert_screen.dart';
import 'package:my_oga_rider/services/views/Welcome_Screen/welcome_screen.dart';
import 'package:my_oga_rider/utils/theme/theme.dart';
import 'package:my_oga_rider/widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant/colors.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print(message.notification?.title.toString());
    print(message.notification?.body.toString());
    print(message.data.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  runApp(MyApp());
  _init();
}

AuthenticationRepository authenticationRepository = Get.put(AuthenticationRepository());

_checkUserType() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  final iD = prefs.getString("aUserID");
  if (iD == null) {
    final iDd = prefs.getString("UserID");
    final userDoc = await FirebaseFirestore.instance.collection("Drivers").doc(
        iDd).get();
    if (userDoc.exists) {
      if(Platform.isAndroid){
        if(permission == LocationPermission.denied){
          Get.to(() => const PermissionScreen());
        }else{
          Get.offAll(() => MainScreen());
        }
      }else{
        Get.offAll(() => MainScreen());
      }
    } else {
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      await Get.put(AuthenticationRepository().logout());
      Get.offAll(() => const WelcomeScreen());
    }
  } else {
    final userDoc = await FirebaseFirestore.instance.collection("Drivers")
        .doc(iD)
        .get();
    if (userDoc.exists) {
      Get.offAll(() => MainScreen());
    } else {
      Get.snackbar("Error", "No Access",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.red);
      await Get.put(AuthenticationRepository().logout());
      Get.offAll(() => const WelcomeScreen());
    }
  }
}

_init() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("UserID");
  if (token != null) {
    authenticationRepository.checkVerification();
  }
  else {
    Get.to(() => const WelcomeScreen());
  }
}




class MyApp extends StatelessWidget {
  final GetXSwitchState getXSwitchState = Get.put(GetXSwitchState());

  MyApp({super.key});

  final FirestoreService _db = Get.put(FirestoreService());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FirestoreService>(builder: (_) {
      // _db.loadPendingBookings();
      return GetBuilder<GetXSwitchState>(builder: (_) {
        return MultiProvider(
          providers: [
            StreamProvider(
              create: (BuildContext context) => _db.getBookingData(),
              initialData: Loading(),
              catchError: (context, e) {
                //or pop a dialogue...whatever.
                return null;
              },
            ),
            ChangeNotifierProvider<AppStateProvider>.value(
              value: AppStateProvider(),),
          ],
          child: GetMaterialApp(
            theme: getXSwitchState.isDarkMode
                ? MyOgaTheme.darkTheme
                : MyOgaTheme
                .lightTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.leftToRightWithFade,
            transitionDuration: const Duration(milliseconds: 200),
            home: const Scaffold(body: Center(child: CircularProgressIndicator(
              color: moAccentColor, backgroundColor: Colors.white,),)),
          ),
        );
      });
    });
  }
}

