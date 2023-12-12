import 'package:flutter/material.dart';

import '../../../constant/colors.dart';
import '../../../widgets/custom_btn.dart';
import '../../AppServices/app_provider.dart';
import '../../model/booking_model.dart';
import 'package:provider/provider.dart';


class RideRequestScreen extends StatefulWidget {
  @override
  _RideRequestScreenState createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {

  @override
  void initState() {
    super.initState();
    AppStateProvider _state = Provider.of<AppStateProvider>(context, listen: false);
    _state.listenToRequest(id: _state.rideRequestModel.id, context: context);
  }
  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    //UserProvider userProvider = Provider.of<UserProvider>(context);
    var request = Provider.of<BookingModel>(context);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text( "New Ride Request",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          backgroundColor: white,
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //if (appState.riderModel.photo == null)
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(40)),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 45,
                          child: Icon(
                            Icons.person,
                            size: 65,
                            color: white,
                          ),
                        ),
                      ),
                    //if (appState.riderModel.photo != null)
                    //  Container(
                    //    decoration: BoxDecoration(
                    //        color: Colors.deepOrange,
                    //        borderRadius: BorderRadius.circular(40)),
                    //    child: CircleAvatar(
                    //      radius: 45,
                    //      backgroundImage: NetworkImage(appState.riderModel?.photo),
                    //    ),
                    //  ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appState.requestModelFirebase.customerName ?? "Nada"),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pick Up", style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  subtitle: TextButton.icon(
                      onPressed: () async {},
                      icon: const Icon(
                        Icons.location_on,
                      ),
                      label:Text( appState.requestModelFirebase.pickUpAddy ?? "Nada",
                      style: Theme.of(context).textTheme.bodyLarge,)),
                ),
                const Divider(),
                ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Drop Off", style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  subtitle: TextButton.icon(
                      onPressed: () async {},
                      icon: const Icon(
                        Icons.location_on,
                      ),
                      label:Text( appState.requestModelFirebase.dropOffAddy ?? "Nada",
                        style: Theme.of(context).textTheme.bodyLarge,)),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomBtn(
                      text: "Accept",
                      onTap: () async {
                      },
                      bgColor: green,
                      shadowColor: Colors.greenAccent,
                    ),
                    CustomBtn(
                      text: "Reject",
                      onTap: () {
                        //appState.clearMarkers();
                        //appState.changeRideRequestStatus();
                      },
                      bgColor: red,
                      shadowColor: Colors.redAccent,
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }


}