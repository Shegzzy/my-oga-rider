import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/views/Profile_Screen/update_profile_screen.dart';

import 'package:provider/provider.dart';
import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../controller/profile_controller.dart';
import '../../controller/profile_photo_controller.dart';

import '../../model/usermodel.dart';
import '../Forget_Password/Change Password/change_password.dart';

class ProfileInformation extends StatelessWidget {
  const ProfileInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final controller = Get.put(ProfileController());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title:
        Text(moProfileInfo, style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const UpdateProfileScreen());
              },
              icon: const Icon(LineAwesomeIcons.edit)),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: ChangeNotifierProvider(
          create: (_) => ProfilePhotoController(),
          child: Consumer<ProfilePhotoController>(
              builder: (context, provider, child){
                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: FutureBuilder(
                        future: controller.getUserData(),
                        builder: (context,  snapshot) {
                          if (snapshot.connectionState == ConnectionState.done){
                            if (snapshot.hasData){
                              UserModel userData = snapshot.data as UserModel;
                              return Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Stack(
                                    children: [
                                      SizedBox(
                                        width: 120.0,
                                        height: 120.0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(100),
                                          child: userData.profilePic == null
                                              ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                              : Image(image: NetworkImage(userData.profilePic!),
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress){
                                              if(loadingProgress == null) return child;
                                              return const Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, object, stack){
                                              return const Icon(Icons.person_2_rounded, color: Colors.grey, size: 28,);
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(moProfilePics, style: Theme.of(context).textTheme.headlineMedium),
                                  const SizedBox(height: 15.0),
                                  const Divider(),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(moProfileInfoHead, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileName, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text(userData.fullname == null ? "Complete profile" : userData.fullname!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileEmail, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text(userData.email == null ? "Complete profile" : userData.email!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfilePhone, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text(userData.phoneNo == null ? "Complete profile" : userData.phoneNo!,  style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileAddress, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.address == null ? "Complete profile" : userData.address!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileState, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.userState == null ? "Complete profile" : userData.userState!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileDOB, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.dateOfBirth == null ? "Complete profile" : userData.dateOfBirth!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileGender, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.gender == null ? "Complete profile" : userData.gender!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moProfileCompany, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.userCompany == null ? "Complete profile" : userData.userCompany!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 30.0,),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(moProfileCarInfoHead, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleNum, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text(userData.vehicleNumber == null ? "Contact Support" : userData.vehicleNumber!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleMake, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.vehicleMake == null ? "Complete profile" : userData.vehicleMake!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleType, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.vehicleType == null ? "Complete profile" : userData.vehicleType!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleModel, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.vehicleModel == null ? "Complete profile" : userData.vehicleModel!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleYear, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.vehicleYear == null ? "Complete profile" : userData.vehicleYear!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(moVehicleColor, style: Theme.of(context).textTheme.headlineSmall,),
                                          Text( userData.vehicleColor == null ? "Complete profile" : userData.vehicleColor!, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 30.0,),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(moDocuments, style: Theme.of(context).textTheme.bodyLarge,),
                                        ],
                                      ),
                                      const SizedBox(height: 20.0,),
                                      const Divider(),
                                      SizedBox(
                                        width: Get.width,
                                        height: 150,
                                        child: userData.userDocuments == null
                                            ? const Center(
                                          child: Text("No image found"),
                                        )
                                            : ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: userData.userDocuments?.length,
                                          itemBuilder: (ctx, i){
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.black),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Image(
                                                image: NetworkImage(userData.userDocuments![i]),
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
                                                    Icons.document_scanner,
                                                    color: Colors.red,
                                                  );
                                                },
                                              ));
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 50.0,),
                                      const Divider(),
                                      TextButton(onPressed: (){
                                        Get.to(()=> const ChangePasswordScreen());
                                      },
                                          child: const Text("Change Password", style: TextStyle(color: moAccentColor,fontSize: 20,
                                              fontWeight: FontWeight.w400),
                                          )
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }
                            else if (snapshot.hasError) {
                              return Center(
                                child: Text("Profile incomplete: click here to complete profile"),
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
                        }
                    ),
                  ),
                );
              }
          )
      ),
    );
  }
}
