import 'package:flutter/material.dart';
import '../constant/colors.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: moSecondarColor,
      child: Container(
        margin: const EdgeInsets.all(15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(width: 6.0,),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(moAccentColor),),
              const SizedBox(width: 6.0,),
              Text(message, style: const TextStyle(color: Colors.black),),
            ],
          ),
        ),
      ),
    );
  }
}
