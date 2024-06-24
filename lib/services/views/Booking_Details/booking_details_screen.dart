import 'dart:async';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/controller/request_controller.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/bookings_tab.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../../repo/user_repo.dart';
import '../../controller/getx_switch_state.dart';
import '../../controller/profile_controller.dart';
import '../../model/booker_model.dart';
import '../../model/booking_model.dart';
import '../../model/usermodel.dart';
import '../Navigtion_Screen/navigation_screen.dart';
import '../Order_Status/order_status.dart';
import '../Rating_Screen/rating_screen.dart';



class BookingDetailsScreen extends StatefulWidget {
  final BookingModel bookingData;
  const BookingDetailsScreen({Key? key, required this.bookingData}) : super(key: key);


  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState(bookingData: this.bookingData);
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final BookingModel bookingData;
  _BookingDetailsScreenState({required this.bookingData});

  ProfileController controller = Get.put(ProfileController());
  final _userRepo = Get.put(UserRepository());
  final GetXSwitchState getXSwitchState = Get.find();
  BookingModel? bookingModel;


  BookerModel? _bookerModel;
  FirestoreService fireStoreService = Get.find();
  late StreamSubscription<BookingModel> _bookingStatusSubscription;
  int counter = 0;
  double rate = 0;
  double _total = 0;
  double _average = 0;
  List<double> ratings = [0.1, 0.3, 0.5, 0.7, 0.9];
  final _db = FirebaseFirestore.instance;
  bool loadingCustomer = false;


  @override
  void initState() {
    super.initState();
    getCustomerDetails();
    _startListeningToBookingStatusChanges();
  }

  @override
  void dispose() {
    _bookingStatusSubscription.cancel();
    super.dispose();
  }

  void _startListeningToBookingStatusChanges() {
    print('started');
    _bookingStatusSubscription = fireStoreService.getBookingDataByNum(bookingData.bookingNumber!).listen((event) {
      setState(() {
        bookingModel = event;
      });
    });
  }

  Future<void> fetchRider() async{

    await controller.getUserById();

    print(_userRepo.userModel?.fullname);
  }

  Future<void> getRatingCount() async{
    await _db.collection("Users").doc(bookingData.customer_id).collection("Ratings").get().then((value) {
      for (var element in value.docs) {
        rate = element.data()["rating"];
        setState(() {
          _total = _total + rate;
          counter = counter+1;
        });
      }
    });
    _average = _total/counter;
    print(_average);
  }

  Future<void> getCustomerDetails() async{
    try{
      setState(() {
        loadingCustomer = true;
      });

      await _userRepo.getUserDetailsWithID(bookingData.customer_id!).then((value) {
        setState(() {
          _bookerModel = value;
        });
      });
      await getRatingCount();
      await fetchRider();

    }catch(e){
      print('Error $e');
    }finally{
      setState(() {
        loadingCustomer = false;
      });
    }
  }

  Future<void>showDriverDialog(BuildContext context) async {
    return await showDialog(context: context, builder: (context){
      var isDark = getXSwitchState.isDarkMode;
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          content: loadingCustomer ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(),)
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Customer", style: Theme.of(context).textTheme.bodyLarge,),
              const SizedBox(height: 20,),
              SizedBox(
                width: 120.0,
                height: 120.0,
                child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(100),
                    child: _bookerModel!.profilePic == null
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
                          Icons.person_2_rounded,
                          color: Colors.blueGrey,
                        );
                      },
                    )),
              ),
              const SizedBox(width: 2,),
              Text(_bookerModel?.fullname ?? " ",
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              Text(_bookerModel?.phoneNo ?? " ",
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5,),
              const Icon(LineAwesomeIcons.phone_solid, color: moAccentColor, size: 30,),
              const SizedBox(height: 35,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ratings: ${_average.toStringAsFixed(1)}"),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _average < 3.5 ? Colors.redAccent : Colors.green,
                  )
                ],
              ),
              const SizedBox(height: 35,),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: Theme.of(context).outlinedButtonTheme.style,
                      child: Text("Cancel".toUpperCase()),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
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
                      },
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Text("Call".toUpperCase()),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      });
    });
  }

  void showStatusModalBottomSheet(BuildContext context){
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
            bookingData: bookingData,
          ),
        ),
      ),
    );
  }

  void _launchNavigation(double lat, lng) async {
    String googleMapsAndroidURL = 'google.navigation:q=${lat},${lng}&mode=d';
    String googleMapsIosURL = 'comgooglemaps://?daddr=${lat},${lng}&directionsmode=driving';
    String googleMapsWebURL = 'https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}&travelmode=driving';

    if (Platform.isAndroid && await canLaunch(googleMapsAndroidURL)) {
      await launch(googleMapsAndroidURL);
    } else if (Platform.isIOS && await canLaunch(googleMapsIosURL)) {
      await launch(googleMapsIosURL);
    } else {
      await launch(googleMapsWebURL, forceSafariVC: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(result: true), icon: const Icon(LineAwesomeIcons.angle_left_solid)),
        title: Text("Booking Details", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: Get.height,
          width: Get.width,
          padding: const EdgeInsets.all(20.0),
          child:  SizedBox(
            height: Get.height,
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("BN: ${bookingData.bookingNumber}",
                    style: theme.textTheme.headlineSmall,),
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookingData.customer_name!, style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 5,),
                        Text(bookingData.customer_phone!, style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 5,),
                      ],
                    ),
                    const SizedBox(width: 40,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(MyOgaFormatter.currencyFormatter(double.parse(bookingData.amount!)), style: theme.textTheme.titleSmall,),
                        const SizedBox(height: 10,),
                        Text("${bookingData.distance}", style: theme.textTheme.titleSmall,),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text("Package Type: ${bookingData.packageType}",
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,)),
                    Flexible(
                      child: Text("Delivery Mode: ${bookingData.deliveryMode ?? ""}",
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text("Payment Mode: ${bookingData.payment_method}",
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text("Ride Type: ${bookingData.rideType ?? ""}",
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text("Pick Up Location",
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    bookingModel?.status == 'active' ?
                    Flexible(
                      child: loadingCustomer ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(),)
                          : TextButton(
                        child: Text("View on Map",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark ? Colors.amberAccent : PButtonColor
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => NavigationScreen(
                            lat: double.parse(bookingData.pickUp_latitude!),
                            lng: double.parse(bookingData.pickUp_longitude!),
                            riderLat: double.parse(_userRepo.userModel!.currentLat!),
                            riderLng: double.parse(_userRepo.userModel!.currentLong!),
                          ));
                        },),
                    )
                      :const Text(''),
                  ],
                ),
                Text(bookingData.pickup_address??"", style: theme.textTheme.titleLarge,),
                const SizedBox(height: 15,),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text("Drop Off Location",
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    bookingModel?.status == 'active' ?
                    Flexible(
                      child: loadingCustomer ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(),)
                          : TextButton(
                        child: Text("View on Map",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark ? Colors.amberAccent : PButtonColor
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => NavigationScreen(
                            lat: double.parse(bookingData.dropOff_latitude!),
                            lng: double.parse(bookingData.dropOff_longitude!),
                            riderLat: double.parse(_userRepo.userModel!.currentLat!),
                            riderLng: double.parse(_userRepo.userModel!.currentLong!),
                          ));
                          // _launchNavigation(double.parse(bookingData.dropOff_latitude!), double.parse(bookingData.dropOff_longitude!));
                        },),
                    )
                      :const Text(''),
                  ],
                ),

                const SizedBox(height: 5,),
                Text(bookingData.dropOff_address??"", style: theme.textTheme.titleLarge,),
                const SizedBox(height: 15),
                const Divider(
                  color: Colors.black,
                  height: 2,
                  thickness: 1,
                  indent: 2,
                  endIndent: 2,
                ),

                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text("Date Created: ${MyOgaFormatter.dateFormatter(DateTime.parse(bookingData.created_at!))}",
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    if(bookingModel?.status == 'active')...[
                      Flexible(
                        child: Text("Status: ${bookingModel?.status}",
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ]else if(bookingModel?.status == 'completed' && bookingModel?.rateUser == '0' || bookingModel?.rateUser == null)...[
                      Flexible(child: TextButton(
                        child: Text(
                          "Rate User",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark ? Colors.amberAccent : PButtonColor
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RatingScreen(
                                    userID: bookingData.customer_id!,
                                    bookingID: bookingData.bookingNumber!,
                                  )));
                        },
                      ))
                    ]else if(bookingModel?.status == 'completed' && bookingModel?.rateUser == '1' || bookingModel?.rateUser != null)...[
                      Flexible(
                        child: Text("Status: ${bookingModel?.status}",
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ],

                  ],
                ),

                const SizedBox(height: 20),
                Flexible(child: Text("Additional Details: ${bookingData.additional_details}", style: theme.textTheme.titleLarge, maxLines: 3, overflow: TextOverflow.ellipsis,)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text("Customer Details",
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 10,),
                    Flexible(
                      child: TextButton(
                        child: Text("View Customer Details",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark ? Colors.amberAccent : PButtonColor
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            showDriverDialog(context);
                          });
                        },),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (){
                          showStatusModalBottomSheet(context);
                        },
                        style: Theme
                            .of(context)
                            .elevatedButtonTheme
                            .style,
                        child: Text("Go to Order Status".toUpperCase()),
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
        ),
      ),
    );
  }
}