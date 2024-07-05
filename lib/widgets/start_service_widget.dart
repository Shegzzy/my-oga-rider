import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class StartServiceScreen extends StatelessWidget {
  const StartServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      child: Column(
        children: [
          Text("Booking Status", style: theme.textTheme.titleLarge,),
          const SizedBox(height: 30,),
          Row(
            children: [
              Icon(LineAwesomeIcons.user, size: 30,),
              SizedBox(width: 10.0,),
              Text("Edward Samuel", style: theme.textTheme.headlineSmall,),
              
            ],
          ),
        ],
      ),
    );
  }
}
