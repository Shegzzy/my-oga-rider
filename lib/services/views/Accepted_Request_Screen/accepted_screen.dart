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
  final _db = FirebaseFirestore.instance;
  int counter = 0;
  double rate = 0;
  double _total = 0;
  double _average = 0;
  List<double> ratings = [0.1, 0.3, 0.5, 0.7, 0.9];
  bool loadingCustomer = false;



  @override
  void initState() {
    getCustomerDetails();
    super.initState();

  }

  Future<void> getCustomerDetails() async{
    try{
      setState(() {
        loadingCustomer = true;
      });

      _userRepo.getUserDetailsWithID(bookingData!.customer_id!).then((value) {
        setState(() {
          _bookerModel = value;
        });
      });
      await getRatingCount();

    }catch(e){
      print('Error $e');
    }finally{
      setState(() {
        loadingCustomer = false;
      });
    }
  }

  Future<void> getRatingCount() async{
    await _db.collection("Users").doc(bookingData!.customer_id!).collection("Ratings").get().then((value) {
      for (var element in value.docs) {
        rate = element.data()["rating"];
        setState(() {
          _total = _total + rate;
          counter = counter+1;
        });
      }
    });
    _average = _total/counter;
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
          loadingCustomer ?
              const Center(child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(),)) :
              Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("BOOKING DETAILS", style: Theme.of(context).textTheme.titleLarge,)),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    return const Icon(Icons.person_2_rounded, color: Colors.grey,);
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
                        const SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Ratings: ${_average.toStringAsFixed(1)}", style: theme.textTheme.titleSmall,),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: _average < 3.5 ? Colors.redAccent : Colors.green,
                            )
                          ],
                        ),
                      ],
                    ),

                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    'Package: ${bookingData!.packageType ?? ""}', style: theme.textTheme.titleLarge,),
                    const SizedBox(width: 4,),
                    Text('Delivery Mode: ${bookingData!.deliveryMode}', style: theme.textTheme.titleLarge, maxLines: 2,
                    overflow: TextOverflow.ellipsis,),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cost: ${MyOgaFormatter.currencyFormatter(double.parse(bookingData!.amount??""))}', style: theme.textTheme.titleLarge,),
                    const SizedBox(height: 10,),
                    Text('Distance: ${bookingData!.distance??""}', style: theme.textTheme.titleLarge,),
                  ],
                ),
                const SizedBox(height: 10,),
                Center(child: Text("Payment Mode: ${bookingData!.payment_method}", style: theme.textTheme.titleLarge,)),
                const SizedBox(height: 15,),
                Text("Pick Up", style: theme.textTheme.bodyLarge,),
                const SizedBox(height: 5,),
                Text(bookingData!.pickup_address??"", style: theme.textTheme.titleLarge,),
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
