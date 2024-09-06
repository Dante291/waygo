import 'package:waygo/views/authentication/phone_sign_up.dart';
import 'package:flutter/material.dart';
import 'intro_screen.dart';

class IntroPages extends StatefulWidget {
  @override
  _IntroPagesState createState() => _IntroPagesState();
}

class _IntroPagesState extends State<IntroPages> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          IntroScreen(
            currentPage: 0,
            totalPageCount: 3,
            imagePath: 'assets/images/splash.png',
            title: 'WayGo',
            subtitle: 'Save Money, Share The Journey,\n Make New Friends! 😊',
            description:
                'Just enter your route and find affordable\n rides within minutes!',
            subHeading: 'FIND QUICK RIDES',
            onNext: _nextPage,
            buttonText: "NEXT",
          ),
          IntroScreen(
            currentPage: 1,
            totalPageCount: 3,
            imagePath: 'assets/images/intro2.png',
            title: 'WayGo',
            subtitle: 'Save Money, Share The Journey,\n Make New Friends! 😊',
            description:
                'Got vacant space in your vehicle? Find quick\n rides and make money!',
            subHeading: 'OFFERS RIDES ON THE GO',
            onNext: _nextPage,
            buttonText: 'NEXT',
          ),
          IntroScreen(
            currentPage: 2,
            totalPageCount: 3,
            imagePath: 'assets/images/intro3.png',
            title: 'WayGo',
            subtitle: 'Save Money, Share The Journey,\n Make New Friends! 😊',
            description:
                'Schedule your trips in advance, and book the\nperfect ride for your future trip!',
            subHeading: 'SCHEDULE YOUR TRIPS',
            onNext: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen())),
            buttonText: "GET STARTED",
          ),
        ],
      ),
    );
  }
}
