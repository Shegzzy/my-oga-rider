import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../constant/colors.dart';
import '../../../utils/formatter/formatter.dart';
import '../../controller/request_controller.dart';
import '../../model/booking_model.dart';
import '../../model/order_status_model.dart';
import '../Accepted_Request_Screen/accepted_screen.dart';
import '../Order_Status/order_status.dart';

class PendingBookings extends StatefulWidget {
  const PendingBookings({super.key});

  @override
  State<PendingBookings> createState() => _PendingBookingsState();
}

class _PendingBookingsState extends State<PendingBookings> {
  FirestoreService requestController = Get.find();
  final _db = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    requestController.loadPendingBookings();
  }

  void showAcceptModalBottomSheet(BuildContext context,
      BookingModel newRequest) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.9,
            minChildSize: 0.32,
            builder: (context, scrollController) =>
                SingleChildScrollView(
                  controller: scrollController,
                  child: AcceptScreen(btnClicked: () async {
                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
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

                    ///Start Circular Progress Bar
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                    );
                    await requestController.storeOrderStatus(order);

                    /// Stop Progress Bar
                    Navigator.of(context).pop();
                    showStatusModalBottomSheet(context, newRequest);
                  },
                    bookingData: newRequest,
                  ),
                ),
          ),
    );
  }

  void showStatusModalBottomSheet(BuildContext context,
      BookingModel inRequest) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) =>
          DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.32,
            builder: (context, scrollController) =>
                SingleChildScrollView(
                  controller: scrollController,
                  child: OrderStatusScreen(
                    bookingData: inRequest,
                  ),
                ),
          ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pending Requests'),
          centerTitle: true,
        ),
        body: GetBuilder<FirestoreService>(
            builder: (requestController){
              return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: ListView.builder(
              itemCount: requestController.requestHistory.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  child: ListTile(
                    dense: true,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup Address: ${requestController
                            .requestHistory[index].pickup_address!}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .labelLarge,),
                        const SizedBox(height: 10,),
                        Text('DropOff Address: ${requestController
                            .requestHistory[index].dropOff_address!}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .labelLarge),

                      ],
                    ),
                    subtitle: Column(
                        children: [
                          const SizedBox(height: 10,),
                          Column(
                            children: [
                              Text('Delivery Mode: ${requestController
                                  .requestHistory[index].deliveryMode!}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .labelMedium),
                              const SizedBox(height: 5),
                              Text('Ride Type: ${requestController
                                  .requestHistory[index].rideType!}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .labelMedium),
                              const SizedBox(height: 5),
                              Text('Distance: ${requestController
                                  .requestHistory[index].distance!}',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .labelMedium),
                              const SizedBox(height: 5),
                              Text('Cost: ${MyOgaFormatter.currencyFormatter(
                                  double.parse(
                                      requestController.requestHistory[index]
                                          .amount!))}', style: Theme
                                  .of(context)
                                  .textTheme
                                  .labelMedium),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          InkWell(
                            onTap: requestController.acceptedBookingList
                                .length < 3 ? () async {
                              final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: requestController.requestHistory[index].bookingNumber).get();
                              if(snapshot.docs.isNotEmpty){
                                if(requestController.requestHistory.contains(requestController.requestHistory[index])){
                                  if (requestController.acceptedBookingList.any((
                                      element) =>
                                  element.deliveryMode == 'Express')) {
                                    if (requestController.requestHistory[index]
                                        .deliveryMode == 'Express') {
                                      Get.snackbar(
                                          "Error",
                                          "You can only take one express booking",
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: Colors.white,
                                          colorText: Colors.red);
                                    } else {
                                      await requestController.updateDetail(
                                          requestController.requestHistory[index]
                                              .bookingNumber);
                                      if (mounted) {
                                        showAcceptModalBottomSheet(context,
                                            requestController
                                                .requestHistory[index]);
                                      }
                                      requestController.removePendingBookings(
                                          requestController.requestHistory[index]
                                              .bookingNumber!);
                                    }
                                  } else {
                                    await requestController.updateDetail(
                                        requestController.requestHistory[index]
                                            .bookingNumber);
                                    if (mounted) {
                                      showAcceptModalBottomSheet(context,
                                          requestController.requestHistory[index]);
                                    }
                                    requestController.removePendingBookings(
                                        requestController.requestHistory[index]
                                            .bookingNumber!);
                                  }
                                }else{
                                  Get.snackbar("Error", "This booking is no longer available", colorText: Colors.redAccent, backgroundColor: Colors.white);
                                }
                              }else{
                                Get.snackbar("Error", "Booking has been cancelled", colorText: Colors.redAccent, backgroundColor: Colors.white);
                              }

                            } : () {
                              Get.snackbar(
                                "Error",
                                "You cannot accept more than 3 bookings",
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.white,
                                colorText: Colors.red,
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: PButtonColor
                                ),
                                child: Text('Accept'.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12
                                    ))),
                          )
                        ]
                    ),
                    // Add more details as needed
                    // Add a button to accept the request
                    // onPressed: () => acceptRequest(pendingBookings[index]),
                  ),
                );
              },
            ),
          );
            }
          )
    );
  }
}
