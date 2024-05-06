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

  void getDriver(){
    String? riderID = FirebaseAuth.instance.currentUser?.uid;
    _riderModelStatusSubscription = _userRepo.getRiderById(riderID ?? "").listen((event) {
      if(mounted) {
        setState(() {
          _userModel = event;
        });
      } else {
        return;
      }


      if (_userModel?.isVerified == "Hold"){
        print(_userModel?.isVerified);
        Get.offAll(() => const VerificaitonPendingScreen());
      }

    });

    // print(_userModel?.vehicleNumber);
  }

  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('token');
    String? savedToken = prefs.getString("token");
    await NotificationService().getDeviceToken().then((token) {
      if (kDebugMode) {
        print(" YOUR TOKEN IS: $token");
        print(" YOUR SAVED TOKEN IS: $savedToken");
      }
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
            icon: Icon(LineAwesomeIcons.home),
            label: moHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(LineAwesomeIcons.wallet),
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
