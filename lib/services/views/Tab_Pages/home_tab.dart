import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:my_oga_rider/services/views/Pending_Bookings/pending_bookings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constant/colors.dart';
import '../../../utils/formatter/formatter.dart';
import '../../controller/getx_switch_state.dart';
import '../../controller/request_controller.dart';
import '../../controller/signup_controller.dart';
import '../../model/booking_model.dart';
import '../../model/order_status_model.dart';
import '../Accepted_Request_Screen/accepted_screen.dart';
import '../Order_Status/order_status.dart';
import 'package:location/location.dart' as loc;



class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> with WidgetsBindingObserver {

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;
  final GetXSwitchState getXSwitchState = Get.find();

  late Timer timer;
  late Timer statusCheckTimer;

  BookingModel? currentRequest;

  late Position currentPosition;
  late Stream queryData;
  var geoLocator = Geolocator();
  final _db = FirebaseFirestore.instance;
  final getController = Get.put(GetXSwitchState());
  final userController = Get.put(SignUpController());
  FirestoreService requestController = Get.find();
  List<Placemark>? placeMarks;
  Marker? myPosition;
  bool markerLoading = false;
  int counter = 0;
  double rate = 0;
  double total = 0;
  double average = 0;
  List<double> ratings = [0.1, 0.3, 0.5, 0.7, 0.9];
  bool loadingCustomer = false;
  BitmapDescriptor? markerIcon;
  Set<Circle> _circles = {};
  StreamSubscription<DocumentSnapshot>? _subscription;
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? lastFireStoreUpdateTime;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 15.4746,
  );

  // loading marker
  Future<void> _loadMarkerIcon() async {
    String imgurl = "https://cdn-icons-png.freepik.com/256/5458/5458280.png?ga=GA1.1.691408758.1706907328&semt=ais";
    Uint8List? smallImg = await loadAndResizeImage(imgurl, 80, 80);
    if (smallImg != null) {
      setState(() {
        markerIcon = BitmapDescriptor.fromBytes(smallImg);
      });
    }
  }

  // resizing marker
  Future<Uint8List?> loadAndResizeImage(String url, int width, int height) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      img.Image? image = img.decodeImage(response.bodyBytes);
      if (image != null) {
        img.Image resizedImage = img.copyResize(image, width: width, height: height);
        return Uint8List.fromList(img.encodePng(resizedImage));
      }
    }
    return null;
  }

  // getting current location
  Future<void> locatePosition() async {
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 15.4746);
    newGoogleMapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    placeMarks = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);
    Placemark pMark = placeMarks![0];

    String driverLocation = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    setState(() {
      myPosition = Marker(
        markerId: const MarkerId('source'),
        draggable: true,
        position: LatLng(currentPosition.latitude, currentPosition.longitude),
        icon: markerIcon!,
      );
    });

    _startRefreshTimer();
    // _fetchHeatmapData();

    // Update location in FireStore
    Map<String, dynamic> locationData = {
      'Driver Latitude': currentPosition.latitude.toString(),
      'Driver Longitude': currentPosition.longitude.toString(),
      'Driver Address': driverLocation,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    await FirebaseFirestore.instance.collection('Drivers').doc(userID).set(
        locationData, SetOptions(merge: true));
  }

  // listening to current location
  void _startLocationUpdates() {
    // loc.Location location = loc.Location();
    // location.enableBackgroundMode(enable: true);
    // location.onLocationChanged.listen((event) {
    //   print(event.longitude);
    //   print(event.latitude);
    // });
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) async {
        if (mounted) {
          try {
            if (markerIcon != null) {
              setState(() {
                currentPosition = position;
                myPosition = Marker(
                  markerId: const MarkerId('source'),
                  draggable: true,
                  position: LatLng(position.latitude, position.longitude),
                  icon: markerIcon!,
                );
              });

              // Update camera position for real-time tracking
              // newGoogleMapController.animateCamera(
              //   CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
              // );

              // Update Firestore with the new position
              await _updatePosition(position);
            } else {
              // Handle the case where markerIcon is not initialized
              print("Marker icon is not initialized.");
            }
          } catch (error) {
            // Handle any errors that occur during the async operations
            print("Error occurred during location update: $error");
          }
        }
      },
      onError: (error) {
        // Handle stream errors
        print("Error in position stream: $error");
      },
    );
  }

  // updating current location
  Future<void> _updatePosition(Position position) async {
    DateTime now = DateTime.now();

    if (lastFireStoreUpdateTime == null || now.difference(lastFireStoreUpdateTime!).inMinutes > 1) {
      lastFireStoreUpdateTime = now;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString("UserID")!;

      // Obtain the new location data
      String driverLocation = await _getDriverLocation(position);

      Map<String, dynamic> locationData = {
        'Driver Latitude': position.latitude.toString(),
        'Driver Longitude': position.longitude.toString(),
        'Driver Address': driverLocation,
      };

      // Update Firestore
      await _db.collection('Drivers').doc(userID).set(
          locationData, SetOptions(merge: true));
    }

  }

  // fetching current location
  Future<String> _getDriverLocation(Position position) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark pMark = placeMarks[0];

    return '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
  }

  // Fetch heatmap data from the Firebase Cloud Function
  void _fetchHeatmapData() {
    _subscription = FirebaseFirestore.instance
        .collection('Heatmaps')
        .doc('current')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('data')) {
          List<dynamic> heatmapData = data['data'];
          _generateHeatmap(heatmapData);
        }
      }
    });
  }

  // Generate the heatmap from the fetched data
  void _generateHeatmap(List<dynamic> data) {
    Set<Circle> circles = {};
    double maxWeight = data.map((point) => point['weight'].toDouble()).reduce((a, b) => a > b ? a : b);
    for (var point in data) {
      double intensity = point['weight'].toDouble();
      double normalizedIntensity = intensity / maxWeight;
      // print(intensity);
      Color color;
      if (intensity < 5) {
        color = Colors.green.withOpacity(0.5);
      } else if (intensity < 11) {
        color = Colors.yellow.withOpacity(0.5);
      } else {
        color = Colors.redAccent.withOpacity(0.5);
      }

      circles.add(Circle(
        circleId: CircleId('${point['location']['lat']}_${point['location']['lng']}'),
        center: LatLng(point['location']['lat'], point['location']['lng']),
        radius: 5000,
        fillColor: color,
        strokeColor: color.withOpacity(0.1),
        strokeWidth: 1,
      ));
    }
    setState(() {
      _circles = circles;
    });
  }


  blackThemeGoogleMap() {
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
    const R = 6371.0;

    final double dLat = _toRadians(endLat - startLat);
    final double dLng = _toRadians(endLng - startLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) * sin(dLng / 2) *
            sin(dLng / 2);

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
    _loadMarkerIcon();
    _startLocationUpdates();
    // requestController.loadAcceptedBookings();
    requestController.loadPendingBookings();
    requestController.fetchAcceptedRequests();
    statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) async {
          // print(requestController.requestHistory.length);
          // print(requestController.acceptedBookingList.length);
          await checkAndUpdateBookingStatus();
          await checkAndUpdateAcceptedBooking();

        });
    _fetchHeatmapData();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) return;

    final isDetached = state == AppLifecycleState.detached;

    if (isDetached) {
      getController.switchDataController.write('isSwitched', false);
      timer.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addObserver(this);
    statusCheckTimer.cancel();
    if(timer.isActive){
      _stopRefreshTimer();
    }else{
      return;
    }
    _subscription?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // listening for new booking requests
  void _startRefreshTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {

      if (requestController.acceptedRequests.length < 3) {
        // for(int i = 0; i < requestController.acceptedBookingList.length; i++){
        //   print(requestController.acceptedBookingList[i].deliveryMode);
        // }
        // Listen to updates in the stream of pending booking requests
        requestController.getBookingData().listen((
            List<BookingModel> bookingList) async {
          if (bookingList.isNotEmpty) {
            // Take the latest pending booking request
            for (final latestRequest in bookingList) {
              if (latestRequest != null) {
                if(mounted){
                  setState(() {
                    currentRequest = latestRequest;
                  });
                }

                // Check if the distance between rider and pickup is below a threshold
                const double distanceThreshold = 8.0;

                final double riderLat = currentPosition.latitude;
                final double riderLng = currentPosition.longitude;
                final double pickupLng = double.parse(
                    latestRequest.pickUp_longitude!);
                final double pickupLat = double.parse(
                    latestRequest.pickUp_latitude!);

                final double distance = calculateDistance(
                    riderLat, riderLng, pickupLat, pickupLng);

                // Checking if the booking is not a duplicate, if the booking is within proximity and if enough time has passed since the last notification
                if (distance <= distanceThreshold &&
                    !requestController.requestHistory.any((previousRequest) =>
                    previousRequest.bookingNumber ==
                        latestRequest.bookingNumber) &&
                    (lastNotificationTime == null ||
                        DateTime.now().difference(lastNotificationTime!) >
                            const Duration(seconds: 35))) {
                  setState(() {
                    requestController.addPendingBooking(latestRequest);
                  });

                  await getRatingCount(latestRequest.customer_id!);

                  if(mounted){
                    showBookingNotification(context, latestRequest);
                  }

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

  void _stopRefreshTimer() {
    timer.cancel();
  }

  // Getting customer ratings
  Future<void> getRatingCount(String? customerID) async{

    try{
      setState(() {
        loadingCustomer = true;
      });
      await _db.collection("Users").doc(customerID).collection("Ratings").get().then((value) {
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

  // Method to check if pending booking have been accepted by another rider
  Future<void> checkAndUpdateBookingStatus() async {
    // setting a temporary list for bookings to be removed
    List<BookingModel> bookingsToRemove = [];

    for (var booking in requestController.requestHistory) {
      var querySnapshot = await _db
          .collection("Bookings")
          .where("Booking Number", isEqualTo: booking.bookingNumber)
          .get();
      // print(booking.bookingNumber);

      if (querySnapshot.docs.isNotEmpty) {
        var snapshot = querySnapshot.docs.first;
        var bookingStatus = snapshot.data()['Status'];

        if (bookingStatus == 'active') {
          bookingsToRemove.add(booking);
        }
      } else if(querySnapshot.docs.isEmpty){
        bookingsToRemove.add(booking);
      }
    }

    // Remove the bookings outside the iteration
    if(mounted){
      setState(() {
        for (var booking in bookingsToRemove) {
          requestController.requestHistory.remove(booking);
        }
        requestController.savePendingBookings();
        requestController.loadPendingBookings();
      });
    }else{
      return;
    }
  }

  // Method to check if accepted booking have been canceled by users
  Future<void> checkAndUpdateAcceptedBooking() async {
    // Collect bookings to remove in a separate list
    List<Map<String, dynamic>> bookingsToRemove = [];

    for (var bookings in requestController.acceptedRequests) {
      var querySnapshot = await _db
          .collection("Bookings")
          .where("Booking Number", isEqualTo: bookings['request_id'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        bookingsToRemove.add(bookings);
      }
    }

    // Remove the bookings outside the iteration
    for (var bookings in bookingsToRemove) {
      await requestController.completedOrDeletedRequest(bookings['request_id']);
      // setState(() {
      //   requestController.removeCompletedBooking(bookings['request_id']);
      // });
    }
  }



  Future<void> showBookingNotification(BuildContext context, BookingModel incomingRequest) async {
    var isDark = getXSwitchState.isDarkMode;
    bool isLoading = false;
    return await showDialog(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("New Booking Request", style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,),
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
                      child: Text("Pickup",
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(incomingRequest.pickup_address ?? "",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyLarge,
                        overflow: TextOverflow.ellipsis,
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
                      child: Text("Drop-Off",
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(incomingRequest.dropOff_address ?? "",
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyLarge,
                        overflow: TextOverflow.ellipsis,
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
                  Text('Distance: ${incomingRequest.distance ?? ""}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium,),
                  const SizedBox(width: 20,),
                  Text('Cost: ${MyOgaFormatter.currencyFormatter(
                      double.parse(incomingRequest.amount ?? ""))}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium,),
                ],
              ),
              const SizedBox(height: 20,),
              Text("Payment Method:", style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,),
              const SizedBox(height: 5,),
              Text(incomingRequest.payment_method ?? "", style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,),

              const SizedBox(height: 10,),
              Text("Delivery Mode:", style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,),
              const SizedBox(height: 5,),
              Text(incomingRequest.deliveryMode ?? "", style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,),

              const SizedBox(height: 10,),
              Text("Ride Type:", style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,),
              const SizedBox(height: 5,),
              Text(incomingRequest.rideType ?? "", style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,),

              const SizedBox(height: 10),
              loadingCustomer ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(),) :
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("User Ratings: ${average.toStringAsFixed(1)}", style: Theme
                      .of(context)
                      .textTheme.titleSmall,),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: average < 3.5 ? Colors.redAccent : Colors.green,
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: Theme
                          .of(context)
                          .outlinedButtonTheme
                          .style,
                      child: Text("Cancel".toUpperCase()),
                    ),
                  ),
                  const SizedBox(width: 10.0,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        setState(() {
                          isLoading = true;
                        });

                        try{

                          final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: incomingRequest.bookingNumber).get();
                          final bookingData = snapshot.docs.map((e) => BookingModel.fromSnapshot(e.data())).single;
                          if(snapshot.docs.isNotEmpty){
                            if( bookingData.status == 'pending'){
                              if (requestController.acceptedRequests.any((
                                  element) => element['type'] == 'Express')) {
                                if (incomingRequest.deliveryMode == 'Express') {
                                  Get.snackbar(
                                      "Error",
                                      "You can only take one express booking",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.white,
                                      colorText: Colors.red);
                                } else {
                                  await requestController.updateDetail(
                                      incomingRequest.bookingNumber);
                                  if (mounted) {
                                    showAcceptModalBottomSheet(
                                        context, incomingRequest);
                                  }
                                  requestController.removePendingBookings(
                                      incomingRequest.bookingNumber!);
                                }
                              } else {
                                await requestController.updateDetail(
                                    incomingRequest.bookingNumber);
                                if (mounted) {
                                  showAcceptModalBottomSheet(
                                      context, incomingRequest);
                                }
                                requestController.removePendingBookings(
                                    incomingRequest.bookingNumber!);
                              }
                            }else{
                              Get.snackbar("Error", "Booking have been accepted by another rider", colorText: Colors.redAccent, backgroundColor: Colors.white);
                              if(mounted){
                                Navigator.pop(context);
                              }
                            }

                          }else{
                            Get.snackbar("Error", "Booking has been cancelled", colorText: Colors.redAccent, backgroundColor: Colors.white);
                            if(mounted){
                              Navigator.pop(context);
                            }
                          }
                        }catch(e){
                          print('Accepting Error $e');
                        } finally{
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: Theme
                          .of(context)
                          .elevatedButtonTheme
                          .style,
                      child: isLoading ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(),)
                          : Text("Accept".toUpperCase()),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      });
    });
  }

  void showAcceptModalBottomSheet(BuildContext context, BookingModel newRequest) {
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
                    if(mounted) {
                      ///Start Circular Progress Bar
                      showDialog(context: context, builder: (context) {
                        return const Center(
                            child: CircularProgressIndicator());
                      });
                    }

                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
                    final userID = prefs.getString("UserID")!;
                    final snapshot = await _db.collection("Bookings").where("Booking Number", isEqualTo: newRequest.bookingNumber).get();
                    if(snapshot.docs.isNotEmpty){
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

                      await requestController.storeOrderStatus(order);

                      if(mounted){
                        /// Stop Progress Bar
                        Navigator.of(context).pop();
                        showStatusModalBottomSheet(context, newRequest);
                      }
                    } else{
                      Get.snackbar("Error", "This booking has been cancelled", colorText: Colors.redAccent,backgroundColor: Colors.white);
                      if(mounted){
                        Navigator.pop(context);
                      }
                    }

                  },
                    bookingData: newRequest,
                  ),
                ),
          ),
    );
  }

  void showStatusModalBottomSheet(BuildContext context, BookingModel inRequest) {
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
    var isDark = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;
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
            onMapCreated: (GoogleMapController controller) async {
              newGoogleMapController = controller;
              _controllerGoogleMap.complete(controller);
              await locatePosition();
            },
            markers: myPosition != null ? {myPosition!} : {},
            circles: _circles,
          ),
          Positioned(
            right: 100,
            left: 100,
            top: 50,
            child: Obx(() =>
                LiteRollingSwitch(
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
                    if (state == true) {
                      SharedPreferences prefs = await SharedPreferences
                          .getInstance();
                      final userID = prefs.getString("UserID")!;
                      await _db.collection("Drivers")
                          .doc(userID)
                          .update({'Online': '1'});
                    } else if (state == false) {
                      SharedPreferences prefs = await SharedPreferences
                          .getInstance();
                      final userID = prefs.getString("UserID")!;
                      await _db.collection("Drivers")
                          .doc(userID)
                          .update({'Online': '0'});
                    } else {
                      return;
                    }
                  },
                  onTap: () {},
                  onDoubleTap: () {
                    //showBookingNotification(context);
                  },
                  onSwipe: () {
                    //showBookingNotification(context);
                  },
                ),
            ),
          ),

          Positioned(
                right: 312,
                top: 55,
                child: IconButton(color: PButtonColor, onPressed: () {
                  Get.to(() => const PendingBookings());
                }, icon: const Icon(Icons.notifications, size: 25,),)
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
                      style: TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w600),)),
              )
          )
        ],
      ),
    );
  }
}

