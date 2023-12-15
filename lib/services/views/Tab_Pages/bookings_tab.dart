import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/constant/image_string.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';

import '../../../constant/colors.dart';
import '../../controller/profile_controller.dart';
import '../../model/booking_model.dart';
import '../Booking_Details/booking_details_screen.dart';


class BookingTabPage extends StatefulWidget {
  const BookingTabPage({Key? key}) : super(key: key);

  @override
  State<BookingTabPage> createState() => _BookingTabPageState();
}

class _BookingTabPageState extends State<BookingTabPage> {

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,

      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),

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
                      child: SizedBox(
                        width: 380,
                        height: 210,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0, top: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: moPrimaryColor),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(snapshot.data![index].bookingNumber!,
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    Flexible(child: Text(snapshot.data![index].status!,
                                        style: TextStyle(color: snapshot.data![index].status == "completed" ? Colors.green : Colors.blueAccent ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(shape: const CircleBorder(), minimumSize: Size(35, 35)),
                                      onPressed: () {},
                                      child: const Icon(Icons.location_pin),
                                    ),
                                    const SizedBox(width: 20.0),
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
                                    Flexible(child: Text(MyOgaFormatter.currencyFormatter(double.parse(snapshot.data![index].amount ?? "")),
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                    Flexible(child: Text(snapshot.data![index].distance ?? "",
                                        style: Theme.of(context).textTheme.headlineMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
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
