import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/ratings_tab.dart';
import 'package:provider/provider.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../../repo/auth_repo.dart';
import '../../../repo/user_repo.dart';
import '../../../widgets/profile_menu_widget.dart';
import '../../controller/profile_photo_controller.dart';
import '../../model/usermodel.dart';
import '../../notificationService.dart';
import '../Profile_Screen/profile_information.dart';
import '../Profile_Screen/update_profile_screen.dart';
import '../Settings/settings_screen.dart';


class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {

  final AuthenticationRepository _authController = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  UserModel? _userModel;
  
  @override
  void initState() {
    super.initState();
      _userRepo.getDriverData().listen((event) {
        if(mounted) {
          setState(() {
            _userModel = event;
          });
        }
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ProfilePhotoController(),
        child: Consumer<ProfilePhotoController>(
          builder: (context, provider, child){
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                        Column(
                            children: [
                              Stack(
                                children: [
                                  SizedBox(
                                    width: 120.0,
                                    height: 120.0,
                                    child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(100),
                                        child: _userModel?.profilePic == null
                                            ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                            : Image(
                                          image: NetworkImage(_userModel!.profilePic ?? ""),
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context,
                                              child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                                child:
                                                CircularProgressIndicator());
                                          },
                                          errorBuilder:
                                              (context, object, stack) {
                                            return const Icon(
                                              Icons.person,
                                              color: Colors.blueGrey,
                                            );
                                          },
                                        )),
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
                                            LineAwesomeIcons.pencil_alt_solid,
                                            size: 20.0,
                                            color: Colors.black)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Text(_userModel?.fullname ?? "",
                                  style:
                                  Theme.of(context).textTheme.headlineMedium),
                              Text(_userModel?.email ?? "",
                                  style:
                                  Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 10.0),
                              SizedBox(
                                width: 200.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => const UpdateProfileScreen());
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: PButtonColor,
                                      side: BorderSide.none,
                                      shape: const StadiumBorder()),
                                  child: const Text(moEditProfile,
                                      style: TextStyle(color: PWhiteColor)),
                                ),
                              ),
                            ],
                          ),


                  const SizedBox(height: 20.0),
                  const Divider(),
                  const SizedBox(height: 10.0),
                  //Menu
                  ProfileMenuWidget(
                      title: moMenu1,
                      icon: LineAwesomeIcons.user,
                      onPress: () {
                        Get.to(() => const ProfileInformation());
                      }),
                  ProfileMenuWidget(
                      title: moMenu2,
                      icon: LineAwesomeIcons.receipt_solid,
                      onPress: () {
                        Get.to(() => const RatingTabPage());
                      }),
                  ProfileMenuWidget(
                      title: moMenu3,
                      icon: LineAwesomeIcons.cog_solid,
                      onPress: () {
                        Get.to(() => const SettingScreen());
                      }
                  ),
                  const Divider(),
                  const SizedBox(height: 10.0),
                  ProfileMenuWidget(
                    title: moMenu4,
                    icon: LineAwesomeIcons.sign_out_alt_solid,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () async {
                      await _authController.logout();
                      // NotificationService().showNotification(title: 'My Oga', body: 'Logged out successfully!');
                    },
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
