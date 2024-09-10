import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/views/after_auth/home_screen.dart';
import 'package:waygo/views/authentication/phone_sign_up.dart';
import 'package:waygo/views/introduction/intro_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isFirstTime = await _isFirstTime();
      if (isFirstTime) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => IntroPages()),
        );
      } else {
        CustomUser customUser = await _getCustomUserData(user.uid);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(user: customUser)),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }

  Future<bool> _isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }
    return isFirstTime;
  }

  Future<CustomUser> _getCustomUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return CustomUser(
          name: doc['name'] ?? '',
          phoneNumber: doc['phoneNumber'] ?? '',
          email: doc['email'] ?? '',
          dateOfBirth: doc['dateOfBirth'] ?? '',
          gender: doc['gender'] ?? '',
          emergencyContactName: doc['emergencyContactName'] ?? '',
          emergencyContactPhone: doc['emergencyContactPhone'] ?? '',
          otpOnEmail: doc['otpOnEmail'] ?? false,
          isDriver: doc['isDriver'] ?? false,
          vehicleType: doc['vehicleType'] ?? '',
          vehicleBrand: doc['vehicleBrand'] ?? '',
          vehicleModel: doc['vehicleModel'] ?? '',
          vehicleNumber: doc['vehicleNumber'] ?? '',
          vehiclePhoto: doc['vehiclePhoto'] ?? '',
          driversLicensePhoto: doc['driversLicensePhoto'] ?? '',
          userProfilePhoto: doc['userProfilePhoto'] ?? '',
          vehicleAge: doc['vehicleAge'] ?? 0,
        );
      } else {
        return CustomUser();
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return CustomUser();
    }
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
