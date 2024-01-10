import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/constant/image_string.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';

import '../../../constant/colors.dart';
import '../../controller/getx_switch_state.dart';
import '../../controller/profile_controller.dart';
import '../../model/booking_model.dart';
import '../Booking_Details/booking_details_screen.dart';


class BookingTabPage extends StatefulWidget {
  const BookingTabPage({Key? key}) : super(key: key);

  @override
  State<BookingTabPage> createState() => _BookingTabPageState();
}

class _BookingTabPageState extends State<BookingTabPage> {

  final GetXSwitchState getXSwitchState = Get.find();
  late Future<List<BookingModel>?> userFuture;
  ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    userFuture = _getBookings();
  }

  Future<List<BookingModel>?> _getBookings() async {
    return await controller.getAllUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = getXSwitchState.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,

      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ///Future Builder
        child: FutureBuilder<List<BookingModel>?>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                //Controllers
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (c, index){
                    return  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(bookingData: snapshot.data![index],)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0, top: 5.0),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: isDark ? Colors.black.withOpacity(0.1) : moPrimaryColor),
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(snapshot.data![index].bookingNumber!,
                                      style: Theme.of(context).textTheme.headlineMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  Flexible(child: Text(snapshot.data![index].status!,
                                      style: TextStyle(color: isDark ? snapshot.data![index].status == "completed" ? Colors.blue : Colors.yellowAccent.shade400  : snapshot.data![index].status == "completed" ? Colors.green : Colors.blueAccent ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(shape: const CircleBorder(), minimumSize: const Size(30, 30)),
                                    onPressed: () {},
                                    child: const Icon(Icons.location_pin, size: 20,),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(snapshot.data![index].pickup_address ?? "", style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                          const SizedBox(height: 10,),
                                          Text(snapshot.data![index].dropOff_address ?? "", style: Theme.of(context).textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(child: Text(snapshot.data![index].deliveryMode ?? "",
                                      style: Theme.of(context).textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),

                                  Flexible(child: Text(MyOgaFormatter.currencyFormatter(double.parse(snapshot.data![index].amount ?? "")),
                                      style: Theme.of(context).textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),

                                  Flexible(child: Text(snapshot.data![index].distance ?? "",
                                      style: Theme.of(context).textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              else {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }
            }
            else {
              return const Center(
                  child: CircularProgressIndicator());
            }
          },
        ),
      ),

    );
  }
}
