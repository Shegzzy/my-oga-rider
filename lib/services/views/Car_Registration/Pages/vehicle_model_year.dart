import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VehicleModelYear extends StatefulWidget {
  const VehicleModelYear({Key? key, required this.onSelect}) : super(key: key);

  final Function onSelect;

  @override
  State<VehicleModelYear> createState() => _VehicleModelYearState();
}

class _VehicleModelYearState extends State<VehicleModelYear> {

  List<int> years = [
    2000,
    2001,
    2002,
    2003,
    2004,
    2005,
    2006,
    2007,
    2008,
    2009,
    2010,
    2011,
    2012,
    2013,
    2014,
    2015,
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Text('What is the vehicle model year ?', style: Theme.of(context).textTheme.headlineSmall,),

        SizedBox(height: 10,),


        Expanded(child: Center(
          child: CupertinoPicker.builder(
            childCount: years.length,

            itemBuilder: (BuildContext context, int index) {
              return Center(child: Text(years[index].toString(), style: Theme.of(context).textTheme.headlineMedium,));
            },
            itemExtent: 100,
            onSelectedItemChanged: (value) {
              widget.onSelect(years[value]);
            },
          ),
        )),

      ],
    );
  }
}
