import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sos/pages/contact.dart';
import 'package:sos/pages/home.dart';
import 'package:sos/pages/profile.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedIndex = 0;

  // This method updates the new selected index
  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // List of pages to display
  final List<Widget> _pages = [
    // Replace with your actual home content widget
    HomePage(),
    // Contact page
    ContactPage(),
    // Profile page
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      backgroundColor: Color(0xffFFFFFF),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Color(0xffFFFFFF),
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          selectedItemColor: Color.fromRGBO(0, 0, 0, 1), // Selected item color
          unselectedItemColor: Colors.grey, // Unselected item color
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: SvgPicture.asset(
                'assets/icons/Home.svg',
                height: 23,
                width: 23,
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/Home.svg',
                height: 30,
                width: 30,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              label: 'Contacts',
              icon: SvgPicture.asset(
                'assets/icons/Contact.svg',
                height: 23,
                width: 23,
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/Contact.svg',
                height: 30,
                width: 30,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: SvgPicture.asset(
                'assets/icons/Profile.svg',
                height: 23,
                width: 23,
              ),
              activeIcon: SvgPicture.asset(
                'assets/icons/Profilem.svg',
                height: 30,
                width: 30,
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
