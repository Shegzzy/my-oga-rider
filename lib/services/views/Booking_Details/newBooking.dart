import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/home_tab.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/request_controller.dart';
import '../../model/booking_model.dart';
import '../../model/order_status_model.dart';
import '../Accepted_Request_Screen/accepted_screen.dart';
import '../Order_Status/order_status.dart';

class NewBookingScreen extends StatefulWidget {
  final String cId;
  final String bNum;
  const NewBookingScreen({Key? key, required this.cId, required this.bNum}) : super(key: key);

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  BookingModel? _incomingRequest;
  final FirestoreService _requestController = FirestoreService();
  final _db = FirebaseFirestore.instance;
  bool loadingBooking = false;
  int counter = 0;
  double rate = 0;
  double total = 0;
  double average = 0;
  bool loadingCustomer = false;


  @override
  void initState() {
    super.initState();
    _requestController.fetchAcceptedRequests();
    fetchNewBookingRequest();
    getRatingCount();
  }

  Future<void> fetchNewBookingRequest() async{
    try{
      setState(() {
        loadingBooking = true;
      });

      final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: widget.bNum).get();
      _incomingRequest = snapshot.docs.map((e) => BookingModel.fromSnapshot(e.data())).single;
    }catch (e){
      print('Error fetching the booking $e');
    }finally{
      setState(() {
        loadingBooking = false;
      });
    }
  }

  Future<void> getRatingCount() async{

    try{
      setState(() {
        loadingCustomer = true;
      });
      await _db.collection("Users").doc(widget.cId).collection("Ratings").get().then((value) {
        for (var element in value.docs) {
          rate = element.data()["rating"];
          setState(() {
            total = total + rate;
            counter = counter+1;
          });
        }
      });
      average = total/counter;
    }catch (e){
      print('Error getting user ratings $e');
    }finally{
      setState(() {
        loadingCustomer = false;
      });
    }
  }


  void showAcceptModalBottomSheet(BuildContext context, BookingModel newRequest){
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.32,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: AcceptScreen(btnClicked: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            final userID = prefs.getString("UserID")!;
            final order = OrderStatusModel(
              customerID: newRequest.customer_id,
              driverID: userID,
              bookingNumber: newRequest.bookingNumber,
              orderAssign: "1",
              outForPick: "0",
              arrivePick: "0",
              percelPicked: "0",
              wayToDrop: "0",
              arriveDrop: "0",
              completed: "0",
              dateCreated: DateTime.now().toString(),
              timeStamp: Timestamp.now(),
            );
            await _requestController.storeOrderStatus(order);
            showStatusModalBottomSheet(context, newRequest);
          },
            bookingData: newRequest,
          ),
        ),
      ),
    );
  }

  void showStatusModalBottomSheet(BuildContext context, BookingModel inRequest){
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.32,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: OrderStatusScreen(
            bookingData: inRequest,
          ),
        ),
      ),
    );
  }

  Future<void> checkBookingBeforeAccepting(BookingModel newRequest) async{
    try{
      setState(() {
        loadingBooking = true;
      });

      final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: newRequest.bookingNumber).get();
      final bookingData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e.data())).single;
      if(snapshot.docs.isNotEmpty){
        if(_requestController.acceptedRequests.length < 3){
          if( bookingData.status == 'pending'){
            if (_requestController.acceptedRequests.any((element) => element['type'] == 'Express')) {
              if (newRequest.deliveryMode == 'Express') {
                Get.snackbar(
                    "Error",
                    "You can only take one express booking",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.white,
                    colorText: Colors.red);
              } else {
                await _requestController.updateDetail(
                    newRequest.bookingNumber);
                if (mounted) {
                  showAcceptModalBottomSheet(
                      context, newRequest);
                }
                _requestController.removePendingBookings(
                    newRequest.bookingNumber!);
              }
            }
            else {
              await _requestController.updateDetail(
                  newRequest.bookingNumber);
              if (mounted) {
                showAcceptModalBottomSheet(
                    context, newRequest);
              }
              _requestController.removePendingBookings(
                  newRequest.bookingNumber!);
            }
          }else{
            Get.snackbar("Error", "Booking have been accepted by another rider", colorText: Colors.redAccent, backgroundColor: Colors.white);
            if(mounted){
              Navigator.pop(context);
            }
          }
        }else{
          Get.snackbar(
              "Error",
              "You can only take three bookings at a time",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.white,
              colorText: Colors.red);
        }

      }else{
        Get.snackbar("Error", "Booking has been cancelled", colorText: Colors.redAccent, backgroundColor: Colors.white);
        if(mounted){
          Navigator.pop(context);
        }
      }
    }catch (e){
      print('Checking booking error: $e');
    } finally{
      setState(() {
        loadingBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Booking"),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
              Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            children: [
              Text("New Booking Request", style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Icon(LineAwesomeIcons.street_view),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Pickup: ${_incomingRequest?.pickup_address??""}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  const Icon(LineAwesomeIcons.map_marker),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Drop-Off: ${_incomingRequest?.dropOff_address??""}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Distance: ${ _incomingRequest?.distance ?? ""}', style: Theme.of(context).textTheme.bodyMedium,),
                  const SizedBox(width: 20,),
                  Text('Cost: ${_incomingRequest?.amount ?? ""}', style: Theme.of(context).textTheme.bodyMedium,),
                ],
              ),
              const SizedBox(height: 35,),
              Text("Payment Method", style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 10,),
              Text(_incomingRequest?.payment_method??"", style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 35,),
              //
              Text("Delivery Mode", style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 10,),
              Text(_incomingRequest?.deliveryMode??"", style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 35,),

              Text("Ride Type", style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 10,),
              Text(_incomingRequest?.rideType ?? "", style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 35,),

              Text("User Ratings", style: Theme.of(context).textTheme.titleLarge,),
              const SizedBox(height: 10,),
              loadingCustomer ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(),) :
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(average.toStringAsFixed(1), style: Theme
                      .of(context)
                      .textTheme.labelMedium,),
                  Icon(
                    Icons.star,
                    size: 14,
                    color: average < 3.5 ? Colors.redAccent : Colors.green,
                  )
                ],
              ),
              const SizedBox(height: 35,),
              Column(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Get.off(() => const HomeTabPage());
                      // getRatingCount();
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Center(child: Text("Cancel".toUpperCase())),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  ElevatedButton(
                    onPressed: loadingBooking ? null : () async {
                      await checkBookingBeforeAccepting(_incomingRequest!);
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Center(child: loadingBooking ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator()) : Text("Accept".toUpperCase())),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
