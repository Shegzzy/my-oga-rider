import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/constant/colors.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/home_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../repo/user_repo.dart';
import '../../controller/request_controller.dart';
import '../../model/booker_model.dart';
import '../../model/booking_model.dart';
import '../../model/earningModel.dart';
import '../../model/order_status_model.dart';
import '../../model/usermodel.dart';
import '../Rating_Screen/rating_screen.dart';

class OrderStatusScreen extends StatefulWidget {
 OrderStatusScreen({Key? key, required this.bookingData}) : super(key: key);
 BookingModel? bookingData;
  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {

  String? docId;
  String? cusId;
  var Int1, Int2, Int3, Int4, Int5, Int6, Int7;
 OrderStatusModel? _orderStats;
  BookerModel? _bookerModel;
  final _userRepo = Get.put(UserRepository());
  final _db = FirebaseFirestore.instance;
  UserModel? _userModel;
  FirestoreService requestController = FirestoreService();
  bool isLoading = false;
  bool int1Loading = false;
  bool int2Loading = false;
  bool int3Loading = false;
  bool int4Loading = false;
  bool int5Loading = false;
  bool int6Loading = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      getOrderStatus();
      getUserDetails();
      getDriver();
      initializeData();
  }

  Future<void> initializeData() async {
    await loadRequest();
  }

  Future<void> loadRequest() async {
    await requestController.fetchAcceptedRequests();
    // await requestController.loadAcceptedBookings();
  }


  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _userRepo.onClose();
  //   _userRepo.dispose();
  // }

  void getOrderStatus(){
    _userRepo.getOrderStatusData(widget.bookingData!.bookingNumber!).listen((event) {
      if(mounted) {
        setState(() {
          _orderStats = event;
        });
      } else { return; }
      Int1 = int.tryParse(_orderStats!.orderAssign!);
      Int2 = int.tryParse(_orderStats!.outForPick!);
      Int3 = int.tryParse(_orderStats!.arrivePick!);
      Int4 = int.tryParse(_orderStats!.percelPicked!);
      Int5 = int.tryParse(_orderStats!.wayToDrop!);
      Int6 = int.tryParse(_orderStats!.arriveDrop!);
      Int7 = int.tryParse(_orderStats!.completed!);
    });
  }

  void getUserDetails(){
    _userRepo.getUserDetailsWithID(widget.bookingData!.customer_id!).then((value) {
      if(mounted) {
        setState(() {
          _bookerModel = value;
        });
      } else { return; }
    });
  }

  void getDriver(){
    _userRepo.getDriverData().listen((event) {
      if (mounted){
        setState(() {
          _userModel = event;
        });
      } else { return; }
    });
  }

  Future<void> completeOrder() async {

    try{
      setState(() {
        isLoading = true;
      });

      await _db.collection("Order_Status").doc(_orderStats?.id).update({
        "Completed": "1",
      }).whenComplete(() =>
          Get.snackbar(
              "Success", "Order Status Updated.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.white,
              colorText: Colors.green,
              // maxWidth: 200
          ),
      ).catchError((error, stackTrace) {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });

      await _db.collection("Bookings")
          .where("Booking Number", isEqualTo:widget.bookingData!.bookingNumber!)
          .get().then((value) => value.docs.forEach((element) {
        docId = element.id;
      }));
      await _db.collection("Bookings")
          .doc(docId)
          .update({'Status': 'completed'}).whenComplete(() =>
          Get.snackbar(
              "Success", "Order Completed.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.white,
              colorText: Colors.green),
      ).catchError((error, stackTrace) {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.white,
            colorText: Colors.red);
      });

      final earn = EarningModel(
        driver: _orderStats?.driverID.toString(),
        booking: _orderStats?.bookingNumber.toString(),
        company: _userModel?.userCompany.toString(),
        amount: widget.bookingData!.amount.toString(),
        customer: widget.bookingData!.customer_id.toString(),
        // correction to be made
        // dateCreated: widget.bookingData!.created_at,
        dateCreated: DateTime.now().toString(),
        timeStamp: Timestamp.now(),
      );
      await _userRepo.storeEarning(earn);
      await requestController.completedOrDeletedRequest(_orderStats!.bookingNumber!);
    }catch (e){
      print('Error $e');
    }finally{
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -15,
            child: Container(
              width: 60,
              height: 7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey
              ),
            )
          ),
          Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text("Booking Number:  ${widget.bookingData!.bookingNumber!}", style: Theme.of(context).textTheme.titleLarge,)),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40.0,
                              height: 40.0,
                              child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(100),
                                  child: _bookerModel?.profilePic == null
                                      ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                      : Image(
                                    image: NetworkImage(_bookerModel!.profilePic!),
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context,
                                        child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return const Center(
                                          child:
                                          CircularProgressIndicator());
                                    },
                                    errorBuilder:
                                        (context, object, stack) {
                                      return const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      );
                                    },
                                  )),
                            ),
                            const SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_bookerModel?.fullname ?? " ", style: theme.textTheme.titleLarge),
                                Text(_bookerModel?.phoneNo ?? " ", style: theme.textTheme.bodyLarge),

                              ],
                            ),

                          ],
                        ),
                        GestureDetector(child: const Icon(Icons.phone, color: Colors.purple,), onTap: () async {
                          final Uri url = Uri(
                            scheme: 'tel',
                            path: _bookerModel!.phoneNo,
                          );
                          if(await canLaunchUrl(url)){
                            await launchUrl(url);
                          } else {
                            Get.snackbar("Notice!", "Not Supported yet", snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent.withOpacity(0.1),
                                colorText: Colors.red);
                          }
                        },)
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Int1 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int1 == 1 ? Text("Service Started", style: theme.textTheme.titleLarge)
                                  : const Text("Start Service", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),

                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children:[
                                    VerticalDivider(
                                      color: Int1 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 5,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int2 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int2 == 1 ? Text("Out For Pickup",style: theme.textTheme.titleLarge)
                                  :const Text("Out For Pickup", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Int2 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 5,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int3 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int3 == 1 ? Text("Arrive at Pickup Location", style: theme.textTheme.titleLarge)
                                  :const Text("Arrive at Pickup Location", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children: [
                                    VerticalDivider(
                                      color: Int3 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 5,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int4 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int4 == 1 ? Text("Parcel Picked", style: theme.textTheme.titleLarge)
                                  : const Text("Parcel Picked", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children:[
                                    VerticalDivider(
                                      color: Int4 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 5,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int5 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int5 == 1 ? Text("On the way to Drop Location", style: theme.textTheme.titleLarge)
                                  :const Text("On the way to Drop Location", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              height: 25,
                              child: Row(
                                  children:[
                                    VerticalDivider(
                                      color: Int5 == 1 ? Colors.purple : Colors.grey,
                                      width: 2,
                                      thickness: 5,

                                    ),
                                  ]

                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Int6 == 1 ?
                              Icon(Icons.circle, size: 20, color: Colors.purple):
                              Icon(Icons.circle_outlined, size: 20, color: Colors.grey,),
                              const SizedBox(width: 15,),
                              Int6 == 1 ? Text("Arrived at Drop Location", style: theme.textTheme.titleLarge)
                                  : const Text("Arrived at Drop Location", style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30,),

                          Row(
                            children: [
                              if(Int1 == 0)...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: int1Loading ? null : () async {
                                      ///Start Circular Progress Bar
                                      // showDialog(
                                      //     context: context,
                                      //     builder: (context){
                                      //       return const Center(child: CircularProgressIndicator());
                                      //     }
                                      // );
                                      //
                                      try{
                                        setState(() {
                                          int1Loading = true;
                                        });

                                        await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                          "Order Assigned": "1",
                                        }).whenComplete(() =>
                                            Get.snackbar(
                                                "Success", "Order Status Updated.",
                                                snackPosition: SnackPosition.TOP,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.green),
                                        ).catchError((error, stackTrace) {
                                          Get.snackbar("Error", "Something went wrong. Try again.",
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.red);
                                        });

                                      }catch(e){
                                        print('Int1 Error $e');
                                      }finally{
                                        setState(() {
                                          int1Loading = false;
                                        });
                                      }

                                    },
                                    style: Theme.of(context).elevatedButtonTheme.style,
                                    child: int1Loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                                        : Text("Order Assigned".toUpperCase()),
                                  ),
                                ),
                              ] else if(Int1 == 1 && Int2 == 0)...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      ///Start Circular Progress Bar
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                      );
                                      await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                        "Out For PickUp": "1",
                                      }).whenComplete(() =>
                                          Get.snackbar(
                                              "Success", "Order Status Updated.",
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.green),
                                      ).catchError((error, stackTrace) {
                                        Get.snackbar("Error", "Something went wrong. Try again.",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.white,
                                            colorText: Colors.red);
                                      });
                                      /// Stop Progress Bar
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                    style: Theme.of(context).elevatedButtonTheme.style,
                                    child: Text("On My Way to pickup".toUpperCase()),
                                  ),
                                ),
                              ]else if(Int2 == 1 && Int3 == 0)...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      ///Start Circular Progress Bar
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                      );
                                      await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                        "Arrive at PickUp": "1",
                                      }).whenComplete(() =>
                                          Get.snackbar(
                                              "Success", "Order Status Updated.",
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.green),
                                      ).catchError((error, stackTrace) {
                                        Get.snackbar("Error", "Something went wrong. Try again.",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.white,
                                            colorText: Colors.red);
                                      });
                                      /// Stop Progress Bar
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                    style: Theme.of(context).elevatedButtonTheme.style,
                                    child: Text("Arrived at Pickup".toUpperCase()),
                                  ),
                                ),
                              ]else if(Int3 == 1 && Int4 == 0)...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      ///Start Circular Progress Bar
                                      showDialog(
                                          context: context,
                                          builder: (context){
                                            return const Center(child: CircularProgressIndicator());
                                          }
                                      );
                                      await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                        "Parcel Picked": "1",
                                      }).whenComplete(() =>
                                          Get.snackbar(
                                              "Success", "Order Status Updated.",
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.green),
                                      ).catchError((error, stackTrace) {
                                        Get.snackbar("Error", "Something went wrong. Try again.",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.white,
                                            colorText: Colors.red);
                                      });
                                      /// Stop Progress Bar
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                    },
                                    style: Theme.of(context).elevatedButtonTheme.style,
                                    child: Text("Parcel Picked".toUpperCase()),
                                  ),
                                ),
                              ]else if (requestController.acceptedRequests.any((element) => element['type'] == 'Express' && element['status'] == 'active')) ...[
                                if(widget.bookingData?.deliveryMode == 'Express')...[
                                  if(Int4 == 1 && Int5 == 0)...[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async  {
                                          ///Start Circular Progress Bar
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return const Center(child: CircularProgressIndicator());
                                              }
                                          );
                                          await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                            "Going to DropOff": "1",
                                          }).whenComplete(() =>
                                              Get.snackbar(
                                                  "Success", "Order Status Updated.",
                                                  snackPosition: SnackPosition.TOP,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.green),
                                          ).catchError((error, stackTrace) {
                                            Get.snackbar("Error", "Something went wrong. Try again.",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.red);
                                          });
                                          /// Stop Progress Bar
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        },
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: Text("On My Way to DropOff".toUpperCase()),
                                      ),
                                    ),
                                  ]else if(Int5 == 1 && Int6 == 0)...[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          ///Start Circular Progress Bar
                                          showDialog(
                                              context: context,
                                              builder: (context){
                                                return const Center(child: CircularProgressIndicator());
                                              }
                                          );
                                          await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                            "Arrive DropOff": "1",
                                          }).whenComplete(() =>
                                              Get.snackbar(
                                                  "Success", "Order Status Updated.",
                                                  snackPosition: SnackPosition.TOP,
                                                  backgroundColor: Colors.white,
                                                  colorText: Colors.green),
                                          ).catchError((error, stackTrace) {
                                            Get.snackbar("Error", "Something went wrong. Try again.",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.red);
                                          });
                                          /// Stop Progress Bar
                                          // ignore: use_build_context_synchronously
                                          Navigator.of(context).pop();
                                        },
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: Text("Arrived at DropOff".toUpperCase()),
                                      ),
                                    ),
                                  ]else ...[
                                    Int1 == 1 ?
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: Int7 == 1 ? null:() async {
                                            await completeOrder();
                                            // requestController.removeCompletedBooking(widget.bookingData!.bookingNumber!);
                                            Get.to(() => RatingScreen(userID: widget.bookingData!.customer_id!, bookingID: widget.bookingData!.bookingNumber!,));
                                          },
                                          style: Theme.of(context).elevatedButtonTheme.style,
                                          child: isLoading ? const Center(child: CircularProgressIndicator()) : Text(Int7 == 1 ? "Order Completed".toUpperCase():"Confirm Order Completed".toUpperCase())
                                      ),
                                    ) :
                                    Expanded(
                                      child: OutlinedButton(
                                          onPressed: () async{
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            final userID = prefs.getString("UserID")!;
                                            final order = OrderStatusModel(
                                                customerID: widget.bookingData?.customer_id,
                                                driverID: userID,
                                                bookingNumber: widget.bookingData?.bookingNumber,
                                                orderAssign: "1",
                                                outForPick: "0",
                                                arrivePick: "0",
                                                percelPicked: "0",
                                                wayToDrop: "0",
                                                arriveDrop: "0",
                                                completed: "0",
                                                dateCreated: DateTime.now().toString(),
                                                timeStamp: Timestamp.now()
                                            );
                                            requestController.storeOrderStatus(order);
                                          },
                                          style: Theme.of(context).elevatedButtonTheme.style,
                                          child: Text("Start Service".toUpperCase())
                                      ),
                                    ),
                                  ],
                                ]else if(widget.bookingData?.deliveryMode == 'Normal')...[
                                  Int3 == 1 ?
                                  Center(child: Text('Please Complete Express Booking \n before proceeding to DropOff', style: Theme.of(context).textTheme.titleSmall,)):
                                  Expanded(
                                    child: OutlinedButton(
                                        onPressed: () async{
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          final userID = prefs.getString("UserID")!;
                                          final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: widget.bookingData?.bookingNumber).get();
                                          if(snapshot.docs.isNotEmpty){
                                            final order = OrderStatusModel(
                                                customerID: widget.bookingData?.customer_id,
                                                driverID: userID,
                                                bookingNumber: widget.bookingData?.bookingNumber,
                                                orderAssign: "1",
                                                outForPick: "0",
                                                arrivePick: "0",
                                                percelPicked: "0",
                                                wayToDrop: "0",
                                                arriveDrop: "0",
                                                completed: "0",
                                                dateCreated: DateTime.now().toString(),
                                                timeStamp: Timestamp.now()
                                            );
                                            requestController.storeOrderStatus(order);
                                          }else{
                                            Get.snackbar("Error", "This booking has been cancelled", colorText: Colors.redAccent,backgroundColor: Colors.white);
                                            if(mounted){
                                              Navigator.pop(context);
                                            }
                                          }

                                        },
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: Text("Start Service".toUpperCase())
                                    ),
                                  ),

                                ]
                              ] else ...[
                                if(Int4 == 1 && Int5 == 0)...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async  {
                                        ///Start Circular Progress Bar
                                        showDialog(
                                            context: context,
                                            builder: (context){
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                        );
                                        await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                          "Going to DropOff": "1",
                                        }).whenComplete(() =>
                                            Get.snackbar(
                                                "Success", "Order Status Updated.",
                                                snackPosition: SnackPosition.TOP,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.green),
                                        ).catchError((error, stackTrace) {
                                          Get.snackbar("Error", "Something went wrong. Try again.",
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.red);
                                        });
                                        /// Stop Progress Bar
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();
                                      },
                                      style: Theme.of(context).elevatedButtonTheme.style,
                                      child: Text("On My Way to Dropoff".toUpperCase()),
                                    ),
                                  ),
                                ]else if(Int5 == 1 && Int6 == 0)...[
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        ///Start Circular Progress Bar
                                        showDialog(
                                            context: context,
                                            builder: (context){
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                        );
                                        await _db.collection("Order_Status").doc(_orderStats?.id).update({
                                          "Arrive DropOff": "1",
                                        }).whenComplete(() =>
                                            Get.snackbar(
                                                "Success", "Order Status Updated.",
                                                snackPosition: SnackPosition.TOP,
                                                backgroundColor: Colors.white,
                                                colorText: Colors.green),
                                        ).catchError((error, stackTrace) {
                                          Get.snackbar("Error", "Something went wrong. Try again.",
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.white,
                                              colorText: Colors.red);
                                        });
                                        /// Stop Progress Bar
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).pop();
                                      },
                                      style: Theme.of(context).elevatedButtonTheme.style,
                                      child: Text("Arrived at DropOff".toUpperCase()),
                                    ),
                                  ),
                                ]else ...[
                                  Int1 == 1 ?
                                  Expanded(
                                    child: OutlinedButton(
                                        onPressed: Int7 == 1 ? null:() async {
                                          await completeOrder();
                                          // requestController.removeCompletedBooking(widget.bookingData!.bookingNumber!);
                                          // Navigator.of(context).pop();
                                          Get.to(() => RatingScreen(userID: widget.bookingData!.customer_id!, bookingID: widget.bookingData!.bookingNumber!));
                                        },
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: isLoading ? const Center(child: CircularProgressIndicator()) : Text(Int7 == 1 ? "Order Completed".toUpperCase():"Confirm Order Completed".toUpperCase())
                                    ),
                                  ) :
                                  Expanded(
                                    child: OutlinedButton(
                                        onPressed: () async{
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          final userID = prefs.getString("UserID")!;
                                          final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: widget.bookingData?.bookingNumber).get();
                                          if(snapshot.docs.isNotEmpty){
                                            final order = OrderStatusModel(
                                                customerID: widget.bookingData?.customer_id,
                                                driverID: userID,
                                                bookingNumber: widget.bookingData?.bookingNumber,
                                                orderAssign: "1",
                                                outForPick: "0",
                                                arrivePick: "0",
                                                percelPicked: "0",
                                                wayToDrop: "0",
                                                arriveDrop: "0",
                                                completed: "0",
                                                dateCreated: DateTime.now().toString(),
                                                timeStamp: Timestamp.now()
                                            );
                                            requestController.storeOrderStatus(order);
                                          }else{
                                            Get.snackbar("Error", "This booking has been cancelled", colorText: Colors.redAccent,backgroundColor: Colors.white);
                                            if(mounted){
                                              Navigator.pop(context);
                                            }
                                          }

                                        },
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: Text("Start Service".toUpperCase())
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      );
  }
}
