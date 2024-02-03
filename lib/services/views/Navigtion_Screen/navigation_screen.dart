import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:my_oga_rider/global/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:image/image.dart' as IMG;


class NavigationScreen extends StatefulWidget {
  final double lat;
  final double lng;
  NavigationScreen(this.lat, this.lng);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId,Polyline> polylines={};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker? sourcePosition, destinationPosition, bikePosition;
  loc.LocationData? _currentPosition;
  LatLng curLocation = LatLng(9.2612746, 7.3903539);
  StreamSubscription<loc.LocationData>? locationSubscription;
  Set<Marker> markersSet = {};


  @override
  void initState() {
    super.initState();
    getNavigation();
    addMarker();
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: sourcePosition == null
            ? Center(child: CircularProgressIndicator(),)
            : Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            polylines: Set<Polyline>.of(polylines.values),
            initialCameraPosition: CameraPosition(
              target: curLocation,
              zoom: 12,
            ),
            markers: {sourcePosition!, destinationPosition!, bikePosition ?? const Marker(markerId: MarkerId('default'))},
            onTap: (latlng){
              print(latlng);
            },
            onMapCreated: (GoogleMapController controller){
              setState(() {
                _controller.complete(controller);
              });
            },
            indoorViewEnabled: true,
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.blue
              ),
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.navigation_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                      'google.navigation:q=${widget.lat},${widget.lng}&key=${dotenv.env['mapKey']}'
                    ));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getNavigation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    final GoogleMapController? controller =  await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    String imgurl = "https://cdn-icons-png.freepik.com/256/5458/5458280.png?ga=GA1.1.691408758.1706907328&semt=ais";
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl))
        .load(imgurl))
        .buffer
        .asUint8List();

    Uint8List? myPosition = resizeImage(bytes, 80, 80);

    if(!_serviceEnabled){
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled){
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied){
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted){
        return;
      }
    }
    if(_permissionGranted == loc.PermissionStatus.granted){
      _currentPosition = await location.getLocation();
      curLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);

      locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        )));

        if(mounted){
          controller?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
          setState(() {
            curLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);

            bikePosition = Marker(
              markerId: const MarkerId('bikeID'),
              icon: BitmapDescriptor.fromBytes(myPosition!),
              position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title: double.parse((getDistance(LatLng(widget.lat, widget.lng)).toStringAsFixed(2)))
                      .toString()
              ),
            );

          });
          getDirections(LatLng(widget.lat, widget.lng));
        }
      });
    }
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(dotenv.env['mapKey']!,
      PointLatLng(curLocation.latitude, curLocation.longitude),
      PointLatLng(dst.latitude, dst.longitude),
      travelMode: TravelMode.driving
    );
    if(result.points.isNotEmpty){
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    }else {
      print(result.errorMessage);
    }
    addPolyline(polylineCoordinates);
  }

  addPolyline(List<LatLng>polylineCoordinates){
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
    if(mounted){
      setState(() {});
    }
  }

  double calculateDistance(lat1, long1, lat2, long2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p ) / 2 + c(lat1 * p) * (1 - c((long2 - long1) * p )) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng dstPosition){
    return calculateDistance(curLocation.latitude, curLocation.longitude, dstPosition.latitude, dstPosition.longitude);
  }

  Uint8List? resizeImage(Uint8List data, width, height) {
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }

  addMarker() async {
    String imgurl = "https://cdn-icons-png.freepik.com/256/7193/7193391.png?ga=GA1.1.691408758.1706907328&semt=ais";

    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imgurl))
        .load(imgurl))
        .buffer
        .asUint8List();

    Uint8List? smallImg = resizeImage(bytes, 80, 80);

    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      destinationPosition = Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.lat, widget.lng),
        draggable: true,
        icon: BitmapDescriptor.fromBytes(smallImg!)
      );
    });
  }
}
