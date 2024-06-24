import 'package:flutter/material.dart';

import '../constant/colors.dart';


class CustomBtn extends StatelessWidget {
  final String text;
  final Color? txtColor;
  final Color bgColor;
  final Color? shadowColor;
  VoidCallback onTap;

  CustomBtn({Key? key,
        required this.text,
        this.txtColor,
        required this.bgColor,
        this.shadowColor,
        required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: bgColor ?? black,
            boxShadow: [
              BoxShadow(
                  color: shadowColor == null
                      ? Colors.grey.withOpacity(0.5)
                      : shadowColor!.withOpacity(0.5),
                  offset: const Offset(2, 3),
                  blurRadius: 4)
            ]),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(text, style: Theme.of(context).textTheme.headlineSmall,),
        ),
      ),
    );
  }
}
