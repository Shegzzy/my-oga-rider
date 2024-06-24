import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/profile_controller.dart';
import '../../../model/vehicleModel.dart';


class VehicleType extends StatefulWidget {
  const VehicleType({Key? key, required this.selectedVehicle, required this.onSelect}) : super(key: key);

  final String selectedVehicle;
  final Function onSelect;

  @override
  State<VehicleType> createState() => _VehicleTypeState();
}

class _VehicleTypeState extends State<VehicleType> {

  final ProfileController _pController = Get.put(ProfileController());
  late Future<List<VehicleModel>?> vehicleFuture;

  Future<List<VehicleModel>?> _getAllVehicles() async {
    return await _pController.getAllVehicle();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vehicleFuture = _getAllVehicles();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("Select your type of vehicle?", style: Theme.of(context).textTheme.headlineSmall,),
        const SizedBox(height: 10.0,),

        Flexible(
            child: FutureBuilder<List<VehicleModel>?>(
              future: vehicleFuture,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  if(snapshot.hasData){

                    return ListView.builder(
                      itemBuilder: (ctx,i){
                        return ListTile(
                          onTap: () => widget.onSelect(snapshot.data![i].name),
                          title: Text(snapshot.data![i].name ?? ""),
                          trailing: widget.selectedVehicle == snapshot.data![i].name ? const Padding(
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
      ],
    );
  }
}
