import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/constant/image_string.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';

import '../../../constant/colors.dart';
import 'package:get/get.dart';
import '../../../constant/text_strings.dart';
import '../../../repo/user_repo.dart';
import '../../model/booker_model.dart';
import '../../model/booking_model.dart';
import '../Dashboard/appbar.dart';
import '../Order_Status/order_status.dart';

class AcceptScreen extends StatefulWidget {
  AcceptScreen({Key? key,
    required this.btnClicked,
    required this.bookingData,

    }) : super(key: key);

  Function() btnClicked;
  BookingModel? bookingData;

  @override
  State<AcceptScreen> createState() => _AcceptScreenState(btnClicked: btnClicked, bookingData: bookingData);
}

class _AcceptScreenState extends State<AcceptScreen> {
  BookingModel? bookingData;
  _AcceptScreenState({required this.bookingData, required Function() btnClicked});

  String? docId;
  final _userRepo = Get.put(UserRepository());

  BookerModel? _bookerModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userRepo.getUserDetailsWithPhone(bookingData!.customer_phone!).then((value) {
      setState(() {
        _bookerModel = value;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return  Stack(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("BOOKING DETAILS", style: Theme.of(context).textTheme.titleLarge,)),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 60.0,
                      height: 60.0,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:  _bookerModel?.profilePic == null
                                ? const Icon(LineAwesomeIcons.user_circle, size: 35,)
                                : Image(image: NetworkImage( _bookerModel!.profilePic!),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress){
                                  if(loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (context, object, stack){
                                    return const Icon(Icons.error_outline, color: Colors.red,);
                                  },
                                )
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(bookingData!.customer_name??"", style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 5,),
                        Text(bookingData!.customer_phone??"", style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 5,),
                        Text("Booking Number: ${bookingData!.bookingNumber}", style: theme.textTheme.titleSmall,),
                      ],
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(MyOgaFormatter.currencyFormatter(double.parse(bookingData!.amount??"")), style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 10,),
                        Text(bookingData!.distance??"", style: theme.textTheme.titleSmall,),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(bookingData!.packageType??"", style: theme.textTheme.headline6,),
                    const SizedBox(width: 4,),
                    Text(bookingData!.deliveryMode == "1" ? "Express (24hrs)" : "Normal (8hrs)", style: theme.textTheme.headline6, maxLines: 2,
                    overflow: TextOverflow.ellipsis,),
                  ],
                ),
                const SizedBox(height: 10,),
                Center(child: Text("Payment Mode: ${bookingData!.payment_method}", style: theme.textTheme.headline6,)),
                const SizedBox(height: 15,),
                Text("Pick Up", style: theme.textTheme.bodyText1,),
                const SizedBox(height: 5,),
                Text(bookingData!.pickup_address??"", style: theme.textTheme.headline6,),
                const SizedBox(height: 15,),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(height: 15,),
                Text("Drop Off", style: theme.textTheme.bodyLarge,),
                const SizedBox(height: 5,),
                Text(bookingData!.dropOff_address??"", style: theme.textTheme.titleLarge,),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.btnClicked,
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: Text(moStartService.toUpperCase()),
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
        ],
    );
  }
}
