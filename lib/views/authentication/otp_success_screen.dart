import 'package:waygo/views/authentication/ride_choice_screen.dart';
import 'package:flutter/material.dart';

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RideChoiceScreen()),
                );
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
}
