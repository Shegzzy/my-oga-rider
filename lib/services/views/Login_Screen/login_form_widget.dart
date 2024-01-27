import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';

import '../../controller/login_controller.dart';
import '../../model/usermodel.dart';
import '../Car_Registration/verification_pending.dart';
import '../Main_Screen/main_screen.dart';
import '../Forget_Password/Forget_Password_Options/forget_password_model_bottom_sheet.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final _formkey = GlobalKey<FormState>();
  final _controller = Get.put(LoginController());
  bool _isVisible = false;
  bool isUploading = false;

  Future<void> login() async{
    try {
      setState(() {
        isUploading = true;
      });
      await _controller.loginUsers(_controller.email.text.trim(), _controller.password.text.trim());
    } catch (e){
      print('Error $e');
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined),
                labelText: moEmail,
                hintText: moEmail,
                border: OutlineInputBorder(),
              ),
              validator: (value){
                if(value == null || value.isEmpty)
                {
                  return "Please enter email";
                }
                return null;
              },
              controller: _controller.email,
            ),
            const SizedBox(height: 10.0,),
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined),
                labelText: moPassword,
                hintText: moPassword,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: _isVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off, color: Colors.grey,),
                ),
              ),
              obscureText: !_isVisible,
              controller: _controller.password,
              validator: (value){
                if(value == null || value.isEmpty)
                {
                  return "Please enter your password";
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0,),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (){
                  ForgetPasswordScreen.buildShowModalBottomSheet(context);
                },
                child: const Text(moForgetPassword, style: TextStyle(color: moAccentColor),),
              ),
            ),
             SizedBox(
              width: double.infinity,
              child: isUploading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: () async {
                if(_formkey.currentState!.validate()) {
                ///Start Circular Progress Bar
                await login();
                }
                },
                child: Text(moLogin.toUpperCase(), style: const TextStyle(fontSize: 20.0,),),
                ),
            ),
          ],
        ),
      ),
    );
  }
}



