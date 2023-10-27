import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../verification_pending.dart';


class DocumentUpload extends StatefulWidget {
  const DocumentUpload({Key? key}) : super(key: key);

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {

  late var _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      _timer= Timer.periodic(const Duration(seconds: 20), (timer){
        Get.offAll( const VerificaitonPendingScreen());
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Text('Upload Documents',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),),

        SizedBox(height: 30,),


        Container(
          width: Get.width,
          height: Get.height*0.1,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xffE3E3E3).withOpacity(0.4),
              border: Border.all(color: Color(0xff2FB654).withOpacity(0.26),width: 1)
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_upload,size: 40,color: Color(0xff7D7D7D),),

              const SizedBox(width: 10,),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: [

                  Text('Vehicle Registration',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.black),),
                  Text('waiting For Approval',style: TextStyle(fontSize: 12,color: Color(0xff62B62F)),),


                ],
              ),
            ],
          ),
        ),


      ],
    );
  }
}
