import 'package:flutter/material.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/views/after_auth/find_ride_section/find_ride_section.dart';
import 'package:waygo/views/after_auth/home_screen_view.dart';
import 'package:waygo/views/after_auth/offer_ride_section/offer_ride_section.dart';
import 'package:waygo/views/after_auth/user_profile/user_profile.dart';

class Home extends StatefulWidget {
  final CustomUser user;

  Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      // Home screen content
      HomeScreen(user: widget.user),
      // Offer Ride screen content
      const OfferRideSection(),
      // Find Ride screen content
      const FindRideSection(),
      // Account screen content
      UserProfile(
        user: widget.user,
      ),
    ];
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromARGB(243, 255, 255, 255),
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              currentIndex: _selectedIndex,
              selectedItemColor: const Color.fromRGBO(215, 223, 127, 1),
              unselectedItemColor: Colors.white,
              showUnselectedLabels: true,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home,
                    color: _selectedIndex == 0
                        ? const Color.fromRGBO(215, 223, 127, 1)
                        : Colors.white,
                    size: 30,
                  ),
                  label: 'Home',
                  backgroundColor: const Color.fromRGBO(26, 81, 98, 1),
                ),
                BottomNavigationBarItem(
                  icon: Image.asset('assets/images/offer_ride_logo.png',
                      color: _selectedIndex == 1
                          ? const Color.fromRGBO(215, 223, 127, 1)
                          : Colors.white,
                      width: 50,
                      height: 30),
                  label: 'Offer Ride',
                  backgroundColor: const Color.fromRGBO(26, 81, 98, 1),
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/images/find_ride_logo.png',
                    color: _selectedIndex == 2
                        ? const Color.fromRGBO(215, 223, 127, 1)
                        : Colors.white,
                    width: 50,
                    height: 30,
                  ),
                  label: 'Find Ride',
                  backgroundColor: const Color.fromRGBO(26, 81, 98, 1),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person,
                    color: _selectedIndex == 3
                        ? const Color.fromRGBO(215, 223, 127, 1)
                        : Colors.white,
                    size: 35,
                  ),
                  label: 'Account',
                  backgroundColor: const Color.fromRGBO(26, 81, 98, 1),
                ),
              ],
              selectedLabelStyle: const TextStyle(
                color: Color.fromRGBO(215, 223, 127, 1),
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                color: Colors.white,
              ),
            )));
  }
}
