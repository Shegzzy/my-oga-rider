import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/controller/request_controller.dart';
import 'package:my_oga_rider/services/views/Tab_Pages/bookings_tab.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
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


  @override
  void initState() {
    super.initState();
    _startListeningToBookingStatusChanges();
    _userRepo.getUserDetailsWithPhone(bookingData.customer_phone!).then((value) {
      setState(() {
        _bookerModel = value;
      });
    });
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

  Future<void>showDriverDialog(BuildContext context) async {
    return await showDialog(context: context, builder: (context){
      var isDark = getXSwitchState.isDarkMode;
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          content: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: isDark ? Colors.black12.withOpacity(0.01) : Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          if (loadingProgress == null)
                            return child;
                          return const Center(
                              child:
                              CircularProgressIndicator());
                        },
                        errorBuilder:
                            (context, object, stack) {
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.red,
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
                const Icon(LineAwesomeIcons.phone, color: moAccentColor, size: 30,),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(result: true), icon: const Icon(LineAwesomeIcons.angle_left)),
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
                    Flexible(
                      child: TextButton(
                        child: const Text("View on Map",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                        onPressed: () {
                          Get.to(() => NavigationScreen(double.parse(bookingData.pickUp_latitude!), double.parse(bookingData.pickUp_longitude!)));
                        },),
                    ),
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
                    Flexible(
                      child: TextButton(
                        child: const Text("View on Map",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                        onPressed: () {
                          Get.to(() => NavigationScreen(double.parse(bookingData.dropOff_latitude!), double.parse(bookingData.dropOff_longitude!)));
                        },),
                    ),
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
                    Flexible(
                      child: Text("Status: ${bookingModel?.status}",
                        style: theme.textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,),
                    ),
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
                        child: const Text("View Customer Details",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                        onPressed: () {
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