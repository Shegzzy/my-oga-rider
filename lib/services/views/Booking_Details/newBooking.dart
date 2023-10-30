import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestController.getBookingDataByNum(widget.bNum).listen((event) {
      _incomingRequest = event;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Booking"),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 50.0,),
            Text("New Booking Request", style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 20,),
            Row(
              children: [
                const Icon(LineAwesomeIcons.street_view),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      //borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Pickup: ${_incomingRequest?.pickup_address??""}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      //borderRadius: BorderRadius.circular(1.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Drop-Off: ${_incomingRequest?.dropOff_address??""}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
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
                Text( _incomingRequest?.distance??"", style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(width: 20,),
                Text(MyOgaFormatter.currencyFormatter(double.parse(_incomingRequest?.amount??"")), style: Theme.of(context).textTheme.bodyMedium,),
              ],
            ),
            const SizedBox(height: 35,),
            Text("Payment Method", style: Theme.of(context).textTheme.titleLarge,),
            const SizedBox(height: 10,),
            Text(_incomingRequest?.payment_method??"", style: Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 35,),
            Column(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.back();
                    },
                    style: Theme.of(context).outlinedButtonTheme.style,
                    child: Text("Cancel".toUpperCase()),
                  ),
                ),
                const SizedBox(
                  height: 18.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _requestController.updateDetail(_incomingRequest?.bookingNumber);
                      showAcceptModalBottomSheet(context, _incomingRequest!);

                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Text("Accept".toUpperCase()),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
