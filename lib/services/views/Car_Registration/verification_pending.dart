import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../constant/image_string.dart';
import '../../../widgets/loading.dart';
import '../Welcome_Screen/welcome_screen.dart';

class VerificaitonPendingScreen extends StatefulWidget {
  const VerificaitonPendingScreen({Key? key}) : super(key: key);

  @override
  State<VerificaitonPendingScreen> createState() => _VerificaitonPendingScreenState();
}

class _VerificaitonPendingScreenState extends State<VerificaitonPendingScreen> {

  late var _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted){
      _timer= Timer.periodic(const Duration(seconds: 20), (timer){
          Get.offAll( const WelcomeScreen());
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50.0,),
          Image(image: const AssetImage(moSplashImage), height: size.height * 0.1,),
          Text("Vehicle Registration", style: Theme.of(context).textTheme.headline1,),
          Text("process status", style: Theme.of(context).textTheme.bodyText1,),

          const SizedBox(height: 20,),


          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Verification Pending',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Colors.black),),
              const SizedBox(height: 20,),


              const Text('Your document is still pending for verification. Once it’s all verified you start getting rides. please sit tight',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Color(0xff7D7D7D)),textAlign: TextAlign.center,),

              const SizedBox(height: 20,),
              Loading()
            ],
          )),
          const SizedBox(height: 40,),




        ],
      ),
    );
  }
}
