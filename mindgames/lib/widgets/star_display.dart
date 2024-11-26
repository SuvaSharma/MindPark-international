import 'package:flutter/material.dart';

class StarDisplay extends StatelessWidget {
  final int numberOfStars;

  const StarDisplay({
    super.key,
    required this.numberOfStars,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        numberOfStars,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child:
              Image.asset('assets/images/Star.png', // Path to your image asset
                  width: MediaQuery.of(context).size.width * 0.1,
                  // height: MediaQuery.of(context).size.width * 0.1,
                  fit: BoxFit.cover),
        ),
      ),
    );
  }
}
