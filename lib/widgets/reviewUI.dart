import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

import '../constant/colors.dart';

class ReviewUI extends StatelessWidget {
  final String? image, name, date, comment;
  final double? rating;
  final VoidCallback? onTap;
  final bool? isLess;
  const ReviewUI({
    Key? key,
    this.image,
    this.name,
    this.date,
    this.comment,
    this.rating,
    this.onTap,
    this.isLess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 2.0, bottom: 2.0, left: 16.0, right: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45.0,
                width: 45.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(image!), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(44.0),
                ),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                  child: Text(name!,
                    style: Theme.of(context).textTheme.headline6,
                  )),
              const SizedBox(
                width: 20.0,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_outlined),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              RatingStars(
                value: rating!,
                starCount: 5,
                starSize: 20,
                starColor: moSecondarColor,
                starOffColor: const Color(0xffe7e8ea),
                animationDuration: const Duration(milliseconds: 1000),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Text(
                date!,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          GestureDetector(
            onTap: onTap,
            child: isLess! ? Text(
              comment!,
              style: Theme.of(context).textTheme.bodyText2,
            ) :
            Text(
              comment!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}