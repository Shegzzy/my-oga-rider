import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../controller/signup_controller.dart';
import '../../model/usermodel.dart';
import '../Car_Registration/car_regitration_widget.dart';
import '../OTP_Screen/otp_screen.dart';
import '../Request_Screen/request_screen.dart';


class SignupFormWidget extends StatefulWidget {
  const SignupFormWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<SignupFormWidget> createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {


  final controller = Get.put(SignUpController());
  final _formkey = GlobalKey<FormState>();
  bool _isVisible = false;
  bool _isPasswordEightChar = false;
  bool _isPasswordOneNum = false;
  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode = CountryCode(name: "Nigeria", code: "NG", dialCode: "+234");
  var isUploading = false.obs;

  onPasswordChanged(String password){
    final numericRegx = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightChar = false;
      _isPasswordOneNum = false;
      if(password.length  >= 8) {
        _isPasswordEightChar = true;
      }
      if(numericRegx.hasMatch(password)) {
        _isPasswordOneNum = true;
      }
    });
  }

  signUP() async {

    final user = UserModel(
      email: controller.email.text.trim(),
      fullname: controller.name.text.trim(),
      password: controller.password.text.trim(),
      phoneNo: countryCode.dialCode+controller.phoneNo.text.trim(),
      address: controller.address.text.trim(),
      isVerified: '0',
      isOnline: '0',
      dateCreated: DateTime.now().toString(),
    );

    ///Start Circular Progress Bar
    isUploading(true);

    await controller.registerUser(controller.email.text.trim(), controller.password.text.trim());
    await controller.createUser(user);
    controller.phoneAuthentication(countryCode.dialCode+controller.phoneNo.text.trim());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Phone", countryCode.dialCode+controller.phoneNo.text.trim());

    /// Stop Progress Bar
    isUploading(false);

    Get.to(() => const OTPScreen());
  }


  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(moFullName),
                    prefixIcon: Icon(Icons.person_outline_outlined)),
                controller: controller.name,
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your full name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(moEmail),
                    prefixIcon: Icon(Icons.email_outlined)),
                controller: controller.email,
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your email";
                  }
                  if(!value.contains("@")){
                    return ("Please enter a valid email address!");
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                onChanged: (password) => onPasswordChanged(password),
                obscureText: !_isVisible,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: (){
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off, color: Colors.grey,),
                    ),
                    label: const Text(moPassword),
                    prefixIcon: const Icon(Icons.fingerprint_outlined)),
               controller: controller.password,
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your password";
                  }
                  if(_isPasswordEightChar == false){
                    return "Password must be at least 8 character.";
                  }
                  if(_isPasswordOneNum == false){
                    return "Password must contain at least 1 number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isPasswordEightChar ? Colors.green : Colors.transparent,
                      border: _isPasswordEightChar ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 15,),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Text("Contains at least 8 characters")
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _isPasswordOneNum ? Colors.green : Colors.transparent,
                      border: _isPasswordOneNum ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 15,),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Text("Contains at least 1 number")
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                    label: Text(moRepeatPassword),
                    prefixIcon: Icon(Icons.fingerprint_outlined)),
                    validator: (value){
                      if(value != controller.password.text.trim())
                      {
                        return "Password not match";
                      }
                        return null;
                      },
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                height: 60.0,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.1) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 3,
                      blurRadius: 3,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () async {
                          final code = await countryPicker.showPicker(context: context);
                          if(code != null){
                            countryCode = code;
                          }
                          setState(() {

                          });
                        },
                        child: Row(
                          children: [
                            const SizedBox(width: 10.0,),
                            Expanded(
                              child: Container(
                                child: countryCode.flagImage,
                              ),
                            ),
                            Text(countryCode.dialCode, style: Theme.of(context).textTheme.bodyText2,),
                            const Icon(Icons.keyboard_arrow_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60.0,
                      color: moAccentColor.withOpacity(0.2),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: controller.phoneNo,
                        decoration: const InputDecoration(
                          label: Text(moPhoneTitle),
                          hintText: moPhoneHintTitle,
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty)
                          {
                            return "Please enter a mobile number";
                          }
                          if(value.length > 10 || value.length < 10 ){
                            return "Please enter a valid mobile number without 0";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: controller.address,
                decoration: const InputDecoration(
                    label: Text("Enter Permanent Address"),
                    prefixIcon: Icon(Icons.home_work_outlined)),
                validator: (value){
                  if(value == null || value.isEmpty)
                  {
                    return "Please enter your address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                child: Obx(()=> isUploading.value? const Center(child: CircularProgressIndicator()): ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      signUP();
                    }
                  },
                  child: Text(moNext.toUpperCase()),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
