import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/getx_switch_state.dart';

class VehicleMake extends StatefulWidget {
  const VehicleMake({Key? key, required this.controller,}) : super(key: key);

  final TextEditingController controller;

  @override
  State<VehicleMake> createState() => _VehicleMakeState();
}

class _VehicleMakeState extends State<VehicleMake> {
  final GetXSwitchState getXSwitchState = Get.find();


  TextFieldWidget(String title,TextEditingController controller,Function validator,{Function? onTap,bool readOnly = false}) {
    var isDark = getXSwitchState.isDarkMode;
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      // height: 50,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 1)
          ],
          borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        readOnly: readOnly,
        onTap: ()=> onTap!(),
        validator: (input)=> validator(input),
        controller: controller,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xffA7A7A7)),
        decoration: InputDecoration(
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintStyle:  GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xff7D7D7D).withOpacity(0.5)),
          hintText: title,
          // border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Make of your vehicle?", style: Theme.of(context).textTheme.headline5,),
        const SizedBox(height: 10.0,),
        TextFieldWidget(
            'Enter Make eg. Lexus or Suzuki',
            widget.controller,
                (String v){},
            readOnly: false
        ),
      ],
    );
  }
}
