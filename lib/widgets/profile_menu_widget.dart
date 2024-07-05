import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart';

import '../constant/colors.dart';
import '../services/controller/getx_switch_state.dart';

class ProfileMenuWidget extends StatelessWidget {
  ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;
  final GetXSwitchState getXSwitchState = Get.find();


  @override
  Widget build(BuildContext context) {

    var isDark = getXSwitchState.isDarkMode;
    var iconColor = isDark? moPrimaryColor : moAccentColor;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
      trailing: endIcon? Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Icon(LineAwesomeIcons.angle_right_solid,
              size: 18.0, color: Colors.grey)) : null ,
    );
  }
}