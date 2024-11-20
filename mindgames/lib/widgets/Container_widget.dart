import 'package:flutter/material.dart';

class ContainerWidget extends StatelessWidget {
  final double screenWidth;
  final Widget child;
  final bool showIcon;

  const ContainerWidget({
    Key? key,
    required this.screenWidth,
    required this.child,
    this.showIcon = false, //Defaultia
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(12.0),
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0.5, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: child),
            if (showIcon)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: screenWidth * 0.04,
              ),
          ],
        ),
      ),
    );
  }
}
