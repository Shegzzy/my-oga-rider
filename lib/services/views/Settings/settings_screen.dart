import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/views/Settings/about_us_screen.dart';
import 'package:my_oga_rider/services/views/Settings/privacy_policy.dart';
import 'package:my_oga_rider/services/views/Settings/terms_and_condition_screen.dart';
import '../../controller/getx_switch_state.dart';

import '../../../constant/text_strings.dart';


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isSwitched = false;
  final getController = Get.put(GetXSwitchState());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text(moSetting, style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(moPushNotification, style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(width: 30.0,),
                Obx(() => Switch(
                    value: getController.isNotify.value,
                    activeColor: Colors.green,
                    onChanged: (bool newValue){
                      getController.changeNotifyState(newValue);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0,),
            InkWell(
                onTap: (){
                  Get.to(()=> const PrivacyPolicyScreen());
                },
                child: Text(moPrivacy, style: Theme.of(context).textTheme.headlineMedium,)),
            const SizedBox(height: 20.0,),
            InkWell(
                onTap: (){
                  Get.to(()=> const TermsAndConditionScreen());
                },
                child: Text(moTerms, style: Theme.of(context).textTheme.headlineMedium,)),
            const SizedBox(height: 20.0,),
            InkWell(
                onTap: (){
                  Get.to(()=> const AboutUsScreen());
                },
                child: Text(moAbout, style: Theme.of(context).textTheme.headlineMedium,)),
            const SizedBox(height: 20.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode', style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(width: 30.0,),
                Switch(
                  value: getController.isDarkMode,
                  activeColor: Colors.green,
                  onChanged: (newValue){
                    setState(() {
                      getController.changeThemeMode(newValue);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
