import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/widgets/custom_btn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../../utils/formatter/formatter.dart';
import '../../controller/getx_switch_state.dart';
import '../../controller/request_controller.dart';
import '../../controller/signup_controller.dart';
import '../../model/booking_model.dart';
import '../../model/order_status_model.dart';
import '../Accepted_Request_Screen/accepted_screen.dart';
import '../Order_Status/order_status.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with WidgetsBindingObserver{

  final Completer<GoogleMapController> _controllerGoogleMap = Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  late var timer;
  BookingModel? currentRequest;

  late Position currentPosition;
  late Stream queryData;
  var geoLocator = Geolocator();
  final _db = FirebaseFirestore.instance;
  final getController = Get.put(GetXSwitchState());
  final userController = Get.put(SignUpController());
  FirestoreService requestController = FirestoreService();
  List<Placemark>? placeMarks;

  void locatePosition() async {
    ///Asking Users Permission
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    placeMarks = await placemarkFromCoordinates(currentPosition.latitude, currentPosition.longitude);
    Placemark pMark = placeMarks![0];

    String driverLocation = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    Map<String,dynamic> locationData = {
      'Driver Latitude': currentPosition.latitude.toString(),
      'Driver Longitude': currentPosition.longitude.toString(),
      'Driver Address': driverLocation,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    await FirebaseFirestore.instance.collection('Drivers').doc(userID).set(locationData,SetOptions(merge: true));
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  blackThemeGoogleMap () {
    newGoogleMapController.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  // Function to calculate distance between two points using Haversine formula
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    const R = 6371.0; // Earth radius in kilometers

    final double dLat = _toRadians(endLat - startLat);
    final double dLng = _toRadians(endLng - startLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) * sin(dLng / 2) * sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double result = R * c;
    return result.roundToDouble();
  }

  // Helper function to convert degrees to radians
  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  DateTime? lastNotificationTime;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestController.loadAcceptedBookings();
    timer = Timer.periodic(const Duration(seconds: 30), (timer) async {

      if (requestController.acceptedBookingList.length < 3) {
        for(int i = 0; i < requestController.acceptedBookingList.length; i++){
          print(requestController.acceptedBookingList[i].deliveryMode);
        }
        // Listen to updates in the stream of pending booking requests
        requestController.getBookingData().listen((List<BookingModel> bookingList) async {
          if (bookingList.isNotEmpty) {
            // Take the latest pending booking request
            for (final latestRequest in bookingList) {
              if (latestRequest != null) {
                setState(() {
                  currentRequest = latestRequest;
                });

                // Check if the distance between rider and pickup is below a threshold
                final double distanceThreshold = 5.0;

                final double riderLat = currentPosition.latitude;
                final double riderLng = currentPosition.longitude;
                final double pickupLng = double.parse(latestRequest.pickUp_longitude!);
                final double pickupLat = double.parse(latestRequest.pickUp_latitude!);

                final double distance = calculateDistance(riderLat, riderLng, pickupLat, pickupLng);
                print(distance);

                // String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${currentPosition.latitude},${currentPosition.longitude}&destination=${latestRequest.pickUp_latitude},${latestRequest.pickUp_longitude}&key=AIzaSyBnh_SIURwYz-4HuEtvm-0B3AlWt0FKPbM";
                // http.Response response = await http.get(Uri.parse(directionUrl));
                // if (response.statusCode == 200) {
                //   // Parse the response body into a map
                //   Map<String, dynamic> responseData = json.decode(response.body);
                //
                //   // Access the required distance value
                //   int distanceValue = responseData['routes'][0]['legs'][0]['distance']['value'];
                //   print("Distance: $distanceValue meters");
                // } else {
                //   print("Failed to fetch directions. Status code: ${response.statusCode}");
                // }

                // Checking if the booking is not a duplicate, if the booking is within proximity and if enough time has passed since the last notification
                if (distance <= distanceThreshold && !requestController.requestHistory.any((previousRequest) => previousRequest.bookingNumber == latestRequest.bookingNumber) &&
                    (lastNotificationTime == null || DateTime.now().difference(lastNotificationTime!) > const Duration(seconds: 35))) {
                  setState(() {
                    requestController.requestHistory.add(latestRequest);
                  });

                  showBookingNotification(context, latestRequest);

                  // Update the timestamp of the last shown notification
                  lastNotificationTime = DateTime.now();
                }
              }
            }
          }
        });
      } else {
        return;
      }
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) return;

    final isDetached = state == AppLifecycleState.detached;

    if(isDetached){
      getController.switchDataController.write('isSwitched', false);
      timer.stop;
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    WidgetsBinding.instance.addObserver(this);
  }


  void _startRefreshTimer() {
    timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        showBookingNotification(context, currentRequest!);
      });
    });
  }

  void _stopRefreshTimer() {
    timer.cancel();
  }

  Future<void>showBookingNotification(BuildContext context, BookingModel incomingRequest) async {
    return await showDialog(context: context, builder: (context){
      return StatefulBuilder(builder: (context, setState){
        return AlertDialog(
          content: Container(
            width: double.infinity,
            height: 430,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.0),
            ),
            child: Column(
              children: [
                Text("New Booking Request", style: Theme.of(context).textTheme.bodyLarge,),
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
                          child: Text("Pickup",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          //borderRadius: BorderRadius.circular(1.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(incomingRequest.pickup_address??"",
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
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
                          child: Text("Drop-Off",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          //borderRadius: BorderRadius.circular(1.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(incomingRequest.dropOff_address??"",
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
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
                    Text('Distance: ${incomingRequest.distance ?? ""}', style: Theme.of(context).textTheme.bodyMedium,),
                    const SizedBox(width: 20,),
                    Text('Cost: ${MyOgaFormatter.currencyFormatter(double.parse(incomingRequest.amount ?? ""))}', style: Theme.of(context).textTheme.bodyMedium,),
                  ],
                ),
                const SizedBox(height: 35,),
                Text("Payment Method:", style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 10,),
                Text(incomingRequest.payment_method??"", style: Theme.of(context).textTheme.bodyLarge,),

                const SizedBox(height: 15,),
                Text("Delivery Mode:", style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 10,),
                Text(incomingRequest.deliveryMode??"", style: Theme.of(context).textTheme.bodyLarge,),

                const SizedBox(height: 10),
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
                          if(requestController.acceptedBookingList.any((element) => element.deliveryMode == 'Express')){
                            if(incomingRequest.deliveryMode == 'Express'){
                              Get.snackbar(
                                  "Error", "You can only take one express booking",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.white,
                                  colorText: Colors.red);
                            }else {
                              await requestController.updateDetail(incomingRequest.bookingNumber);
                              showAcceptModalBottomSheet(context, incomingRequest);
                              requestController.removePendingBookings(incomingRequest.bookingNumber!);
                            }
                          }else {
                            await requestController.updateDetail(incomingRequest.bookingNumber);
                            showAcceptModalBottomSheet(context, incomingRequest);
                            requestController.removePendingBookings(incomingRequest.bookingNumber!);
                          }
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
      });
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
            ///Start Circular Progress Bar
            showDialog(
                context: context,
                builder: (context){
                  return const Center(child: CircularProgressIndicator());
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
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 20),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              locatePosition();
            },
          ),
          Positioned(
            right: 100,
            left: 100,
            top: 50,
            child: Obx(() => LiteRollingSwitch(
                //initial value
                value: getController.isOnline.value,
                textOn: 'Online',
                textOff: 'Offline',
                colorOn: const Color(0xFF00E676),
                colorOff: const Color(0xFFFF5252),
                iconOn: Icons.done,
                iconOff: Icons.remove_circle_outline,
                textSize: 16.0,
                onChanged: (bool state) async {
                  getController.changeSwitchState(state);
                  if(state == true){
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final userID = prefs.getString("UserID")!;
                    await _db.collection("Drivers")
                        .doc(userID)
                        .update({'Online': '1'});
                  } else if(state == false){
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final userID = prefs.getString("UserID")!;
                    await _db.collection("Drivers")
                        .doc(userID)
                        .update({'Online': '0'});
                  }else {
                    return;
                  }
                },
                onTap: (){},
                onDoubleTap: (){
                  //showBookingNotification(context);
                },
                onSwipe: (){
                  //showBookingNotification(context);
                },
              ),
            ),
          ),
          Positioned(
            right: 325,
            top: 65,
            child: GestureDetector(
                onTap: (){
                  Get.to(_buildPendingBookings(context, ));
                },
                child: Icon(Icons.notifications, color: PButtonColor,))
          ),
          Positioned(
              right: 325,
              top: 65,
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade500
                ),
                child: Center(
                    child: Text('${requestController.requestHistory.length}',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),)),
              )
            )
        ],
      ),
    );
  }

  Widget _buildPendingBookings(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
        centerTitle: true,
      ),
      body: Padding(
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
                    Text('Pickup Address: ${requestController.requestHistory[index].pickup_address!}'),
                    const SizedBox(height: 10,),
                    Text('DropOff Address: ${requestController.requestHistory[index].dropOff_address!}'),

                  ],
                ),
                subtitle: Column(
                  children: [
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Mode: ${requestController.requestHistory[index].deliveryMode!}'),
                        Text('Distance: ${requestController.requestHistory[index].distance!}'),
                        Text('Cost: ${MyOgaFormatter.currencyFormatter(double.parse(requestController.requestHistory[index].amount!))}')
                      ],
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () async{
                        if(requestController.requestHistory.any((element) =>
                          element.bookingNumber == currentRequest!.bookingNumber
                        )){
                          await requestController.updateDetail(requestController.requestHistory[index].bookingNumber);
                          if(mounted){
                            // requestController.addAcceptedBooking(requestHistory[index]);
                            showAcceptModalBottomSheet(context, requestController.requestHistory[index]);
                          }
                          requestController.removePendingBookings(requestController.requestHistory[index].bookingNumber!);
                          print(requestController.requestHistory[index].bookingNumber);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: PButtonColor
                        ),
                        child: Text('Accept'.toUpperCase(), style: const TextStyle(
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
      ),
    );
  }
}
