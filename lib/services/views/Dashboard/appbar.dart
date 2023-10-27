import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/bookings_tab.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/profile_tab.dart';

//import '../../../../constants/colors.dart';
//import '../../../../repositories/authentication_repository/authentication_repository.dart';
import '../../../constant/image_string.dart';
import '../Main_Screen/main_screen.dart';
import '../Tab_Pages/home_tab.dart';
//import '../../Profile/profile_screen.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
            children: [
              const UserAccountsDrawerHeader(
                  accountName: Text("John Doe", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),),
                  accountEmail: Text("johndoe@gmail.com", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image(image: AssetImage(moProfilePic),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                decoration: BoxDecoration(
                  color: Colors.purple,
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_filled),
                title: Text("Home"),
                onTap: (){
                  Get.to(()=> MainScreen());
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Profile"),
                onTap: (){
                  Get.to(()=> ProfileTabPage());
                },
              ),

              ListTile(
                leading: Icon(Icons.history_edu_rounded),
                title: Text("My Bookings"),
                onTap: (){
                  Get.to(()=> BookingTabPage());
                },
              ),

              ListTile(
                leading: Icon(Icons.wallet_travel_rounded),
                title: Text("My Earnings"),
                onTap: (){},

              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
                onTap: (){},

              ),

              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: (){},

              ),
            ],
      )
      ,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
  }

