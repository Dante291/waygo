import 'package:waygo/views/introduction/intro_pages.dart';
import 'package:flutter/material.dart';

import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => IntroPages(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 47, 58, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash.png'),
            const Text(
              "Waygo",
              style: TextStyle(
                fontFamily: "Lalezar",
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(215, 223, 127, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
