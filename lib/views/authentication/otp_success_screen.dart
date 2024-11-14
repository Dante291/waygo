import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:waygo/models/user.dart';
import 'package:waygo/views/after_auth/home.dart';
import 'package:waygo/views/authentication/ride_choice_screen.dart';

class SuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2C36),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            Image.asset(
              'assets/images/phoneverified.png',
              height: 200,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            const Text(
              'Phone number verified successfully!',
              style: TextStyle(
                fontFamily: "Montserrat",
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            ElevatedButton(
              onPressed: () {
                checkIfUserExists(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(215, 223, 127, 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "Montserrat",
                    color: Color.fromRGBO(26, 81, 98, 1),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkIfUserExists(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return; // Handle if userId is null
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // If user exists in Firestore, convert the data to CustomUser
        final userData = userSnapshot.data()!;
        CustomUser customUser = CustomUser(
          name: userData['name'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          email: userData['email'] ?? '',
          dateOfBirth: userData['dateOfBirth'] ?? '',
          gender: userData['gender'] ?? '',
          emergencyContactName: userData['emergencyContactName'] ?? '',
          emergencyContactPhone: userData['emergencyContactPhone'] ?? '',
          otpOnEmail: userData['otpOnEmail'] ?? false,
          isDriver: userData['isDriver'] ?? false,
          vehicleType: userData['vehicleType'] ?? '',
          vehicleBrand: userData['vehicleBrand'] ?? '',
          vehicleModel: userData['vehicleModel'] ?? '',
          vehicleNumber: userData['vehicleNumber'] ?? '',
          vehiclePhoto: userData['vehiclePhoto'] ?? '',
          driversLicensePhoto: userData['driversLicensePhoto'] ?? '',
          userProfilePhoto: userData['userProfilePhoto'] ?? '',
          vehicleAge: userData['vehicleAge'] ?? 0,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home(user: customUser)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RideChoiceScreen()),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('Could not check user status. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B2C36),
          title: const Text(
            'Error',
            style: TextStyle(color: Color(0xFFD7DF7F)),
          ),
          content: const Text(
            'An error occurred. Please try again later.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFFD7DF7F)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
