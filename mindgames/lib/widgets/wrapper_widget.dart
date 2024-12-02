import 'package:flutter/material.dart';
import 'package:mindgames/Home_Page.dart';
import 'package:mindgames/check_internet_widget.dart';
import 'package:mindgames/news_page.dart';
import 'package:mindgames/parents_portal_sections/Parents_portal_page.dart';
import 'package:mindgames/widgets/navigation_bar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const CheckInternetWidget(onlinePage: ParentsPortalPage()),
    const MainPage(),
    const CheckInternetWidget(
      onlinePage: NewsPage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
