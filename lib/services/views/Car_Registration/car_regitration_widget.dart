import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/services/views/Car_Registration/verification_pending.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/colors.dart';
import '../../../constant/image_string.dart';
import '../../../repo/auth_repo.dart';
import 'Pages/company.dart';
import 'Pages/document_upload.dart';
import 'Pages/location_page.dart';
import 'Pages/upload_document.dart';
import 'Pages/vehicle_color.dart';
import 'Pages/vehicle_make.dart';
import 'Pages/vehicle_model.dart';
import 'Pages/vehicle_model_year.dart';
import 'Pages/vehicle_number.dart';
import 'Pages/vehicle_type.dart';


class CarRegistrationWidget extends StatefulWidget {
  const CarRegistrationWidget({Key? key}) : super(key: key);

  @override
  State<CarRegistrationWidget> createState() => _CarRegistrationWidgetState();
}

class _CarRegistrationWidgetState extends State<CarRegistrationWidget> {

  String selectedLocation = "";
  String selectedVehicle = "";
  TextEditingController vehicleMakeController = TextEditingController();
  TextEditingController vehicleModelController = TextEditingController();
  //String selectedVehicleMake =  '';
  //String selectedVehicleModel =  '';
  String selectedCompany =  '';
  String selectModelYear = '';
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleColorController = TextEditingController();
  String vehicleColor = '';
  List<File> document = [];
  List<String> downloadUrls = [];
  var isUploading = false.obs;

  final PageController _pageController = PageController();
  final _controller = Get.put(AuthenticationRepository());

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50.0,),
          Image(image: const AssetImage(moSplashImage), height: size.height * 0.1,),
          Text("Vehicle Registration", style: Theme.of(context).textTheme.displayLarge,),
          Text("Complete the process details", style: Theme.of(context).textTheme.bodyLarge,),
          const SizedBox(height: 40.0,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
                child: PageView(
                  onPageChanged: (int page){
                    currentPage = page;
                  },
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                children: [
                  LocationPage(selectedLocation: selectedLocation, onSelect: (String location){
                    setState(() {
                      selectedLocation = location;
                    });
                  }),
                  VehicleType(selectedVehicle: selectedVehicle, onSelect: (String vehicle){
                    setState(() {
                      selectedVehicle = vehicle;
                    });
                  }),
                  VehicleMake(
                    controller: vehicleMakeController,
                  ),
                  VehicleModel(
                    controller: vehicleModelController,
                  ),
                  VehicleModelYear(
                    onSelect: (int year){
                      setState(() {
                        selectModelYear = year.toString();
                      });
                    },
                  ),
                  VehicleNumber(
                    controller: vehicleNumberController,
                  ),
                  VehicleColor(
                    onColorSelected: (String selectedColor){
                      vehicleColor = selectedColor;
                    },
                    controller: vehicleColorController,
                  ),
                  SelectCompany(
                    selectedCompany: selectedCompany,
                    onSelect: (String company){
                      setState(() {
                        selectedCompany = company;
                      });
                    },
                  ),
                  UploadDocument(onImageSelected: (List<File> image){
                    document = image;
                  },
                  ),
                  const DocumentUpload(),

                ],
              ),
            ),),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: (){
                      _pageController.animateToPage(currentPage-1, duration: const Duration(milliseconds: 500), curve: Curves.easeIn,);
                    }, backgroundColor: PButtonColor,
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white,),),
                  )),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Obx(()=> isUploading.value? const Center(child: CircularProgressIndicator())
                        : FloatingActionButton(
                      onPressed: () {
                        if (currentPage < 8) {
                          if (validateCurrentPage()) {
                            _pageController.animateToPage(currentPage + 1,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          } else {
                            Get.snackbar('Notice', 'Please fill in all required fields.');
                          }
                        } else if (document.isEmpty) {
                          Get.snackbar('Notice', 'Please upload photo of your documents');
                        } else {
                          uploadDriverCarEntry();
                        }
                      },
                      backgroundColor: PButtonColor,
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white,),),
                  ))
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool validateCurrentPage() {
    switch (currentPage) {
      case 0:
        return selectedLocation.isNotEmpty;
      case 1:
        return selectedVehicle.isNotEmpty;
      case 2:
        return vehicleMakeController.text.trim().isNotEmpty;
      case 3:
        return vehicleModelController.text.trim().isNotEmpty;
      case 4:
        return selectModelYear.isNotEmpty;
      case 5:
        return vehicleNumberController.text.trim().isNotEmpty;
      case 6:
        return vehicleColor.isNotEmpty &&
            (vehicleColor != "Others" || vehicleColorController.text.isNotEmpty);
      case 7:
        return selectedCompany.isNotEmpty;
      default:
        return true;
    }
  }

  Future<String>uploadFile(File file) async {
    final metaData = SettableMetadata(contentType: 'image/jpeg');
    final storageRef = FirebaseStorage.instance.ref();
    Reference ref = storageRef
        .child('riders/${DateTime.now().microsecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(file, metaData);

    final taskSnapshot = await uploadTask.whenComplete(() => null);
    String url = await taskSnapshot.ref.getDownloadURL();
    return url;
  }

  storeEntry(List<String> imageUrls) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("aUserID")!;
    FirebaseFirestore.instance
        .collection('Drivers')
        .doc(userID)
        .update({'Documents': imageUrls}).then((value) {
      Get.snackbar('Success', 'Data is stored successfully');
    });
  }

  void uploadDriverCarEntry() async{

    isUploading(true);

    for (int i = 0; i < document.length; i++) {
      String url = await uploadFile(document[i]);
      downloadUrls.add(url);

      if (i == document.length - 1) {
        storeEntry(downloadUrls);
      }
    }

    Map<String,dynamic> carData = {
      'State': selectedLocation,
      'Vehicle Type': selectedVehicle,
      'Vehicle Make': vehicleMakeController.text.trim(),
      'Vehicle Model': vehicleModelController.text.trim(),
      'Vehicle Year': selectModelYear,
      'Vehicle Number': vehicleNumberController.text.trim(),
      'Vehicle Color': vehicleColor == "Others" ? vehicleColorController : vehicleColor,
      'Company': selectedCompany,
    };

    await _controller.uploadCarEntry(carData);
    isUploading(false);

    // Get.off(()=>const VerificaitonPendingScreen());
  }

}
