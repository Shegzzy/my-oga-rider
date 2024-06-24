import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleModel extends StatefulWidget {
  const VehicleModel({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;

  @override
  State<VehicleModel> createState() => _VehicleModelState();
}

class _VehicleModelState extends State<VehicleModel> {

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Model of your vehicle?", style: Theme.of(context).textTheme.headlineSmall,),
          const SizedBox(height: 10.0,),

          TextFieldWidget(
              'Enter Model of Vehicle',
              widget.controller,
                  (String v){},
              readOnly: false
          ),

          //ListView.builder(itemBuilder: (ctx,i){
          //  return ListTile(
          //    onTap: () => widget.onSelect(vehicleModel[i]),
          //    title: Text(vehicleModel[i]),
          //    trailing: widget.selectedModel == vehicleModel[i] ? Padding(
          //      padding: const EdgeInsets.all(10.0),
          //      child: CircleAvatar(
          //        backgroundColor: Colors.green,
          //        child: Icon(Icons.check, color: Colors.white, size: 15,),
          //      ),
          //    ) : SizedBox.shrink(),
          //  );
          //}, itemCount: vehicleModel.length,shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
          //),
        ],
      ),
    );
  }
}
