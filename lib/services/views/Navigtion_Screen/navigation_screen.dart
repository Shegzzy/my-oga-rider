import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:image/image.dart' as IMG;

class NavigationScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final double riderLat;
  final double riderLng;

  const NavigationScreen({
    Key? key,
    required this.lat,
    required this.lng,
    required this.riderLat,
    required this.riderLng,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Map<PolylineId, Polyline> polylines = {};
  final PolylinePoints polylinePoints = PolylinePoints();
  final loc.Location location = loc.Location();

  loc.LocationData? _currentPosition;
  late LatLng curLocation;
  late LatLng destinationLocation;
  StreamSubscription<loc.LocationData>? locationSubscription;
  Uint8List? myPosition;
  Marker? bikePosition;
  Marker? destinationPosition;
  bool loadingMarker = false;

  @override
  void initState() {
    super.initState();
    curLocation = LatLng(widget.riderLat, widget.riderLng);
    destinationLocation = LatLng(widget.lat, widget.lng);
    getNavigation();
    addMarker();
    locationSubscription = location.onLocationChanged.listen((loc.LocationData cLoc) {
      _currentPosition = cLoc;
      updateBikePosition();
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: loadingMarker
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: Set<Polyline>.of(polylines.values),
            initialCameraPosition: CameraPosition(
              target: curLocation,
              zoom: 14.5,
            ),
            markers: {
              if (bikePosition != null) bikePosition!,
              if (destinationPosition != null) destinationPosition!,
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            indoorViewEnabled: true,
          ),
          Positioned(
            bottom: 70,
            right: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.navigation_outlined,
                    color: Colors.white,
                  ),
                  onPressed: _launchNavigation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchNavigation() async {
    String googleMapsAndroidURL = 'google.navigation:q=${widget.lat},${widget.lng}&mode=d';
    String googleMapsIosURL = 'comgooglemaps://?daddr=${widget.lat},${widget.lng}&directionsmode=driving';
    String googleMapsWebURL = 'https://www.google.com/maps/dir/?api=1&destination=${widget.lat},${widget.lng}&travelmode=driving';

    if (Platform.isAndroid && await canLaunch(googleMapsAndroidURL)) {
      await launch(googleMapsAndroidURL);
    } else if (Platform.isIOS && await canLaunch(googleMapsIosURL)) {
      await launch(googleMapsIosURL);
    } else {
      await launch(googleMapsWebURL, forceSafariVC: false);
    }
  }

  Future<void> getNavigation() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    if (_permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation();
      curLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: curLocation,
        zoom: 16,
      )));

      if (mounted) {
        setState(() {
          bikePosition = Marker(
            markerId: const MarkerId('bikeID'),
            icon: BitmapDescriptor.fromBytes(myPosition!),
            position: curLocation,
            infoWindow: InfoWindow(
              title: double.parse((getDistance(destinationLocation).toStringAsFixed(2))).toString(),
            ),
          );
        });
      await getDirections(destinationLocation);
      }else {
        return;
      }
    }
  }

  Future<void> getDirections(LatLng dst) async {
    print('redrawing poly line');
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['mapKey']!,
      PointLatLng(curLocation.latitude, curLocation.longitude),
      PointLatLng(dst.latitude, dst.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyline(polylineCoordinates);
  }

  void addPolyline(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 6,
    );
    polylines[id] = polyline;
    if (mounted) {
      setState(() {});
    }
  }

  double calculateDistance(double lat1, double long1, double lat2, double long2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * (1 - c((long2 - long1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng dstPosition) {
    return calculateDistance(curLocation.latitude, curLocation.longitude, dstPosition.latitude, dstPosition.longitude);
  }

  Uint8List? resizeImage(Uint8List data, int width, int height) {
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
    return Uint8List.fromList(IMG.encodePng(resized));
  }

  Future<void> addMarker() async {
    setState(() {
      loadingMarker = true;
    });

    try{
      String imgurl = "https://cdn-icons-png.freepik.com/256/7193/7193391.png?ga=GA1.1.691408758.1706907328&semt=ais";
      String bikeImgUrl = "https://cdn-icons-png.freepik.com/256/5458/5458280.png?ga=GA1.1.691408758.1706907328&semt=ais";

      Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl)).load(imgurl)).buffer.asUint8List();
      Uint8List? smallImg = resizeImage(bytes, 80, 80);

      Uint8List bikeBytes = (await NetworkAssetBundle(Uri.parse(bikeImgUrl)).load(bikeImgUrl)).buffer.asUint8List();
      myPosition = resizeImage(bikeBytes, 80, 80);

      setState(() {
        bikePosition = Marker(
          markerId: const MarkerId('bikeID'),
          position: curLocation,
          icon: BitmapDescriptor.fromBytes(myPosition!),
        );

        destinationPosition = Marker(
          markerId: const MarkerId('destination'),
          position: destinationLocation,
          draggable: true,
          icon: BitmapDescriptor.fromBytes(smallImg!),
        );
      });
    }catch (e){
      print('Marker error $e');
    }finally{
      setState(() {
        loadingMarker = false;
      });
    }
  }

  void updateBikePosition() {
    if (_currentPosition != null) {
      if(mounted){
        setState(() {
          curLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
          bikePosition = Marker(
            markerId: const MarkerId('bikeID'),
            icon: BitmapDescriptor.fromBytes(myPosition!),
            position: curLocation,
          );
        });
      } else{
        return;
      }
      // getDirections(destinationLocation);
    }
  }
}
