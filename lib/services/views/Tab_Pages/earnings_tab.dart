import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_oga_rider/utils/formatter/formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/colors.dart';
import '../../../constant/text_strings.dart';
import '../../controller/profile_controller.dart';
import '../../model/booking_model.dart';


class EarningTabPage extends StatefulWidget {
  const EarningTabPage({Key? key}) : super(key: key);

  @override
  State<EarningTabPage> createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  _EarningTabPageState() {
    _selectedDays = _earningDays[0];
  }

  late Future<List<BookingModel>?> userFuture;
  final _db = FirebaseFirestore.instance;
  String? userID;
  double _total = 0;
  double _total30 = 0;
  double _total7 = 0;
  double _total1 = 0;
  double? _amount;
  double? _amount30;
  double? _amount7;
  double? _amount1;
  late DateTime _userTime30, _userTime7, _userTime1;
  late DateTime queryDate30, queryDate7, queryDate1;
  ProfileController controller = Get.put(ProfileController());
  final _earningDays = ["Total Earnings", "30 Days Earnings","7 Days Earnings", "24 Hours Earnings" ];
  String? _selectedDays = "";

  @override
  void initState() {
    super.initState();
    userFuture = _getBookings();
    getTotal();
    get30days();
    get7days();
    get1days();
  }

  Future<List<BookingModel>?>_getBookings() async {
    return await controller.getAllUserBookings();
  }

  Future<void>get30days()async{
    DateTime currentDate = DateTime.now();
    queryDate30 = currentDate.subtract(const Duration(days:30));
    Timestamp  timestamp= Timestamp.fromDate(queryDate30);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    try {
      await _db.collection("Earnings").where("Driver", isEqualTo: userID).get().then((value) {
        for (var element in value.docs) {
          _userTime30 = DateTime.parse(element.data()["timeStamp"].toDate().toString());
          if (_userTime30.isAfter(queryDate30)) {
            _amount30 = double.tryParse(element.data()["Amount"]);
            setState(() {
              _total30 += _amount30!;
            });
          }
        }
      });
      if (!mounted) {
        return;
      }
    }catch (e){
      return;
    }
  }

  Future<void>get7days()async{
    DateTime currentDate = DateTime.now();
    queryDate7 = currentDate.subtract(const Duration(days:7));
    Timestamp  timestamp= Timestamp.fromDate(queryDate7);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    try {
      await _db.collection("Earnings").where("Driver", isEqualTo: userID).get().then((value) {
        for (var element in value.docs) {
          _userTime7 = DateTime.parse(element.data()["timeStamp"].toDate().toString());
          if (_userTime7.isAfter(queryDate7)) {
            _amount7 = double.tryParse(element.data()["Amount"]);
            setState(() {
              _total7 += _amount7!;
            });
          }
        }
      });
      if (!mounted) {
        return;
      }
    }catch (e){
      return;
    }
  }

  Future<void>get1days()async{
    DateTime currentDate = DateTime.now();
    queryDate1 = currentDate.subtract(const Duration(hours:24));
    Timestamp  timestamp= Timestamp.fromDate(queryDate1);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    try {
      await _db.collection("Earnings").where("Driver", isEqualTo: userID).get().then((value) {
        for (var element in value.docs) {
          _userTime1 = DateTime.parse(element.data()["timeStamp"].toDate().toString());
          if (_userTime1.isAfter(queryDate1)) {
            _amount1 = double.tryParse(element.data()["Amount"]);
            setState(() {
              _total1 += _amount1!;
            });
          }
        }
      }).catchError((error, stackTrace) {

      });
      if (!mounted) {
        return;
      }
    }catch (e){
      return;
    }
  }

  Future<void>getTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString("UserID")!;
    await _db.collection("Earnings").where("Driver", isEqualTo:userID).get().then((value){
          for (var element in value.docs) {
            _amount = double.tryParse(element.data()["Amount"]);
            setState(() {
              _total = _total + _amount!;
            });
          }
          if (kDebugMode) {
            print("THIS IS TOTAL $_total");
          }
        });
    if(!mounted){return;}

}

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final txtTheme = Theme
        .of(context)
        .textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("My Earnings", style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Card(
            elevation: 20,
            shadowColor: Colors.black,
            color: moPrimaryColor,
            child: SizedBox(
              width: 400,
              height: 220,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10,),
                    Container(
                      width: 160,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: DropdownButtonFormField(
                        value: _selectedDays,
                        items: _earningDays
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDays = val as String;
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colors.deepPurple,
                        ),
                        dropdownColor: Colors.grey,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text("$_selectedDays", style: txtTheme.displayMedium),
                    const SizedBox(height: 10,),
                    if(_selectedDays == "30 Days Earnings")...[
                      Text(MyOgaFormatter.currencyFormatter(_total30), style: txtTheme.titleLarge?.apply(fontSizeFactor: 2.2)),
                    ] else if(_selectedDays == "7 Days Earnings")...[
                      Text("NGN $_total7", style: txtTheme.titleLarge?.apply(fontSizeFactor: 2.2)),
                    ]else if(_selectedDays == "24 Hours Earnings")...[
                      Text("NGN $_total1", style: txtTheme.titleLarge?.apply(fontSizeFactor: 2.2)),
                    ]else if(_selectedDays == "Total Earnings")...[
                      Text(MyOgaFormatter.currencyFormatter(_total).toString(), style: txtTheme.titleLarge?.apply(fontSizeFactor: 2.2)),
                    ]
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30,),
          Expanded(
            child: FutureBuilder<List<BookingModel>?>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    //Controllers
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (c, index){
                        return  GestureDetector(
                          onTap: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => BookingDetailsScreen(bookingData: snapshot.data![index],)));
                          },
                          child: SizedBox(
                            width: 380,
                            height: 150,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0, top: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: PCardBgColor),
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: Text(snapshot.data![index].bookingNumber ?? "",
                                            style: Theme.of(context).textTheme.headlineMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                        Flexible(child: Text(snapshot.data![index].status ?? "",
                                            style: TextStyle(color: snapshot.data![index].status == "completed" ? Colors.green : Colors.blueAccent ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: Text(MyOgaFormatter.currencyFormatter(
                                              double.parse(snapshot
                                                      .data![index].amount ??
                                                  "")),
                                            style: Theme.of(context).textTheme.headlineMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                        Flexible(child: Text(snapshot.data![index].distance ?? "",
                                            style: Theme.of(context).textTheme.headlineMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    const SizedBox(height:10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(child: Text(My ?? "",
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
        ],
      ),
    );
  }
}
