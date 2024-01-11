import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../repo/user_repo.dart';
import '../../model/usermodel.dart';

class RatingScreen extends StatefulWidget {
  final String userID;
  const RatingScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {

  double ratingValue = 0.0;
  String? customer;
  UserModel? userModel;
  final _db = FirebaseFirestore.instance;
  final controller = Get.put(UserRepository());


  void saveRating() async {
    final userName = userModel?.fullname;
    final userEmail = userModel?.email;

    final data = {
      "name": userName,
      "email": userEmail,
      "rating": ratingValue,
      "dateCreated": DateTime.now().toString(),
      "timeStamp": Timestamp.now(),
    };

    try{
      await _db.collection('Users').doc(customer).collection('Ratings').add(data).whenComplete(() => Get.snackbar(
          "Success", "Rating Submitted.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.green),
      ).catchError((error, stackTrace) {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });
    } catch (e){
      Get.snackbar(
        "Error", e.toString(), snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customer = widget.userID;
    getDriverDetails();
  }

  Future<void> getDriverDetails() async{
    controller.getDriverData().listen((event){
      setState(() {
        userModel = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rate Service",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80.0,
            ),
            RatingBar.builder(
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState((){
                  ratingValue = rating;
                });
                if (kDebugMode) {
                  print(rating);
                }
              },
              initialRating: 0.0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              unratedColor: Colors.grey,
              itemSize: 50.0,
              updateOnDrag: true,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Row(
              children: [
                Expanded(
                  child: ratingValue == 0.0
                      ? OutlinedButton(
                    onPressed: (){
                      Get.snackbar(
                        "Oh Yeah", "You need to select a rating amount", snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.white,
                        colorText: Colors.red,
                      );
                    },
                    style: Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style,
                    child: Text("Tap on Amount of Star".toUpperCase()),
                  )
                      : OutlinedButton(
                    onPressed: (){
                      saveRating();
                    },
                    style: Theme
                        .of(context)
                        .elevatedButtonTheme
                        .style,
                    child: Text("Submit Rating".toUpperCase()),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
