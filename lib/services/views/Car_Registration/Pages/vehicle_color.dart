import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleColor extends StatefulWidget {
  const VehicleColor({Key? key, required this.onColorSelected, required this.controller}) : super(key: key);

  final Function onColorSelected;
  final TextEditingController controller;

  @override
  State<VehicleColor> createState() => _VehicleColorState();
}

class _VehicleColorState extends State<VehicleColor> {

  String dropdownvalue = 'Pick a color';

  List<String> colors = [
    'Pick a color',
    'White',
    "Red",
    "Black",
    "Blue",
    "Grey",
    "Green",
    "Others",
  ];

  buildDropDown() {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // height: 50,
      decoration: BoxDecoration(
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 1)
          ],
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton(

        // Initial Value
        value: dropdownvalue,

        isExpanded: true,
        underline: Container(),

        // Down Arrow Icon
        icon: const Icon(Icons.keyboard_arrow_down),

        // Array list of items
        items: colors.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        // After selecting the desired option,it will
        // change button value to selected value
        onChanged: (String? newValue) {
          setState(() {
            dropdownvalue = newValue!;
          });
          widget.onColorSelected(newValue!);
        },
      ),
    );
  }

  TextFieldWidget(
      String title,TextEditingController controller,Function validator,{Function? onTap,bool readOnly = false}) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          filled: true,
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

        Text('What color of vehicle is it ?',style: Theme.of(context).textTheme.headlineSmall,),

        const SizedBox(height: 30,),

        buildDropDown(),
        const SizedBox(height: 20.0,),
        if(dropdownvalue == "Others")...[
          Container(
            child: TextFieldWidget(
                'Enter Vehicle color',
                widget.controller,
                    (String v){},
                readOnly: false
            ),
          ),
        ]
      ],
    );
  }
}
