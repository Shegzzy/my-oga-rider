import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../../repo/auth_repo.dart';
import '../../../repo/user_repo.dart';
import '../../model/usermodel.dart';
import '../../notificationService.dart';
import '../Car_Registration/verification_pending.dart';
import '../Tab_Pages/bookings_tab.dart';
import '../Tab_Pages/earnings_tab.dart';
import '../Tab_Pages/home_tab.dart';
import '../Tab_Pages/profile_tab.dart';


class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}



class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _db = FirebaseFirestore.instance;
  int selectedIndex = 0;
  String? _token, _userID;
  late StreamSubscription<UserModel> _riderModelStatusSubscription;
  UserModel? _userModel;
  final _userRepo = Get.put(UserRepository());
  final auth = FirebaseAuth.instance;

  onItemCliked(int index){
    setState(() {
      selectedIndex = index;
      _tabController!.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    NotificationService().requestNotificationPermission();
    NotificationService().firebaseInit(context);
    NotificationService().setUpInteractMessage(context);
    getToken();
    getDriver();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _riderOnHold() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async{
            return false;
          },
          child: AlertDialog(
            title: const Text("Account on Hold"),
            content: const Text(
                "MyOga Rider, your account is currently on hold. Please contact your dispatch company for further instructions"
                    ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Get.put(AuthenticationRepository().logout());
                  // Get.offAll(() => MainScreen());
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getDriver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('token');
    String? savedToken = prefs.getString("token");
    String? riderID = auth.currentUser?.uid;
    _riderModelStatusSubscription = _userRepo.getRiderById(riderID ?? "").listen((event) async {
      if(mounted) {
        setState(() {
          _userModel = event;
        });
      } else {
        return;
      }

      if (_userModel?.isVerified == "Hold"){
        print(_userModel?.isVerified);
        _riderOnHold();
      }
      // else if(_userModel?.token != savedToken){
      //   await Get.put(AuthenticationRepository().logout());
      //   Get.snackbar("Error", "Your account was logged in on another device",
      //       snackPosition: SnackPosition.TOP,
      //       backgroundColor: Colors.white,
      //       colorText: Colors.red);
      // }

    });

    // print(_userModel?.vehicleNumber);
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('token');
    String? savedToken = prefs.getString("token");
    await NotificationService().getDeviceToken().then((token) {
      // if (kDebugMode) {
      //   print(" YOUR TOKEN IS: $token");
      //   print(" YOUR SAVED TOKEN IS: $savedToken");
      // }
      setState(() {
        _token = token;
      });
      if(_token != savedToken){
        updateToken();
      }
    }
    );
  }

  void updateToken () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userID = prefs.getString("UserID");
    print('User ID: $_userID');
    await _db.collection("Drivers").doc(_userID).update({
      "Token": _token
    });
    prefs.setString("token", _token!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          HomeTabPage(),
          EarningTabPage(),
          BookingTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.home_solid),
            label: moHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.wallet_solid),
            label: moEarnings,
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.address_book),
            label: moBookings,
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.user_circle),
            label: moProfile,
          ),
        ],
        unselectedItemColor: moAccentColor,
        selectedItemColor: moPrimaryColor,
        backgroundColor: PButtonColor,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemCliked,
      ),
    );
  }
}
