import 'package:flutter/material.dart';

import '../../../constant/image_string.dart';
import '../../../constant/text_strings.dart';


class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(image: const AssetImage(moSplashImage), height: size.height * 0.1,),
        Text(moWelcomeBack, style: Theme.of(context).textTheme.displayLarge,),
        Text(moWelcomeBackTagline, style: Theme.of(context).textTheme.displayLarge,),
      ],
    );
  }
}
