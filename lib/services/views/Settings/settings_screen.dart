import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
            onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(moSetting, style: Theme.of(context).textTheme.headline4),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(moPushNotification, style: Theme.of(context).textTheme.headline4,),
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
            Text(moPrivacy, style: Theme.of(context).textTheme.headline4,),
            const SizedBox(height: 20.0,),
            Text(moTerms, style: Theme.of(context).textTheme.headline4,),
            const SizedBox(height: 20.0,),
            Text(moAbout, style: Theme.of(context).textTheme.headline4,),
          ],
        ),
      ),
    );
  }
}
