import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      elevation: 10,
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(Iconsax.people, 'Parents Portal', 0, screenWidth),
        _buildNavItem(Iconsax.home, 'Home', 1, screenWidth),
        _buildNavItem(Iconsax.document, 'News', 2, screenWidth),
      ],
      selectedItemColor: Color(0xFF309092),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontSize: screenWidth * 0.035,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: screenWidth * 0.028,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index, double screenWidth) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: screenWidth * 0.07,
      ),
      label: label.tr,
    );
  }
}
