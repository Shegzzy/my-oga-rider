import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/locationModel.dart';
import '../../../controller/profile_controller.dart';


class LocationPage extends StatefulWidget {
  LocationPage(
      {Key? key, required this.selectedLocation, required this.onSelect})
      : super(key: key);

  final String selectedLocation;
  final Function onSelect;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  final ProfileController _pController = Get.put(ProfileController());
  late Future<List<LocationModel>?> locationFuture;

  Future<List<LocationModel>?> _getAllLocations() async {
    return await _pController.getAllLocation();
  }


  List<String> locations = [
    'Abuja',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationFuture = _getAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "What service location do you want to register for?", style: Theme
              .of(context)
              .textTheme
              .headlineSmall,),
          const SizedBox(height: 10.0,),
          
          Flexible(
              child: FutureBuilder<List<LocationModel>?>(
                future: locationFuture,
                  builder: (context, snapshot){
                   if(snapshot.connectionState == ConnectionState.done){
                     if(snapshot.hasData){

                       return ListView.builder(
                         itemBuilder: (ctx,i){
                         return ListTile(
                           onTap: () => widget.onSelect(snapshot.data![i].name),
                           title: Text(snapshot.data![i].name ?? ""),
                           trailing: widget.selectedLocation == snapshot.data![i].name ? const Padding(
                             padding: EdgeInsets.all(10.0),
                             child: CircleAvatar(
                               backgroundColor: Colors.green,
                               child: Icon(Icons.check, color: Colors.white, size: 15,),
                             ),
                           ) : const SizedBox.shrink(),
                         );
                       }, itemCount: snapshot.data!.length,shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                       );
                     } else if (snapshot.hasError) {
                       return Center(
                         child: Text(snapshot.error.toString()),
                       );
                     } else {
                       return const Center(
                         child: Text("Something went wrong"),
                       );
                     }

                   } else {
                     return const Center(
                         child: CircularProgressIndicator());
                   }
                  },
              ),
          ),
        ]
    );
  }
}